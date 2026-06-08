import '../model/order.dart';
import '../remote/orders_data_source.dart';

class OrdersRepository {
  final OrdersDataSource _dataSource;
  OrdersRepository(this._dataSource);

  Future<List<Order>> getOrders() => _dataSource.getOrders();
  Future<Order> getOrderById(String id) => _dataSource.getOrderById(id);
  Future<void> updateStatus(String id, OrderStatus status) => _dataSource.updateStatus(id, status);
}
