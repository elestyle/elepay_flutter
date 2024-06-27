import 'package:elepay_flutter_example/Api/PayHandler.dart';
import 'package:elepay_flutter_example/Api/SourceHandler.dart';
import 'package:elepay_flutter_example/Models/Information.dart';
import 'package:elepay_flutter_example/Models/Payments.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class InfosView extends StatefulWidget {
  const InfosView({super.key});

  @override
  State<InfosView> createState() => _InfosViewState();
}

class _InfosViewState extends State<InfosView> {
  List<Map<String, dynamic>> sources = [];

  @override
  Widget build(BuildContext context) {
    var infosProvider = Provider.of<InfosProvider>(context);
    var paymentsProvider = Provider.of<PaymentsProvider>(context);

    void syncCustomer(Function(String?) completion) {
      PayHandler.instance.queryCustomer((List<Map<String, dynamic>> ret) {
        var custom = ret.firstWhere(
          (element) => element['email'] == infosProvider.email,
          orElse: () => <String, dynamic>{},
        );
        String? customerId = custom["id"];
        if (customerId != null) {
          PayHandler.instance.updateCustomer(
            infosProvider.name,
            infosProvider.email,
            infosProvider.phone,
            customerId,
            (String? ret) {
              completion(ret);
            },
          );
        } else {
          PayHandler.instance.createCustomer(
            infosProvider.name,
            infosProvider.email,
            infosProvider.phone,
            (String? ret) {
              completion(ret);
            },
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Infos')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Name'),
            subtitle: TextFormField(
              initialValue: infosProvider.name,
              decoration: const InputDecoration(hintText: 'Juice', hintStyle: TextStyle(color: Colors.black26)),
              onChanged: (value) {
                infosProvider.name = value;
              },
            ),
          ),
          ListTile(
            title: const Text('Email'),
            subtitle: TextFormField(
              initialValue: infosProvider.email,
              decoration: const InputDecoration(hintText: 'someone@mail', hintStyle: TextStyle(color: Colors.black26)),
              onChanged: (value) {
                infosProvider.email = value;
              },
            ),
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: TextFormField(
              initialValue: infosProvider.phone,
              decoration: const InputDecoration(hintText: '7010102020', hintStyle: TextStyle(color: Colors.black26)),
              onChanged: (value) {
                infosProvider.phone = value;
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('CustomerId'),
            subtitle: Row(
              children: [
                Text(infosProvider.customerId.isNotEmpty ? infosProvider.customerId : "< need sync >"),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (infosProvider.noInfos) {
                      Fluttertoast.showToast(msg: "Infos cannot be empty.", gravity: ToastGravity.CENTER);
                      return;
                    }
                    syncCustomer((String? customerId) {
                      if (customerId != null && customerId.isNotEmpty) {
                        infosProvider.customerId = customerId ?? "";
                        Fluttertoast.showToast(msg: "Sync Success.", gravity: ToastGravity.CENTER);
                      } else {
                        Fluttertoast.showToast(msg: "Sync Failed.", gravity: ToastGravity.CENTER);
                      }
                    });
                  },
                  child: const Text('Sync'),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'SourceId:${infosProvider.sourceId.isNotEmpty ? infosProvider.sourceId : '< need add or sync to selected >'}',
            ),
            subtitle: Column(
              children: [
                for (var item in sources)
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        infosProvider.sourceId = item["id"];
                      },
                      child: Text(item["id"] ?? "error"),
                    ),
                  ),
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (infosProvider.customerId.isEmpty) {
                          return;
                        }
                        PayHandler.instance.querySource(
                          infosProvider.customerId,
                          (List<Map<String, dynamic>> ret) {
                            setState(() {
                              sources = ret;
                            });
                            if (ret.isEmpty) {
                              Fluttertoast.showToast(msg: "No source, please add one.", gravity: ToastGravity.CENTER);
                            }
                          },
                        );
                      },
                      child: const Text('Sync'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (infosProvider.customerId.isEmpty) {
                          return;
                        }
                        PayHandler.instance.createSource(
                          infosProvider.customerId,
                          paymentsProvider.current,
                          (String? sourceId) {
                            infosProvider.sourceId = sourceId ?? "";
                          },
                        );
                      },
                      child: const Text('Add(pre page with payment)'),
                    ),
                    const Spacer(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
