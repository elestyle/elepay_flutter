import 'package:elepay_flutter_example/Help/KVMap.dart';

import 'Network.dart';

class PayHandler {
  static void setup() {
    PayHandler.instance;
  }

  static final PayHandler instance = PayHandler._internal();

  late final Network net;
  late final HeaderInterceptor interceptor;

  PayHandler._internal() {
    interceptor = HeaderInterceptor();
    net = Network(headerInterceptor: interceptor);
    _setup();
  }

  void _setup() {
    interceptor.headers.add(HTTPHeader.authorization(KVMap.get(KV_KEY_secKey) ?? ""));
  }
}
