import 'package:flutter/material.dart';

import 'SubViews.dart';

class SettingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: ListView(
        children: const [KeyView(), Divider(), TradeParamsView(), Divider(), CardView(), Divider(), InfosOverView()],
      ),
    );
  }
}
