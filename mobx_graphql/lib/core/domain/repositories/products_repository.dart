import '../../data/local/products_local_store.dart';
import '../../data/models/product_model.dart';
import '../../data/remote/products_remote_store.dart';

abstract class ProductsRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProductsFromRemote();
  Future<List<ProductModel>> getProductsFromLocal();
  Future<void> buyProduct(String productId);
}

class LiveProductsRepository extends ProductsRepository {
  final ProductsRemoteStore remoteStore;
  final ProductLocalStore localStore;

  LiveProductsRepository({
    required this.remoteStore,
    required this.localStore,
  });

  @override
  Future<void> buyProduct(String productId) async {
    return remoteStore.buyProduct(productId);
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final local = await localStore.getProducts();
    if (local.isNotEmpty) {
      return local;
    } else {
      final remote = await remoteStore.getProducts();
      return localStore.cacheProducts(remote);
    }
  }

  @override
  Future<List<ProductModel>> getProductsFromLocal() async {
    return await localStore.getProducts();
  }

  @override
  Future<List<ProductModel>> getProductsFromRemote() async {
    return await remoteStore.getProducts();
  }
}
