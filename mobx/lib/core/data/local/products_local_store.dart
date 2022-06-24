abstract class ProductLocalStore {
  Future<List<void>> getProducts();
  Future<List<void>> cacheProducts(List<void> products);
}

class LiveProductsLocalStore extends ProductLocalStore {
  @override
  Future<List<void>> getProducts() {
    // TODO: implement getProducts
    throw UnimplementedError();
  }

  @override
  Future<List<void>> cacheProducts(List<void> products) {
    // TODO: implement cacheProducts
    throw UnimplementedError();
  }
}
