import '../model/product.dart';
import '../remote/products_data_source.dart';

class ProductsRepository {
  final ProductsDataSource _dataSource;
  ProductsRepository(this._dataSource);

  Future<List<Product>> getProducts() => _dataSource.getProducts();
  Future<void> saveProduct(Product product) => _dataSource.saveProduct(product);
  Future<void> deleteProduct(String id) => _dataSource.deleteProduct(id);
  Future<void> setActive(String id, bool isActive) => _dataSource.setActive(id, isActive);
}
