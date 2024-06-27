import 'package:elepay_flutter/elepay_flutter.dart';
import 'package:elepay_flutter_example/Help/KVMap.dart';
import 'package:elepay_flutter_example/Models/Payments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Api/PayHandler.dart';
import 'Models/Card.dart';
import 'Models/Configs.dart';
import 'Models/Finance.dart';
import 'Models/Information.dart';
import 'Models/Products.dart';
import 'Models/TradingType.dart';
import 'ProductsView.dart';
import 'SettingView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KVMap.init();

  var config = ElepayConfiguration(KVMap.get(KV_KEY_pubKey) ?? "");
  ElepayFlutter.initElepay(config);

  PayHandler.setup();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProductsProvider()),
      ChangeNotifierProvider(create: (context) => FinanceProvider()),
      ChangeNotifierProvider(create: (context) => TradingProvider()),
      ChangeNotifierProvider(create: (context) => PaymentsProvider()),
      ChangeNotifierProvider(create: (context) => InfosProvider.load()),
      ChangeNotifierProvider(create: (context) => ConfigsProvider.load()),
      ChangeNotifierProvider(create: (context) => CardProvider.load()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // force update BottomNavigationBar's currentIndex
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          ProductsView(),
          SettingView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabController.index,
        onDestinationSelected: (index) {
          _tabController.animateTo(index);
        },
        destinations: const [
          NavigationDestination(
            tooltip: '',
            icon: Icon(Icons.store_outlined),
            label: 'Products',
            selectedIcon: Icon(Icons.store),
          ),
          NavigationDestination(
            tooltip: '',
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
            selectedIcon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
