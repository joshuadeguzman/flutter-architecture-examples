import 'package:example_mobx/core/data/api/backend_api.dart';

import '../api/firebase_api.dart';

abstract class ProductsRemoteStore {
  Future<List<void>> getProducts();
  Future<void> buyProduct(String productId);
}

class LiveProductRemoteStore extends ProductsRemoteStore {
  final BackendApi backendApi;
  final FirebaseApi firebaseApi;

  LiveProductRemoteStore({
    required this.backendApi,
    required this.firebaseApi,
  });
  @override
  Future<List<void>> getProducts() {
    // TODO: implement getProducts
    throw UnimplementedError();
  }

  @override
  Future<void> buyProduct(String productId) {
    // TODO: implement buyProduct
    throw UnimplementedError();
  }
}
