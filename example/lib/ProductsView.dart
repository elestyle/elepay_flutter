import 'package:elepay_flutter_example/Models/Configs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'Models/Products.dart';
import 'PaymentView.dart';
import 'ProductCell.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    var productsProvider = Provider.of<ProductsProvider>(context);
    var configsProvider = Provider.of<ConfigsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              if (configsProvider.pubKey.isEmpty || configsProvider.secKey.isEmpty) {
                Fluttertoast.showToast(msg: "Go to setting to set keys.", gravity: ToastGravity.CENTER);
                return;
              }
              if (productsProvider.count <= 0) {
                Fluttertoast.showToast(msg: "Select the product first.", gravity: ToastGravity.CENTER);
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentView()));
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0 / 1.2,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: List.generate(productsProvider.products.length, (index) {
          return ProductCell(product: productsProvider.products[index], index: index);
        }),
      ),
    );
  }
}
