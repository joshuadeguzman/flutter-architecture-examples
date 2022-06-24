import 'package:flutter/material.dart';

import '../presentation/products_store.dart';
import '../widgets/product_item.dart';

class ProductsPage extends StatefulWidget {
  final ProductsStore productsStore;

  const ProductsPage({
    super.key,
    required this.productsStore,
  });

  @override
  State<StatefulWidget> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  ProductsStore get store => widget.productsStore;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, i) {
        if (store.products.isNotEmpty) {
          return ProductItem(
            model: store.products[i],
          );
        }

        return const Text('No items found');
      },
      itemCount: store.products.length,
    );
  }
}
