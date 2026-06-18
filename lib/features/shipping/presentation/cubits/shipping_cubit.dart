import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/governorate.dart';
import '../../data/repo/shipping_repository.dart';

part 'shipping_state.dart';

class ShippingCubit extends Cubit<ShippingState> {
  final ShippingRepository _repository;
  ShippingCubit(this._repository) : super(const ShippingState());

  Future<void> load() async {
    emit(state.copyWith(status: ShippingStatus.loading));
    try {
      final govs = await _repository.getAll();
      emit(state.copyWith(status: ShippingStatus.success, governorates: govs));
    } catch (e) {
      emit(state.copyWith(status: ShippingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> save(Governorate g) async {
    try {
      await _repository.save(g);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ShippingStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ShippingStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> toggleActive(Governorate g) async {
    try {
      await _repository.setActive(g.id, !g.isActive);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ShippingStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }
}
