import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/coupon.dart';
import '../../data/repo/coupons_repository.dart';

part 'coupons_state.dart';

class CouponsCubit extends Cubit<CouponsState> {
  final CouponsRepository _repository;
  CouponsCubit(this._repository) : super(const CouponsState());

  Future<void> load() async {
    emit(state.copyWith(status: CouponsStatus.loading));
    try {
      final coupons = await _repository.getAll();
      emit(state.copyWith(status: CouponsStatus.success, coupons: coupons));
    } catch (e) {
      emit(state.copyWith(status: CouponsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> save(Coupon coupon) async {
    try {
      await _repository.save(coupon);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: CouponsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: CouponsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> toggleActive(Coupon coupon) async {
    try {
      await _repository.setActive(coupon.id, !coupon.isActive);
      await load();
    } catch (e) {
      emit(state.copyWith(status: CouponsStatus.failure, errorMessage: e.toString()));
    }
  }
}
