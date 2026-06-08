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

  Future<void> delete(String id) async {
    await _repository.deleteProduct(id);
    await load();
  }

  Future<void> toggleActive(Product p) async {
    await _repository.setActive(p.id, !p.isActive);
    await load();
  }
}
