import 'package:flutter/material.dart';

import '../Help/KVMap.dart';

class CardProvider with ChangeNotifier {
  static CardProvider? _instance;

  static CardProvider load() {
    _instance ??= CardProvider._(
      number: KVMap.get(KV_KEY_cardNumber) ?? "",
      expYear: KVMap.get(KV_KEY_cardExpYear) ?? "",
      expMonth: KVMap.get(KV_KEY_cardExpMonth) ?? "",
      cvc: KVMap.get(KV_KEY_cardCVC) ?? "",
    );
    return _instance!;
  }

  CardProvider._({String number = '', String expYear = '', String expMonth = '', String cvc = ''})
      : _cvc = cvc,
        _expMonth = expMonth,
        _expYear = expYear,
        _number = number;

  String _number;
  String _expYear;
  String _expMonth;
  String _cvc;

  set number(String newValue) {
    _number = newValue;
    KVMap.set(KV_KEY_cardNumber, _number);
    notifyListeners();
  }

  String get number => _number;

  set expYear(String newValue) {
    _expYear = newValue;
    KVMap.set(KV_KEY_cardExpYear, _expYear);
    notifyListeners();
  }

  String get expYear => _expYear;

  set expMonth(String newValue) {
    _expMonth = newValue;
    KVMap.set(KV_KEY_cardExpMonth, _expMonth);
    notifyListeners();
  }

  String get expMonth => _expMonth;

  set cvc(String newValue) {
    _cvc = newValue;
    KVMap.set(KV_KEY_cardCVC, _cvc);
    notifyListeners();
  }

  String get cvc => _cvc;

  bool isEmpty() {
    return _number.isEmpty || _expYear.isEmpty || _expMonth.isEmpty || _cvc.isEmpty;
  }
}
