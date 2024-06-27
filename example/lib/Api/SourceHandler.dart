import 'dart:convert';
import 'dart:io';

import 'package:elepay_flutter/elepay_flutter.dart';
import 'package:elepay_flutter_example/Models/Configs.dart';
import 'package:elepay_flutter_example/Models/Payments.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Network.dart';
import 'PayHandler.dart';

extension PayHandlerSource on PayHandler {
  void queryCustomer(Function(List<Map<String, dynamic>>) completion) {
    PayHandler.instance.net.requestJSON(ConfigsProvider.customers, method: HTTPMethod.GET).then((result) {
      List<Map<String, dynamic>> ret = [];
      if (result['customers'] is List) {
        ret = (result['customers'] as List)
            .where((element) => element is Map<String, dynamic>)
            .map((element) => element as Map<String, dynamic>)
            .toList();
      }

      completion(ret);
    }).catchError((_) {
      completion([]);
    });
  }

  void createCustomer(String name, String email, String phone, Function(String?) completion) {
    Map<String, dynamic> params = {'name': name, 'email': email, 'phone': phone};

    PayHandler.instance.net.requestJSON(ConfigsProvider.customers, params: params).then((result) {
      completion(result['id'] as String?);
    }).catchError((_) {
      completion(null);
    });
  }

  void updateCustomer(String name, String email, String phone, String customerId, Function(String?) completion) {
    Map<String, dynamic> params = {'name': name, 'email': email, 'phone': phone};

    PayHandler.instance.net.requestJSON("${ConfigsProvider.customers}/$customerId", params: params).then((result) {
      completion(result['id'] as String?);
    }).catchError((_) {
      completion(null);
    });
  }

  void querySource(String customerId, Function(List<Map<String, dynamic>>) completion) {
    PayHandler.instance.net.requestJSON(ConfigsProvider.source(customerId), method: HTTPMethod.GET).then((result) {
      List<Map<String, dynamic>> ret = [];
      if (result['sources'] is List) {
        ret = (result['sources'] as List)
            .where((element) => element is Map<String, dynamic>)
            .map((element) => element as Map<String, dynamic>)
            .toList();
      }
      completion(ret);
    }).catchError((error) {
      completion([]);
      Fluttertoast.showToast(msg: "Source error<${error.toString()}>.", gravity: ToastGravity.CENTER);
    });
  }

  void createSource(String customerId, Payments payment, Function(String?) completion) {
    Map<String, dynamic> params = {'paymentMethod': payment.name, 'resource': Platform.isIOS ? "ios" : "android"};

    PayHandler.instance.net.requestJSON(ConfigsProvider.source(customerId), params: params).then((result) async {
      String sourceId = result['id'] as String;

      if (sourceId.isEmpty) {
        Fluttertoast.showToast(msg: "Source error.", gravity: ToastGravity.CENTER);
        completion(null);
        return;
      }

      var res = await ElepayFlutter.handleSource(jsonEncode(result));
      if (res is ElepayResultSucceeded) {
        Fluttertoast.showToast(msg: "Source Succeed<${res.paymentId}>.", gravity: ToastGravity.CENTER);
      } else if (res is ElepayResultFailed) {
        var toast = "${res.paymentId},code=${res.code},reason=${res.reason},message=${res.message}";
        Fluttertoast.showToast(msg: "Checkout Failed<$toast>.", gravity: ToastGravity.CENTER);
      } else if (res is ElepayResultCancelled) {
        Fluttertoast.showToast(msg: "Source Canceled<${res.paymentId}>.", gravity: ToastGravity.CENTER);
      }
      completion(sourceId ?? "");
    }).catchError((error) {
      completion(null);
      Fluttertoast.showToast(msg: "Source error<${error.toString()}>.", gravity: ToastGravity.CENTER);
    });
  }
}
