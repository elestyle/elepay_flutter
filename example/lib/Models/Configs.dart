import 'package:elepay_flutter_example/Help/KVMap.dart';
import 'package:flutter/material.dart';

class ConfigsProvider with ChangeNotifier {
  static ConfigsProvider? _instance;

  static ConfigsProvider load() {
    _instance ??= ConfigsProvider._(
      pubKey: KVMap.get(KV_KEY_pubKey) ?? "",
      secKey: KVMap.get(KV_KEY_secKey) ?? "",
    );
    return _instance!;
  }

  static const String host = "https://api.elepay.io";
  static const String charge = "$host/charges";
  static const String customers = "$host/customers";
  static const String checkout = "$host/codes";
  static String source(String customerId) {
    return "$customers/$customerId/sources";
  }

  String _pubKey = KVMap.get(KV_KEY_pubKey) ?? "";
  String _secKey = KVMap.get(KV_KEY_secKey) ?? "";

  ConfigsProvider._({
    required String pubKey,
    required String secKey,
  })  : _pubKey = pubKey,
        _secKey = secKey;

  set pubKey(String newValue) {
    _pubKey = newValue;
    KVMap.set(KV_KEY_pubKey, newValue);
    notifyListeners();
  }

  String get pubKey => _pubKey;

  set secKey(String newValue) {
    _secKey = newValue;
    KVMap.set(KV_KEY_secKey, newValue);
    notifyListeners();
  }

  String get secKey => _secKey;
}
