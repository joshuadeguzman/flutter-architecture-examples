import 'package:mobx/mobx.dart';

import '../../core/data/models/product_model.dart';
import '../../core/domain/repositories/products_repository.dart';

part 'products_store.g.dart';

class ProductsStore = ProductsStoreBase with _$ProductsStore;

abstract class ProductsStoreBase with Store {
  final LiveProductsRepository productsRepository;

  @observable
  List<ProductModel> products = [];

  ProductsStoreBase({
    required this.productsRepository,
  });

  @action
  Future<void> getProducts() async {
    final products = await productsRepository.getProducts();
    this.products = products.toList();
  }
}
