import 'package:example_mobx/core/data/api/backend_api.dart';
import 'package:example_mobx/core/data/api/hive_db.dart';
import 'package:example_mobx/core/data/remote/products_remote_store.dart';
import 'package:example_mobx/products/presentation/products_store.dart';
import 'package:example_mobx/products/views/products_page.dart';
import 'package:flutter/material.dart';

import 'core/data/api/firebase_api.dart';
import 'core/data/local/products_local_store.dart';
import 'core/domain/repositories/products_repository.dart';

void main() {
  final firebaseApi = FirebaseApi();
  final backendApi = BackendApiV1();
  final hiveDb = HiveDb();
  final productsRemoteStore = LiveProductRemoteStore(
    backendApi: backendApi,
    firebaseApi: firebaseApi,
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
