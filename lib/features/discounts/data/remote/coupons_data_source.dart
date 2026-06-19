import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/coupon.dart';

class CouponsDataSource {
  final SupabaseClient _client;
  CouponsDataSource(this._client);

  Future<List<Coupon>> getAll() async {
    final rows = await _client
        .from('coupons')
        .select()
        .order('created_at', ascending: false);
    return (rows as List).map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(Coupon coupon) async {
    if (coupon.id.isEmpty) {
      await _client.from('coupons').insert(coupon.toJson());
    } else {
      await _client.from('coupons').update(coupon.toJson()).eq('id', coupon.id);
    }
  }

  Future<void> delete(String id) => _client.from('coupons').delete().eq('id', id);

  Future<void> setActive(String id, bool active) =>
      _client.from('coupons').update({'is_active': active}).eq('id', id);
}
