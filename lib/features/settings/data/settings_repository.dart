import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_settings.dart';

class SettingsRepository {
  final SupabaseClient _client;
  SettingsRepository(this._client);

  Future<AppSettings> getSettings() async {
    try {
      final row = await _client.from('app_settings').select().eq('id', 1).single();
      return AppSettings.fromJson(row);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> updateSettings(AppSettings settings) =>
      _client.from('app_settings').update(settings.toUpdateJson()).eq('id', 1);
}
