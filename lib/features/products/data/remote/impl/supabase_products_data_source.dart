import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/product.dart';
import '../products_data_source.dart';

class SupabaseProductsDataSource implements ProductsDataSource {
  final SupabaseClient _client;
  SupabaseProductsDataSource(this._client);

  static const _select = '*, product_variants(*), product_collections(collection_id)';

  @override
  Future<List<Product>> getProducts() async {
    final rows = await _client.from('products').select(_select).order('created_at', ascending: false);
    return (rows as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveProduct(Product product) async {
    final saved = await _client.from('products').upsert(product.toUpsertJson()).select('id').single();
    final productId = saved['id'] as String;

    // Sync collection links: clear then re-insert.
    await _client.from('product_collections').delete().eq('product_id', productId);
    if (product.collectionIds.isNotEmpty) {
      await _client.from('product_collections').insert(
            product.collectionIds.map((c) => {'product_id': productId, 'collection_id': c}).toList(),
          );
    }

    // Sync variants: delete removed, upsert the rest.
    final existing = await _client.from('product_variants').select('id').eq('product_id', productId);
    final existingIds = (existing as List).map((e) => e['id'] as String).toSet();
    final keptIds = product.variants.where((v) => v.id.isNotEmpty).map((v) => v.id).toSet();
    final toDelete = existingIds.difference(keptIds);
    for (final id in toDelete) {
      await _client.from('product_variants').delete().eq('id', id);
    }
    if (product.variants.isNotEmpty) {
      var order = 0;
      final rows = product.variants.map((v) => v.toUpsertJson(productId, order++)).toList();
      await _client.from('product_variants').upsert(rows);
    }
  }

  @override
  Future<void> deleteProduct(String id) => _client.from('products').delete().eq('id', id);

  @override
  Future<void> setActive(String id, bool isActive) =>
      _client.from('products').update({'is_active': isActive}).eq('id', id);
}
