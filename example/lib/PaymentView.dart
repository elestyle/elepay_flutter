import 'package:elepay_flutter_example/Api/ChargeHandler.dart';
import 'package:elepay_flutter_example/Api/CheckoutHandler.dart';
import 'package:elepay_flutter_example/Api/PayHandler.dart';
import 'package:elepay_flutter_example/Models/Information.dart';
import 'package:elepay_flutter_example/Models/Payments.dart';
import 'package:elepay_flutter_example/Models/TradingType.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Models/Finance.dart';
import 'Models/Products.dart';
import 'SubViews.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    var productsProvider = Provider.of<ProductsProvider>(context);
    var financeProvider = Provider.of<FinanceProvider>(context);
    var tradingProvider = Provider.of<TradingProvider>(context);
    var paymentsProvider = Provider.of<PaymentsProvider>(context);
    var infosProvider = Provider.of<InfosProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Infos')),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                for (var item in productsProvider.selected)
                  ListTile(
                    leading: Text(item.emoji, style: const TextStyle(fontSize: 40)),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(financeProvider.display([item.price])),
                  ),
                const Divider(color: Colors.black12),
                ListTile(
                  title: const Text('Total', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    financeProvider.display(productsProvider.selected.map((e) => e.price).toList()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // handle payment
                    switch (tradingProvider.current) {
                      case TradingType.Charge:
                        PayHandler.instance.handleCharge(
                            financeProvider.amount(productsProvider.selected.map((e) => e.price).toList()),
                            financeProvider.current.name,
                            paymentsProvider.current.name);
                        break;
                      case TradingType.Source:
                        PayHandler.instance.handleCharge(
                          financeProvider.amount(productsProvider.selected.map((e) => e.price).toList()),
                          financeProvider.current.name,
                          paymentsProvider.current.name,
                          source: true,
                          customerId: infosProvider.customerId,
                          sourceId: infosProvider.sourceId,
                        );
                        break;
                      case TradingType.Checkout:
                        List<Map<String, dynamic>> productsConv = productsProvider.selected.map((product) {
                          return {
                            "name": product.name,
                            "image": product.img,
                            "price": financeProvider.amount([product.price]),
                            "count": 1,
                          };
                        }).toList();

                        PayHandler.instance.handleCheckout(
                            financeProvider.amount(productsProvider.selected.map((e) => e.price).toList()),
                            financeProvider.current.name,
                            productsConv);
                        break;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // match_parent width
                  ),
                  child: const Text('-> Go to Pay'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const TradeParamsView(),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
