import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showToast(String msg) {
  final state = appScaffoldMessengerKey.currentState;
  if (state == null) return;
  state
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(msg, textAlign: TextAlign.center),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
}
