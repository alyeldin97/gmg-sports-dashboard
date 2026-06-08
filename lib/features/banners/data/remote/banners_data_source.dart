import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/banner_item.dart';

class BannersDataSource {
  final SupabaseClient _client;
  BannersDataSource(this._client);

  Future<List<BannerItem>> getBanners() async {
    final rows = await _client.from('banners').select().order('sort_order');
    return (rows as List).map((e) => BannerItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBanner(BannerItem b) => _client.from('banners').upsert(b.toUpsertJson());

  Future<void> deleteBanner(String id) => _client.from('banners').delete().eq('id', id);
}
