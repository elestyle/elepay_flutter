import 'dart:convert';

import 'package:elepay_flutter/elepay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        Fluttertoast.showToast(msg: "Checkout Succeed<${res.paymentId}>.", gravity: ToastGravity.CENTER);
      } else if (res is ElepayResultFailed) {
        var toast = "${res.paymentId},code=${res.code},reason=${res.reason},message=${res.message}";
        Fluttertoast.showToast(msg: "Checkout Failed<$toast>.", gravity: ToastGravity.CENTER);
      } else if (res is ElepayResultCancelled) {
        Fluttertoast.showToast(msg: "Checkout Canceled<${res.paymentId}>.", gravity: ToastGravity.CENTER);
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Checkout error<${error.toString()}>.", gravity: ToastGravity.CENTER);
    });
  }
}
