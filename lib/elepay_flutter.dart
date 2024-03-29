library elepay_flutter;

import 'dart:async';

import 'package:flutter/services.dart';

part 'elepay_config.dart';
part 'elepay_result.dart';

/// elepay SDK wrapper class
class ElepayFlutter {
  static const MethodChannel _channel = const MethodChannel('elepay_flutter');

  /// Initialize elepay SDK.
  ///
  /// This method should be called before invoking any other elepay API.
  /// See [ElepayConfiguration] for more details about the required data for initialization.
  static Future<void> initElepay(ElepayConfiguration configuration) async {
    await _channel.invokeMethod("initElepay", configuration.asMap);
  }

  /// Change the language used by elepay SDK UI.
  ///
  /// Only supported [ELepayLanguageKey] could be used. By default, elepay SDK uses your system's
  /// language setting. If the system language setting is not supported by elepay SDK, elepay SDK
  /// will fallback to English.
  ///
  /// Note that this method must be called *after* elepay SDK is initialized and *before* the
  /// payment processing.
  static Future<void> changeLanguage(ElepayLanguageKey languageKey) async {
    await _channel.invokeMethod(
        "changeLanguage", {"languageKey": languageKey.stringPresentation});
  }

  /// Change the theme of elepay SDK UI.
  ///
  /// Note:
  /// 1. This method must be called *after* elepay SDK is initialized and *before* the
  /// payment processing.
  /// 2. iOS only supports this method on iOS 13 and above.
  static Future<void> changeTheme(ElepayTheme theme) async {
    await _channel
        .invokeMethod("changeTheme", {"theme": theme.stringPresentation});
  }

  /// Handle the charge payment data.
  ///
  /// [payload] is supposed to be the JSON object content that you created by invoking elepay's
  /// creating charge API.
  /// An instance of [ElepayResult] will be returned to indicate the processing result.
  /// Refere to [ElepayResult] for more details.
  static Future<ElepayResult> handleCharge(String payload) async {
    var params = {"payload": payload};
    var sdkResult = await _channel.invokeMethod("handleCharge", params);
    sdkResult = Map<String, dynamic>.from(sdkResult);

    return _processSdkResult(sdkResult);
  }

  /// Handle the source data.
  ///
  /// [payload] is supposed to be the JSON object content that you created by invoking elepay's
  /// creating source API.
  /// An instance of [ElepayResult] will be returned to indicate the processing result.
  /// Refere to [ElepayResult] for more details.
  static Future<ElepayResult> handleSource(String payload) async {
    var params = {"payload": payload};
    var sdkResult = await _channel.invokeMethod("handleSource", params);
    sdkResult = Map<String, dynamic>.from(sdkResult);

    return _processSdkResult(sdkResult);
  }

  /// Handle the checkout code data.
  ///
  /// [payload] is supposed to be the JSON object content that you created by invoking elepay's
  /// creating code API.
  /// An instance of [ElepayResult] will be returned to indicate the processing result.
  /// Refere to [ElepayResult] for more details.
  static Future<ElepayResult> checkout(String payload) async {
    var params = {"payload": payload};
    var sdkResult = await _channel.invokeMethod("checkout", params);
    sdkResult = Map<String, dynamic>.from(sdkResult);

    return _processSdkResult(sdkResult);
  }

  static ElepayResult _processSdkResult(Map<String, dynamic> sdkResult) {
    String state = sdkResult["state"];
    String paymentId = sdkResult["paymentId"];

    ElepayResult? res;
    if (state == "succeeded") {
      res = ElepayResult.succeeded(paymentId);
    } else if (state == "cancelled") {
      res = ElepayResult.cancelled(paymentId);
    } else if (state == "failed") {
      Map<String, dynamic> err = Map<String, dynamic>.from(sdkResult["error"]);
      res = ElepayResult.failed(
          paymentId, err["code"], err["reason"], err["message"]);
    }

    return res!;
  }
}
