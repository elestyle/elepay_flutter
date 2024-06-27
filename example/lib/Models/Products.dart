import 'package:flutter/widgets.dart';

class Product {
  final String emoji;
  final String name;
  final double price;
  final String img;

  Product({required this.emoji, required this.name, required this.price})
      : img = 'https://dummyimage.com/300x200/336ff0/fff.jpg&text=${name}';
}

class ProductsProvider with ChangeNotifier {
  List<Product> products = [
    Product(emoji: "🧿", name: "ModaVest", price: 5),
    Product(emoji: "🧢", name: "LuxStyle", price: 10),
    Product(emoji: "🧤", name: "CapThread", price: 1),
    Product(emoji: "🩱", name: "VivaWear", price: 0.01),
    Product(emoji: "🩲", name: "SilkRoad", price: 6),
    Product(emoji: "🪡", name: "EchoFit", price: 3),
    Product(emoji: "🪢", name: "GlamCap", price: 20),
    Product(emoji: "🩴", name: "UrbTrend", price: 25),
    Product(emoji: "🧺", name: "NovaGear", price: 80),
    Product(emoji: "🎽", name: "ZenWard", price: 30),
    Product(emoji: "🧥", name: "CoolStride", price: 20),
    Product(emoji: "🧣", name: "SkyWoven", price: 5),
    Product(emoji: "🧦", name: "EliteWear", price: 55),
    Product(emoji: "🥼", name: "FlowCove", price: 60),
    Product(emoji: "🥽", name: "PureHabit", price: 20),
    Product(emoji: "🎒", name: "CrestVogue", price: 25),
  ];

  final List<Product> _selected = [];

  void toggle(Product product) {
    if (_selected.contains(product)) {
      _selected.remove(product);
    } else {
      _selected.add(product);
    }
    notifyListeners();
  }

  bool contains(Product product) {
    return _selected.contains(product);
  }

  List<Product> get selected => [..._selected];

  int get count => _selected.length;
}
