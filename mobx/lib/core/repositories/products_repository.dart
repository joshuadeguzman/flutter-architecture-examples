import '../data/local/products_local_store.dart';
import '../data/remote/products_remote_store.dart';

abstract class ProductsRepository {
  Future<void> getProducts();
  Future<List<void>> getProductsFromRemote();
  Future<List<void>> getProductsFromLocal();
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
  Future<List<void>> getProducts() async {
    final local = await localStore.getProducts();
    if (local.isNotEmpty) {
      return local;
    } else {
      final remote = await remoteStore.getProducts();
      return localStore.cacheProducts(remote);
    }
  }

  @override
  Future<List<void>> getProductsFromLocal() async {
    return await localStore.getProducts();
  }

  @override
  Future<List<void>> getProductsFromRemote() async {
    return await remoteStore.getProducts();
  }
}
