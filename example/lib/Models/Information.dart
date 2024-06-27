import 'package:elepay_flutter_example/Help/KVMap.dart';
import 'package:flutter/material.dart';

class InfosProvider with ChangeNotifier {
  static InfosProvider? _instance;

  static InfosProvider load() {
    _instance ??= InfosProvider._(
      name: KVMap.get(KV_KEY_infosName) ?? "",
      email: KVMap.get(KV_KEY_infosEmail) ?? "",
      phone: KVMap.get(KV_KEY_infosPhone) ?? "",
      customerId: KVMap.get(KV_KEY_infosCustomerId) ?? "",
      sourceId: KVMap.get(KV_KEY_infosSourceId) ?? "",
    );
    return _instance!;
  }

  String _name;
  String _email;
  String _phone;
  String _customerId;
  String _sourceId;

  InfosProvider._({
    required String name,
    required String email,
    required String phone,
    required String customerId,
    required String sourceId,
  })  : _name = name,
        _email = email,
        _phone = phone,
        _customerId = customerId,
        _sourceId = sourceId;

  set name(String newValue) {
    _name = newValue;
    _saveToPrefs(KV_KEY_infosName, newValue);
    notifyListeners();
  }

  String get name => _name;

  set email(String newValue) {
    _email = newValue;
    _saveToPrefs(KV_KEY_infosEmail, newValue);
    notifyListeners();
  }

  String get email => _email;

  set phone(String newValue) {
    _phone = newValue;
    _saveToPrefs(KV_KEY_infosPhone, newValue);
    notifyListeners();
  }

  String get phone => _phone;

  set customerId(String newValue) {
    _customerId = newValue;
    _saveToPrefs(KV_KEY_infosCustomerId, newValue);
    notifyListeners();
  }

  String get customerId => _customerId;

  set sourceId(String newValue) {
    _sourceId = newValue;
    _saveToPrefs(KV_KEY_infosSourceId, newValue);
    notifyListeners();
  }

  String get sourceId => _sourceId;

  void _saveToPrefs(String key, String value) {
    KVMap.set(key, value);
  }

  bool get noInfos => _name.isEmpty || _email.isEmpty || _phone.isEmpty;

  bool get noSource => _customerId.isEmpty || _sourceId.isEmpty;
}
