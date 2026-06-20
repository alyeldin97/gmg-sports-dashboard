import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/product.dart';
import '../../data/repo/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository _repository;
  ProductsCubit(this._repository) : super(const ProductsState());

  Future<void> load() async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await _repository.getProducts();
      emit(state.copyWith(status: ProductsStatus.success, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<bool> save(Product product) async {
    emit(state.copyWith(status: ProductsStatus.saving));
    try {
      await _repository.saveProduct(product);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.deleteProduct(id);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> toggleActive(Product p) async {
    try {
      await _repository.setActive(p.id, !p.isActive);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> bulkDelete(List<String> ids) async {
    try {
      for (final id in ids) {
        await _repository.deleteProduct(id);
      }
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> duplicate(Product product) async {
    try {
      final newProduct = Product(
        id: '',
        name: '${product.name} (Copy)',
        nameAr: product.nameAr != null ? '${product.nameAr} (نسخة)' : null,
        description: product.description,
        descriptionAr: product.descriptionAr,
        price: product.price,
        compareAtPrice: product.compareAtPrice,
        images: product.images,
        stock: product.stock,
        isActive: false,
        isFeatured: false,
        collectionIds: product.collectionIds,
        variants: [],
      );
      await _repository.saveProduct(newProduct);
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }

  /// Updates the in-memory stock for [productId] after a stock adjustment so
  /// the list reflects the new value without a full reload.
  void updateStock(String productId, int newStock) {
    final updated = state.products
        .map((p) => p.id == productId ? p.copyWith(stock: newStock) : p)
        .toList();
    emit(state.copyWith(products: updated));
  }

  Future<bool> bulkToggleActive(List<String> ids, bool active) async {
    try {
      for (final id in ids) {
        await _repository.setActive(id, active);
      }
      await load();
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
      return false;
    }
  }
}
