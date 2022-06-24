import '../models/product_model.dart';
import 'package:graphql/client.dart';

abstract class ProductsRemoteStore {
  Future<List<ProductModel>> getProducts();
  Future<void> buyProduct(String productId);
}

class LiveProductRemoteStore extends ProductsRemoteStore {
  final GraphQLClient _client;

  LiveProductRemoteStore(
    this._client,
  );

  @override
  Future<List<ProductModel>> getProducts() async {
    const String query = r'''
      query getProducts() {
        id
        name
        description
      }
    ''';
    final queryOptions = QueryOptions(
      document: gql(query),
    );
    final response = _client..query(queryOptions);

    // TODO: implement getProducts
    throw UnimplementedError();
  }

  @override
  Future<void> buyProduct(String productId) {
    // TODO: implement buyProduct
    throw UnimplementedError();
  }
}
