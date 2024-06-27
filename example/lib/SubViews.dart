import 'dart:io';

import 'package:elepay_flutter_example/Models/Configs.dart';
import 'package:elepay_flutter_example/Models/Information.dart';
import 'package:elepay_flutter_example/Models/TradingType.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'InfosView.dart';
import 'Models/Card.dart';
import 'Models/Finance.dart';
import 'Models/Payments.dart';

class KeyView extends StatelessWidget {
  const KeyView({super.key});

  @override
  Widget build(BuildContext context) {
    var configsProvider = Provider.of<ConfigsProvider>(context);

    return Column(
      children: [
        const ListTile(
          title: Center(
            child: Text('KEYS *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
        ListTile(
          title: const Text('Public Key', style: TextStyle(color: Colors.red)),
          subtitle: TextFormField(
            initialValue: configsProvider.pubKey,
            style: const TextStyle(color: Colors.red),
            decoration: const InputDecoration(hintText: 'pk_live_xxx', hintStyle: TextStyle(color: Colors.red)),
            onChanged: (value) {
              configsProvider.pubKey = value;
            },
          ),
        ),
        ListTile(
          title: const Text('Secret Key', style: TextStyle(color: Colors.red)),
          subtitle: TextFormField(
            initialValue: configsProvider.secKey,
            style: const TextStyle(color: Colors.red),
            decoration: const InputDecoration(hintText: 'sk_live_xxx', hintStyle: TextStyle(color: Colors.red)),
            onChanged: (value) {
              configsProvider.secKey = value;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              exit(0);
            },
            child: const Text('Reboot to apply', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}

class TradeParamsView extends StatefulWidget {
  const TradeParamsView({super.key});

  @override
  State<TradeParamsView> createState() => _TradeParamsViewState();
}

class _TradeParamsViewState extends State<TradeParamsView> {
  int refresh = 0;

  @override
  Widget build(BuildContext context) {
    var financeProvider = Provider.of<FinanceProvider>(context);
    var tradingProvider = Provider.of<TradingProvider>(context);
    var paymentsProvider = Provider.of<PaymentsProvider>(context);

    return Column(
      children: [
        const ListTile(
          title: Center(child: Text('TRADE PARAMS')),
        ),
        ListTile(
          title: const Text('Currency (now support JPY)'),
          subtitle: DropdownButton<String>(
            value: financeProvider.current.name,
            onChanged: (String? newValue) {
              /* Now only support the default currency is JPY.
              financeProvider.setCurrent(FinanceTypeInfo.parseType(newValue));
              setState(() {
                refresh++;
              });
               */
            },
            items: FinanceTypeInfo.allItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: value == "JPY" ? Colors.black : Colors.black12)),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Trading Type'),
          subtitle: DropdownButton<String>(
            value: tradingProvider.current.name,
            onChanged: (String? newValue) {
              tradingProvider.setCurrent(TradingTypeInfo.parseType(newValue));
              setState(() {
                refresh++;
              });
            },
            items: TradingTypeInfo.allItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
        ListTile(
          title: const Text('Payment Selected'),
          subtitle: DropdownButton<String>(
            value: paymentsProvider.current.name,
            onChanged: (String? newValue) {
              paymentsProvider.setCurrent(PaymentsInfo.parseType(newValue));
              setState(() {
                refresh++;
              });
            },
            items: PaymentsInfo.allItems.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class CardView extends StatefulWidget {
  const CardView({super.key});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  bool isSwitchOn = false;

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cardProvider = Provider.of<CardProvider>(context);

    _numberController.text = cardProvider.number;
    if (cardProvider.expYear.isNotEmpty) {
      _expController.text = "${cardProvider.expMonth} / ${cardProvider.expYear}";
    } else {
      _expController.text = cardProvider.expMonth;
    }
    _cvcController.text = cardProvider.cvc;

    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              const Expanded(
                child: Align(alignment: Alignment.centerRight, child: Text('CARD')),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Spacer(),
                    const Text(' Use Default ', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: isSwitchOn,
                      onChanged: (bool newValue) => {
                        setState(() {
                          isSwitchOn = !isSwitchOn;
                          var flag = isSwitchOn;
                          cardProvider.number = flag ? "4242 4242 4242 4242" : "";
                          cardProvider.expYear = flag ? "29" : "";
                          cardProvider.expMonth = flag ? "09" : "";
                          cardProvider.cvc = flag ? "123" : "";
                        })
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              )
            ],
          ),
        ),
        ListTile(
          title: const Text('Card Number'),
          subtitle: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardFormatter(16, 4, " ")],
            decoration:
                const InputDecoration(hintText: '4242 4242 4242 4242', hintStyle: TextStyle(color: Colors.black26)),
            controller: _numberController,
            onChanged: (value) {
              cardProvider.number = value;
            },
          ),
        ),
        ListTile(
          title: const Text('Expiry Date'),
          subtitle: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardFormatter(4, 2, " / ")],
            decoration: const InputDecoration(hintText: 'MM / YY', hintStyle: TextStyle(color: Colors.black26)),
            controller: _expController,
            onChanged: (value) {
              String trimmed = value.replaceAll(' ', '');

              if (!trimmed.contains('/')) {
                trimmed = '$trimmed/';
              }

              List<String> parts = trimmed.split('/');
              if (parts.length > 1) {
                cardProvider.expMonth = parts[0].trim();
                cardProvider.expYear = parts[1].trim();
              }
            },
          ),
        ),
        ListTile(
          title: const Text('CVC'),
          subtitle: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardFormatter(3, 3, "")],
            decoration: const InputDecoration(hintText: '123', hintStyle: TextStyle(color: Colors.black26)),
            controller: _cvcController,
            onChanged: (value) {
              cardProvider.cvc = value;
            },
          ),
        ),
      ],
    );
  }
}

class CardFormatter extends TextInputFormatter {
  int totalNumberCount;
  int splitCount;
  String splitChars;

  CardFormatter(this.totalNumberCount, this.splitCount, this.splitChars);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(splitChars, ''); // 移除所有空格
    if (newText.length > totalNumberCount) {
      newText = newText.substring(0, totalNumberCount); // 限制最多16个数字
    }
    StringBuffer formattedText = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % splitCount == 0) {
        formattedText.write(splitChars); // 每四个数字后添加一个空格
      }
      formattedText.write(newText[i]);
    }
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class InfosOverView extends StatelessWidget {
  const InfosOverView({super.key});

  @override
  Widget build(BuildContext context) {
    var infosProvider = Provider.of<InfosProvider>(context);
    var configsProvider = Provider.of<ConfigsProvider>(context);

    List<dynamic> parse(String value) {
      var tuple1 = value.isNotEmpty ? value : "unknown";
      var tuple2 = value.isNotEmpty ? Colors.black : Colors.red;
      return [tuple1, tuple2];
    }

    var name = parse(infosProvider.name)[0];
    var nameColor = parse(infosProvider.name)[1];

    var email = parse(infosProvider.email)[0];
    var emailColor = parse(infosProvider.email)[1];

    var phone = parse(infosProvider.phone)[0];
    var phoneColor = parse(infosProvider.phone)[1];

    var customerId = parse(infosProvider.customerId)[0];
    var customerIdColor = parse(infosProvider.customerId)[1];

    var sourceId = parse(infosProvider.sourceId)[0];
    var sourceIdColor = parse(infosProvider.sourceId)[1];

    return Column(
      children: [
        ListTile(
          title: const Text('Infos'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: [const Text('Name: '), Text(name, style: TextStyle(color: nameColor))]),
              Row(children: [const Text('Email: '), Text(email, style: TextStyle(color: emailColor))]),
              Row(children: [const Text('Phone: '), Text(phone, style: TextStyle(color: phoneColor))]),
              Row(children: [const Text('CustomerId: '), Text(customerId, style: TextStyle(color: customerIdColor))]),
              Row(children: [const Text('SourceId: '), Text(sourceId, style: TextStyle(color: sourceIdColor))]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (configsProvider.secKey.isEmpty || configsProvider.pubKey.isEmpty) {
                Fluttertoast.showToast(msg: "Go to setting to set keys.", gravity: ToastGravity.CENTER);
                return;
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) => InfosView()));
            },
            child: Text(infosProvider.noSource ? 'Add' : 'Update'),
          ),
        ),
      ],
    );
  }
}
