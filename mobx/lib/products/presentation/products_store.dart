import 'package:mobx/mobx.dart';

import '../../core/repositories/products_repository.dart';

part 'products_store.g.dart';

class ProductsStore = ProductsStoreBase with _$ProductsStore;

abstract class ProductsStoreBase with Store {
  final LiveProductsRepository productsRepository;

  @observable
  List<void> products = [];

  ProductsStoreBase({
    required this.productsRepository,
  });

  @action
  void getProducts() {}
}
