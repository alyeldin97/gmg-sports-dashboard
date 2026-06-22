import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/order.dart';

class OrdersDataSource {
  final SupabaseClient _client;
  OrdersDataSource(this._client);

  static const _select = '*, order_items(*)';
  // Detail select joins products so we can show product images
  static const _detailSelect = '*, order_items(*, products(id, images))';

  Stream<List<Order>> watchOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((e) => Order.fromJson(e)).toList());
  }

  Future<List<Order>> getOrders() async {
    final rows = await _client.from('orders').select(_select).order('created_at', ascending: false);
    return (rows as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrderById(String id) async {
    final row = await _client.from('orders').select(_detailSelect).eq('id', id).single();
    return Order.fromJson(row);
  }

  Future<void> updateStatus(String id, OrderStatus status) =>
      _client.from('orders').update({'status': status.dbValue}).eq('id', id);
}
