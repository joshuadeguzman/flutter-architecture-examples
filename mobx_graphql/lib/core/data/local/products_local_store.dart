import '../api/hive_db.dart';
import '../models/product_model.dart';

abstract class ProductLocalStore {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> cacheProducts(List<void> products);
}

class LiveProductsLocalStore extends ProductLocalStore {
  final HiveDb hiveDb;

  LiveProductsLocalStore({
    required this.hiveDb,
  });

  @override
  Future<List<ProductModel>> getProducts() {
    // TODO: implement getProducts
    throw UnimplementedError();
  }

  @override
  Future<List<ProductModel>> cacheProducts(List<void> products) {
    // TODO: implement cacheProducts
    throw UnimplementedError();
  }
}
