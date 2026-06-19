import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/order.dart';
import '../../data/repo/orders_repository.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _repository;
  StreamSubscription<List<Order>>? _sub;

  OrdersCubit(this._repository) : super(const OrdersState());

  void startRealtime() {
    emit(state.copyWith(status: OrdersStatus.loading));
    _sub?.cancel();
    _sub = _repository.watchOrders().listen(
      (orders) => emit(state.copyWith(status: OrdersStatus.success, orders: orders)),
      onError: (e) => emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString())),
    );
  }

  // Fallback one-shot load (called after updateStatus so the stream catches up immediately)
  Future<void> load() async {
    try {
      final orders = await _repository.getOrders();
      emit(state.copyWith(status: OrdersStatus.success, orders: orders));
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> updateStatus(Order order, OrderStatus status) async {
    try {
      await _repository.updateStatus(order.id, status);
      // Stream will auto-update; also do a manual fetch for faster UI response
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: OrdersStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
