import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/governorate.dart';

class ShippingRepository {
  final SupabaseClient _client;
  ShippingRepository(this._client);

  Future<List<Governorate>> getAll() async {
    final rows = await _client
        .from('governorates')
        .select()
        .order('name', ascending: true);
    return (rows as List)
        .map((e) => Governorate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(Governorate g) async {
    if (g.id.isEmpty) {
      await _client.from('governorates').insert(g.toJson());
    } else {
      await _client
          .from('governorates')
          .update(g.toJson())
          .eq('id', g.id);
    }
  }

  Future<void> delete(String id) async {
    await _client.from('governorates').delete().eq('id', id);
  }

  Future<void> setActive(String id, bool active) async {
    await _client
        .from('governorates')
        .update({'is_active': active})
        .eq('id', id);
  }
}
