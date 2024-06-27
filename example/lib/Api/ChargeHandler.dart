import 'dart:convert';
import 'dart:io';

import 'package:elepay_flutter/elepay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Help/Help.dart';
import '../Models/Configs.dart';
import 'PayHandler.dart';

extension PayHandlerCharge on PayHandler {
  Future<void> handleCharge(int amount, String finance, String payment,
      {bool source = false, String customerId = "", String sourceId = ""}) async {
    if (source && (customerId.isEmpty || sourceId.isEmpty)) {
      Fluttertoast.showToast(msg: "Go to setting to prepare Infos.", gravity: ToastGravity.CENTER);
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
        Fluttertoast.showToast(msg: "Charge Succeed<${res.paymentId}>.", gravity: ToastGravity.CENTER);
      } else if (res is ElepayResultFailed) {
        var toast = "${res.paymentId},code=${res.code},reason=${res.reason},message=${res.message}";
        Fluttertoast.showToast(msg: "Checkout Failed<$toast>.", gravity: ToastGravity.CENTER);
      } else if (res is ElepayResultCancelled) {
        Fluttertoast.showToast(msg: "Charge Canceled<${res.paymentId}>.", gravity: ToastGravity.CENTER);
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Charge error<${error.toString()}>.", gravity: ToastGravity.CENTER);
    });
  }
}
