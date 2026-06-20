import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../orders/data/model/order.dart';

class AnalyticsState extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final bool isLoading;
  final String? error;

  // Metrics
  final double totalRevenue;
  final int totalOrders;
  final double avgOrderValue;
  final int newCustomers; // unique customer emails

  // Breakdown
  final Map<String, int> ordersByStatus; // status -> count
  final List<MapEntry<DateTime, double>> revenueByDay; // for chart
  final List<TopProduct> topProducts; // product name -> units + revenue

  // Comparison (vs previous period of same length)
  final double prevRevenue;
  final int prevOrders;
  final double prevAvgOrderValue;

  const AnalyticsState({
    required this.startDate,
    required this.endDate,
    this.isLoading = false,
    this.error,
    this.totalRevenue = 0,
    this.totalOrders = 0,
    this.avgOrderValue = 0,
    this.newCustomers = 0,
    this.ordersByStatus = const {},
    this.revenueByDay = const [],
    this.topProducts = const [],
    this.prevRevenue = 0,
    this.prevOrders = 0,
    this.prevAvgOrderValue = 0,
  });

  AnalyticsState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoading,
    String? error,
    double? totalRevenue,
    int? totalOrders,
    double? avgOrderValue,
    int? newCustomers,
    Map<String, int>? ordersByStatus,
    List<MapEntry<DateTime, double>>? revenueByDay,
    List<TopProduct>? topProducts,
    double? prevRevenue,
    int? prevOrders,
    double? prevAvgOrderValue,
  }) =>
      AnalyticsState(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        totalRevenue: totalRevenue ?? this.totalRevenue,
        totalOrders: totalOrders ?? this.totalOrders,
        avgOrderValue: avgOrderValue ?? this.avgOrderValue,
        newCustomers: newCustomers ?? this.newCustomers,
        ordersByStatus: ordersByStatus ?? this.ordersByStatus,
        revenueByDay: revenueByDay ?? this.revenueByDay,
        topProducts: topProducts ?? this.topProducts,
        prevRevenue: prevRevenue ?? this.prevRevenue,
        prevOrders: prevOrders ?? this.prevOrders,
        prevAvgOrderValue: prevAvgOrderValue ?? this.prevAvgOrderValue,
      );

  /// Percent change of revenue vs previous period (null when no baseline).
  double? get revenueChange => _pctChange(totalRevenue, prevRevenue);
  double? get ordersChange => _pctChange(totalOrders.toDouble(), prevOrders.toDouble());
  double? get avgOrderChange => _pctChange(avgOrderValue, prevAvgOrderValue);

  static double? _pctChange(double current, double previous) {
    if (previous == 0) return current == 0 ? 0 : null;
    return ((current - previous) / previous) * 100;
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        isLoading,
        error,
        totalRevenue,
        totalOrders,
        avgOrderValue,
        newCustomers,
        ordersByStatus,
        revenueByDay,
        topProducts,
        prevRevenue,
        prevOrders,
        prevAvgOrderValue,
      ];
}

class TopProduct extends Equatable {
  final String name;
  final int units;
  final double revenue;

  const TopProduct({required this.name, required this.units, required this.revenue});

  @override
  List<Object?> get props => [name, units, revenue];
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit()
      : super(AnalyticsState(
          startDate: _todayStart(),
          endDate: _todayStart().add(const Duration(days: 1)),
        ));

  SupabaseClient get _client => Supabase.instance.client;

  static DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ── Range presets ──────────────────────────────────────────────────────────

  Future<void> loadForToday() {
    final start = _todayStart();
    return setRange(start, start.add(const Duration(days: 1)));
  }

  Future<void> loadForYesterday() {
    final start = _todayStart().subtract(const Duration(days: 1));
    return setRange(start, start.add(const Duration(days: 1)));
  }

  Future<void> loadForLast7Days() {
    final tomorrow = _todayStart().add(const Duration(days: 1));
    return setRange(_todayStart().subtract(const Duration(days: 6)), tomorrow);
  }

  Future<void> loadForThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final tomorrow = _todayStart().add(const Duration(days: 1));
    return setRange(start, tomorrow);
  }

  Future<void> setRange(DateTime start, DateTime end) {
    emit(state.copyWith(startDate: start, endDate: end));
    return load();
  }

  // ── Data load ───────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final start = state.startDate;
      final end = state.endDate;
      final duration = end.difference(start);
      final prevStart = start.subtract(duration);

      final current = await _fetchOrders(start, end);
      final previous = await _fetchOrders(prevStart, start);

      // Total revenue (exclude cancelled).
      final valid = current.where((o) => o.status != OrderStatus.cancelled).toList();
      final totalRevenue = valid.fold<double>(0, (sum, o) => sum + o.total);
      final totalOrders = valid.length;
      final avgOrderValue = totalOrders == 0 ? 0.0 : totalRevenue / totalOrders;

      // Unique customers (by guest_email, falling back to recipient phone).
      final customers = <String>{};
      for (final o in valid) {
        final key = (o.guestEmail?.trim().isNotEmpty ?? false)
            ? o.guestEmail!.trim().toLowerCase()
            : o.recipientPhone.trim();
        if (key.isNotEmpty) customers.add(key);
      }

      // Orders by status (all orders in range, including cancelled).
      final byStatus = <String, int>{};
      for (final o in current) {
        byStatus[o.status.name] = (byStatus[o.status.name] ?? 0) + 1;
      }

      // Revenue by day.
      final revenueByDay = _revenueByDay(valid, start, end);

      // Top products by revenue from order_items.
      final productAgg = <String, _Agg>{};
      for (final o in valid) {
        for (final item in o.items) {
          final agg = productAgg.putIfAbsent(item.name, () => _Agg());
          agg.units += item.quantity;
          agg.revenue += item.subtotal;
        }
      }
      final topProducts = (productAgg.entries
              .map((e) => TopProduct(name: e.key, units: e.value.units, revenue: e.value.revenue))
              .toList()
            ..sort((a, b) => b.revenue.compareTo(a.revenue)))
          .take(10)
          .toList();

      // Previous period metrics.
      final prevValid = previous.where((o) => o.status != OrderStatus.cancelled).toList();
      final prevRevenue = prevValid.fold<double>(0, (sum, o) => sum + o.total);
      final prevOrders = prevValid.length;
      final prevAvg = prevOrders == 0 ? 0.0 : prevRevenue / prevOrders;

      emit(state.copyWith(
        isLoading: false,
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        avgOrderValue: avgOrderValue,
        newCustomers: customers.length,
        ordersByStatus: byStatus,
        revenueByDay: revenueByDay,
        topProducts: topProducts,
        prevRevenue: prevRevenue,
        prevOrders: prevOrders,
        prevAvgOrderValue: prevAvg,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<List<Order>> _fetchOrders(DateTime start, DateTime end) async {
    final rows = await _client
        .from('orders')
        .select('*, order_items(*)')
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String());
    return (rows as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Buckets revenue by calendar day across the [start, end) window.
  List<MapEntry<DateTime, double>> _revenueByDay(
      List<Order> orders, DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final result = <MapEntry<DateTime, double>>[];
    var day = startDay;
    // Cap buckets so a huge custom range doesn't produce thousands of points.
    const maxDays = 90;
    var count = 0;
    while (day.isBefore(end) && count < maxDays) {
      final next = day.add(const Duration(days: 1));
      final dayRevenue = orders
          .where((o) => !o.createdAt.isBefore(day) && o.createdAt.isBefore(next))
          .fold<double>(0, (sum, o) => sum + o.total);
      result.add(MapEntry(day, dayRevenue));
      day = next;
      count++;
    }
    return result;
  }
}

class _Agg {
  int units = 0;
  double revenue = 0;
}
