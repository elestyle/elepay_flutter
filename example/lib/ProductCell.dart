import 'package:elepay_flutter_example/Models/Finance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Models/Products.dart';

class ProductCell extends StatefulWidget {
  final Product product;
  final int index;
  const ProductCell({super.key, required this.product, required this.index});

  @override
  State<ProductCell> createState() => _ProductCellState();
}

class _ProductCellState extends State<ProductCell> {
  int refresh = 0;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductsProvider>(context);
    var finance = Provider.of<FinanceProvider>(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 1,
            child: AspectRatio(
              aspectRatio: 1 / 1, // 设置宽高比为 1:1
              child: Container(
                // 这是实际的 1:1 widget
                color: Colors.black12,
                child: Stack(
                  // alignment: AlignmentDirectional.center,
                  children: [
                    Positioned(
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              widget.product.emoji,
                              style: const TextStyle(fontSize: 100),
                            ))),
                    Positioned(
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  widget.product.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                )))),
                  ],
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 1,
            child: AspectRatio(
                aspectRatio: 1 / 0.2,
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(finance.display([widget.product.price]),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: provider.contains(widget.product)
                            ? const Icon(Icons.remove_circle_outline, color: Colors.red)
                            : const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: () {
                          provider.toggle(widget.product);
                          setState(() {
                            refresh++;
                          });
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
