import 'package:example_mobx/core/data/api/backend_api.dart';
import 'package:example_mobx/core/data/models/product_model.dart';

import '../api/firebase_api.dart';

abstract class ProductsRemoteStore {
  Future<List<ProductModel>> getProducts();
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
  Future<List<ProductModel>> getProducts() {
    // TODO: implement getProducts
    throw UnimplementedError();
  }

  @override
  Future<void> buyProduct(String productId) {
    // TODO: implement buyProduct
    throw UnimplementedError();
  }
}
