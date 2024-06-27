import 'package:elepay_flutter_example/Help/KVMap.dart';
import 'package:flutter/cupertino.dart';

enum Payments {
  aeonpay, // AEON Pay
  alipay, // アリペイ
  alipayhk, // アリペイHK
  alipayplus, // Alipay+
  amazonpay, // Amazon Pay
  applepay, // Apple Pay
  applepay_cn, // Apple Pay(中国)
  atone, // atone(コンビニで翌月払い)
  aupay, // au Pay
  bpi, // BPI
  boost, // Boost
  creditcard, // クレジットカード
  dana, // DANA
  docomopay, // d払い
  ezlink, // EZ-Link
  felica, // 電子マネー
  felica_id, // iD
  felica_quickpay, // QUICPay
  felica_transport_ic, // 交通系ICカード
  gcash, // GCash
  ginkopay, // 銀行Pay
  googlepay, // Google Pay
  hellomoney, // HelloMoney by AUB
  jcoinpay, // J-Coin Pay
  jkopay, // JKOPAY
  kakaopay, // Kakao Pay
  linepay, // LINE Pay
  merpay, // メルペイ
  naverpay, // Naver Pay
  origamipay, // Origami Pay
  paidy, // Paidy 翌月払い
  paypal, // PayPal
  paypay, // PayPay
  rabbitlinepay, // Rabbit LINE Pay
  rakutenpay, // 楽天ペイ
  tng, // Touch 'n Go eWallet
  tosspay, // Toss Pay
  truemoney, // TrueWorld
  unionpay, // 雲閃付
  wechatpay, // Wechat Pay
}

extension PaymentsInfo on Payments {
  static List<String> get allItems {
    return Payments.values.map((type) => type.name).toList();
  }

  static Payments parseType(String? input) {
    for (Payments type in Payments.values) {
      if (type.toString().split('.').last == input) {
        return type;
      }
    }
    return Payments.linepay;
  }
}

class PaymentsProvider with ChangeNotifier {
  Payments _current = PaymentsInfo.parseType(KVMap.get(KV_KEY_payment));

  void setCurrent(Payments type) {
    _current = type;
    KVMap.set(KV_KEY_payment, type.name);
    notifyListeners();
  }

  Payments get current => _current;
}
