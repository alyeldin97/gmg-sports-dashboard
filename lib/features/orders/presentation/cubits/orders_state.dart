part of 'orders_cubit.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<Order> orders;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  int get pendingCount => orders.where((o) => o.status == OrderStatus.pending).length;
  double get revenue => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.total);

  OrdersState copyWith({OrdersStatus? status, List<Order>? orders, String? errorMessage}) => OrdersState(
        status: status ?? this.status,
        orders: orders ?? this.orders,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, orders, errorMessage];
}
