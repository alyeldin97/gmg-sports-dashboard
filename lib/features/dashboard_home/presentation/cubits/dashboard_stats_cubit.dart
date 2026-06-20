import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../orders/data/model/order.dart';

class DashboardStatsState extends Equatable {
  final double monthRevenue;
  final int totalOrders;
  final int pendingOrders;
  final Map<String, int> ordersByStatus; // status string -> count
  final List<MapEntry<DateTime, double>> revenueByDay; // last 7 days
  final List<Order> recentOrders;
  final bool isLoading;
  final String? error;

  const DashboardStatsState({
    this.monthRevenue = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.ordersByStatus = const {},
    this.revenueByDay = const [],
    this.recentOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardStatsState copyWith({
    double? monthRevenue,
    int? totalOrders,
    int? pendingOrders,
    Map<String, int>? ordersByStatus,
    List<MapEntry<DateTime, double>>? revenueByDay,
    List<Order>? recentOrders,
    bool? isLoading,
    String? error,
  }) =>
      DashboardStatsState(
        monthRevenue: monthRevenue ?? this.monthRevenue,
        totalOrders: totalOrders ?? this.totalOrders,
        pendingOrders: pendingOrders ?? this.pendingOrders,
        ordersByStatus: ordersByStatus ?? this.ordersByStatus,
        revenueByDay: revenueByDay ?? this.revenueByDay,
        recentOrders: recentOrders ?? this.recentOrders,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [
        monthRevenue,
        totalOrders,
        pendingOrders,
        ordersByStatus,
        revenueByDay,
        recentOrders,
        isLoading,
        error,
      ];
}

class DashboardStatsCubit extends Cubit<DashboardStatsState> {
  final SupabaseClient _client;

  DashboardStatsCubit(this._client) : super(const DashboardStatsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final rows = await _client
          .from('orders')
          .select('*, order_items(*)')
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', tomorrowStart.toIso8601String())
          .order('created_at', ascending: false);

      final orders = (rows as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

      // Today's revenue (exclude cancelled)
      final monthRevenue = orders
          .where((o) => o.status != OrderStatus.cancelled)
          .fold<double>(0, (sum, o) => sum + o.total);

      // Orders grouped by status (today only)
      final byStatus = <String, int>{};
      for (final s in OrderStatus.values) {
        byStatus[s.name] = 0;
      }
      for (final o in orders) {
        byStatus[o.status.name] = (byStatus[o.status.name] ?? 0) + 1;
      }

      final pendingOrders = byStatus[OrderStatus.pending.name] ?? 0;

      // Revenue for today (single point in the trend).
      final revenueByDay = <MapEntry<DateTime, double>>[
        MapEntry(todayStart, monthRevenue),
      ];

      emit(state.copyWith(
        isLoading: false,
        monthRevenue: monthRevenue,
        totalOrders: orders.length,
        pendingOrders: pendingOrders,
        ordersByStatus: byStatus,
        revenueByDay: revenueByDay,
        recentOrders: orders.take(10).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
