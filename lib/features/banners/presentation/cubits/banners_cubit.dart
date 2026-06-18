import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/banner_item.dart';
import '../../data/repo/banners_repository.dart';

part 'banners_state.dart';

class BannersCubit extends Cubit<BannersState> {
  final BannersRepository _repository;
  BannersCubit(this._repository) : super(const BannersState());

  Future<void> load() async {
    emit(state.copyWith(status: BannersStatus.loading));
    try {
      final banners = await _repository.getBanners();
      emit(state.copyWith(status: BannersStatus.success, banners: banners));
    } catch (e) {
      emit(state.copyWith(status: BannersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> save(BannerItem b) async {
    try {
      await _repository.saveBanner(b);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: BannersStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.deleteBanner(id);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: BannersStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }
}
