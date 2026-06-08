import '../model/product.dart';

abstract class ProductsDataSource {
  Future<List<Product>> getProducts();
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> setActive(String id, bool isActive);
}
