import 'package:flutter/foundation.dart';

class CartController extends ChangeNotifier {
  int _itemCount = 0;

  int get itemCount => _itemCount;

  void addItem() {
    _itemCount++;
    notifyListeners();
  }

  void clear() {
    _itemCount = 0;
    notifyListeners();
  }
}
