import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:mobx_graphql/products/presentation/products_store.dart';
import 'package:mobx_graphql/products/views/products_page.dart';

import 'core/data/api/hive_db.dart';
import 'core/data/local/products_local_store.dart';
import 'core/data/remote/products_remote_store.dart';
import 'core/domain/repositories/products_repository.dart';

void main() {
  final httpLink = HttpLink(
    'https://example.com/graphql',
  );

  final graphQlClient = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  );
  final hiveDb = HiveDb();
  final productsRemoteStore = LiveProductRemoteStore(
    graphQlClient,
  );
  final productsLocalStore = LiveProductsLocalStore(
    hiveDb: hiveDb,
  );
  final productsRepository = LiveProductsRepository(
    remoteStore: productsRemoteStore,
    localStore: productsLocalStore,
  );
  final productsStore = ProductsStore(
    productsRepository: productsRepository,
  );

  runApp(MyApp(
    productsStore: productsStore,
  ));
}

class MyApp extends StatelessWidget {
  final ProductsStore productsStore;

  const MyApp({
    super.key,
    required this.productsStore,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobx',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductsPage(
        productsStore: productsStore,
      ),
    );
  }
}
