import 'dart:convert';
import 'dart:io';

import 'package:elepay_flutter/elepay_flutter.dart';
import 'package:elepay_flutter_example/Help/Toast.dart';

import '../Help/Help.dart';
import '../Models/Configs.dart';
import 'PayHandler.dart';

extension PayHandlerCharge on PayHandler {
  Future<void> handleCharge(int amount, String finance, String payment,
      {bool source = false, String customerId = "", String sourceId = ""}) async {
    if (source && (customerId.isEmpty || sourceId.isEmpty)) {
      showToast("Go to setting to prepare Infos.");
      return;
    }

    var params = {
      "capture": true,
      "currency": finance,
      "paymentMethod": payment,
      "amount": amount,
      "resource": Platform.isIOS ? "ios" : "android",
      "orderNo": RandomString.generateRandomChar(),
      "description": "example",
    };

    if (source) {
      params["customerId"] = customerId;
      params["sourceId"] = sourceId;
    }

    PayHandler.instance.net.requestJSON(ConfigsProvider.charge, params: params).then((result) async {
      print("test - result start ");
      var res = await ElepayFlutter.handleCharge(jsonEncode(result));

      print("test - result: $res");
      if (res is ElepayResultSucceeded) {
        showToast("Charge Succeed<${res.paymentId}>.");
      } else if (res is ElepayResultFailed) {
        var toast = "${res.paymentId},code=${res.code},reason=${res.reason},message=${res.message}";
        showToast("Checkout Failed<$toast>.");
      } else if (res is ElepayResultCancelled) {
        showToast("Charge Canceled<${res.paymentId}>.");
      }
    }).catchError((error) {
      showToast("Charge error<${error.toString()}>.");
    });
  }
}
