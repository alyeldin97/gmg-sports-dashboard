import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/collection.dart';

class CollectionsDataSource {
  final SupabaseClient _client;
  CollectionsDataSource(this._client);

  Future<List<Collection>> getCollections() async {
    final rows = await _client.from('collections').select().order('sort_order');
    return (rows as List).map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCollection(Collection c) => _client.from('collections').upsert(c.toUpsertJson());

  Future<void> deleteCollection(String id) => _client.from('collections').delete().eq('id', id);
}
