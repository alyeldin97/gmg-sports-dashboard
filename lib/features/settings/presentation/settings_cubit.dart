import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/app_settings.dart';
import '../data/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;
  SettingsCubit(this._repository) : super(const SettingsState());

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final settings = await _repository.getSettings();
      emit(state.copyWith(status: SettingsStatus.success, settings: settings));
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> save(AppSettings settings) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    try {
      await _repository.updateSettings(settings);
      emit(state.copyWith(status: SettingsStatus.saved, settings: settings));
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }
}
