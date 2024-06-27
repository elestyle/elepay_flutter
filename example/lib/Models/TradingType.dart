import 'package:elepay_flutter_example/Help/KVMap.dart';
import 'package:flutter/cupertino.dart';

enum TradingType {
  Charge,
  Source,
  Checkout,
}

extension TradingTypeInfo on TradingType {
  static List<String> get allItems {
    return TradingType.values.map((type) => type.name).toList();
  }

  static TradingType parseType(String? input) {
    for (TradingType type in TradingType.values) {
      if (type.toString().split('.').last == input) {
        return type;
      }
    }
    return TradingType.Charge;
  }
}

class TradingProvider with ChangeNotifier {
  TradingType _current = TradingTypeInfo.parseType(KVMap.get(KV_KEY_trading));

  void setCurrent(TradingType type) {
    _current = type;
    KVMap.set(KV_KEY_trading, type.name);
    notifyListeners();
  }

  TradingType get current => _current;
}
