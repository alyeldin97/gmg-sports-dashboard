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
      final rows = await _client
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      final orders = (rows as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      // Revenue this month (exclude cancelled)
      final monthRevenue = orders
          .where((o) =>
              o.status != OrderStatus.cancelled &&
              !o.createdAt.isBefore(monthStart))
          .fold<double>(0, (sum, o) => sum + o.total);

      // Orders grouped by status
      final byStatus = <String, int>{};
      for (final s in OrderStatus.values) {
        byStatus[s.name] = 0;
      }
      for (final o in orders) {
        byStatus[o.status.name] = (byStatus[o.status.name] ?? 0) + 1;
      }

      final pendingOrders = byStatus[OrderStatus.pending.name] ?? 0;

      // Revenue by day for the last 7 days (oldest -> newest)
      final revenueByDay = <MapEntry<DateTime, double>>[];
      final today = DateTime(now.year, now.month, now.day);
      for (var i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final next = day.add(const Duration(days: 1));
        final dayRevenue = orders
            .where((o) =>
                o.status != OrderStatus.cancelled &&
                !o.createdAt.isBefore(day) &&
                o.createdAt.isBefore(next))
            .fold<double>(0, (sum, o) => sum + o.total);
        revenueByDay.add(MapEntry(day, dayRevenue));
      }

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
