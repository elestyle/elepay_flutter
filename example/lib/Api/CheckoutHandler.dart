import 'dart:convert';

import 'package:elepay_flutter/elepay_flutter.dart';
import 'package:elepay_flutter_example/Help/Toast.dart';

import '../Help/Help.dart';
import '../Models/Configs.dart';
import 'PayHandler.dart';

extension PayHandlerCheckout on PayHandler {
  Future<void> handleCheckout(int amount, String finance, List<Map<String, dynamic>> products) async {
    Map<String, dynamic> params = {
      "currency": finance,
      "amount": amount,
      "orderNo": RandomString.generateRandomChar(),
      "description": "example",
      "items": products,
    };

    PayHandler.instance.net.requestJSON(ConfigsProvider.checkout, params: params).then((result) async {
      var res = await ElepayFlutter.checkout(jsonEncode(result));
      if (res is ElepayResultSucceeded) {
        showToast("Checkout Succeed<${res.paymentId}>.");
      } else if (res is ElepayResultFailed) {
        var toast = "${res.paymentId},code=${res.code},reason=${res.reason},message=${res.message}";
        showToast("Checkout Failed<$toast>.");
      } else if (res is ElepayResultCancelled) {
        showToast("Checkout Canceled<${res.paymentId}>.");
      }
    }).catchError((error) {
      showToast("Checkout error<${error.toString()}>.");
    });
  }
}
