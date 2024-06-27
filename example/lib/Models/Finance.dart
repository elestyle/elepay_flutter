import 'package:elepay_flutter_example/Help/KVMap.dart';
import 'package:flutter/material.dart';

enum FinanceType { USD, AUD, BRL, GBP, CAD, CNY, EUR, HKD, INR, JPY, KRW, PLN, SEK, CHF }

extension FinanceTypeInfo on FinanceType {
  static List<String> get allItems {
    return FinanceType.values.map((type) => type.name).toList();
  }

  static FinanceType parseType(String? input) {
    for (FinanceType type in FinanceType.values) {
      if (type.toString().split('.').last == input) {
        return type;
      }
    }
    return FinanceType.JPY;
  }

  static final Map<FinanceType, Map<String, dynamic>> _details = {
    FinanceType.USD: {'name': 'USD', 'symbol': '\$', 'rate': 1.0000},
    FinanceType.AUD: {'name': 'AUD', 'symbol': 'A\$', 'rate': 0.6902},
    FinanceType.BRL: {'name': 'BRL', 'symbol': 'R\$', 'rate': 0.2050},
    FinanceType.GBP: {'name': 'GBP', 'symbol': '£', 'rate': 1.2296},
    FinanceType.CAD: {'name': 'CAD', 'symbol': 'C\$', 'rate': 0.7374},
    FinanceType.CNY: {'name': 'CNY', 'symbol': '¥', 'rate': 0.1408},
    FinanceType.EUR: {'name': 'EUR', 'symbol': '€', 'rate': 1.0557},
    FinanceType.HKD: {'name': 'HKD', 'symbol': 'HK\$', 'rate': 0.1279},
    FinanceType.INR: {'name': 'INR', 'symbol': '₹', 'rate': 0.0122},
    FinanceType.JPY: {'name': 'JPY', 'symbol': '¥', 'rate': 0.0073},
    FinanceType.KRW: {'name': 'KRW', 'symbol': '₩', 'rate': 0.00077},
    FinanceType.PLN: {'name': 'PLN', 'symbol': 'zł', 'rate': 0.2417},
    FinanceType.SEK: {'name': 'SEK', 'symbol': 'kr', 'rate': 0.0953},
    FinanceType.CHF: {'name': 'CHF', 'symbol': 'CHF', 'rate': 1.0697}
  };

  String get name => _details[this]!['name'];
  String get symbol => _details[this]!['symbol'];
  double get rate => _details[this]!['rate'];
}

class FinanceProvider with ChangeNotifier {
  FinanceType _current = FinanceTypeInfo.parseType(KVMap.get(KV_KEY_finance));

  void setCurrent(FinanceType type) {
    _current = type;
    KVMap.set(KV_KEY_finance, type.name);
    notifyListeners();
  }

  FinanceType get current => _current;

  String display(List<double> prices) {
    return '${_current.name} ${_current.symbol}${amount(prices)}';
  }

  int amount(List<double> prices) {
    var total = prices.fold(0.0, (sum, price) => sum + price / _current.rate);
    return total.toInt();
  }
}
