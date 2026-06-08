part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, saving, saved, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final AppSettings settings;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const AppSettings(),
    this.errorMessage,
  });

  SettingsState copyWith({SettingsStatus? status, AppSettings? settings, String? errorMessage}) =>
      SettingsState(
        status: status ?? this.status,
        settings: settings ?? this.settings,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
