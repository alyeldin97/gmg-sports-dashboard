import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/order.dart';
import '../../data/repo/orders_repository.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repository;
  OrdersCubit(this._repository) : super(const OrdersState());

  Future<void> load() async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _repository.getOrders();
      emit(state.copyWith(status: OrdersStatus.success, orders: orders));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateStatus(Order order, OrderStatus status) async {
    await _repository.updateStatus(order.id, status);
    await load();
  }
}
