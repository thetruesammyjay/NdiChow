import 'package:flutter/foundation.dart';

import '../../../shared/models/restaurant.dart';

class CartLine {
  const CartLine({required this.item, required this.quantity, this.notes});

  final MenuItem item;
  final int quantity;
  final String? notes;

  CartLine copyWith({int? quantity, String? notes}) => CartLine(
    item: item,
    quantity: quantity ?? this.quantity,
    notes: notes ?? this.notes,
  );
}

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};
  String? _restaurantId;
  String? _restaurantName;
  int _deliveryFee = 0;
  int _minimumOrder = 0;

  List<CartLine> get lines => List.unmodifiable(_lines.values);
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  int get deliveryFee => _deliveryFee;
  int get minimumOrder => _minimumOrder;
  bool get isEmpty => _lines.isEmpty;
  int get itemCount =>
      _lines.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => _lines.values.fold(
    0,
    (sum, line) => sum + line.item.price * line.quantity,
  );
  int get estimatedTotal => subtotal + deliveryFee;
  bool get meetsMinimumOrder => subtotal >= minimumOrder;

  bool canAddFrom(Restaurant restaurant) =>
      isEmpty || restaurant.id == _restaurantId;

  void addItem(Restaurant restaurant, MenuItem item, {String? notes}) {
    if (!canAddFrom(restaurant)) {
      throw StateError('The cart contains items from another restaurant.');
    }
    _restaurantId = restaurant.id;
    _restaurantName = restaurant.name;
    _deliveryFee = restaurant.deliveryFee;
    _minimumOrder = restaurant.minimumOrder;
    final existing = _lines[item.id];
    _lines[item.id] = CartLine(
      item: item,
      quantity: (existing?.quantity ?? 0) + 1,
      notes: notes ?? existing?.notes,
    );
    notifyListeners();
  }

  void increment(String menuItemId) {
    final line = _lines[menuItemId];
    if (line == null) return;
    _lines[menuItemId] = line.copyWith(quantity: line.quantity + 1);
    notifyListeners();
  }

  void decrement(String menuItemId) {
    final line = _lines[menuItemId];
    if (line == null) return;
    if (line.quantity == 1) {
      _lines.remove(menuItemId);
    } else {
      _lines[menuItemId] = line.copyWith(quantity: line.quantity - 1);
    }
    if (_lines.isEmpty) _resetRestaurant();
    notifyListeners();
  }

  void setNotes(String menuItemId, String notes) {
    final line = _lines[menuItemId];
    if (line == null) return;
    _lines[menuItemId] = CartLine(
      item: line.item,
      quantity: line.quantity,
      notes: notes.trim().isEmpty ? null : notes.trim(),
    );
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _resetRestaurant();
    notifyListeners();
  }

  void _resetRestaurant() {
    _restaurantId = null;
    _restaurantName = null;
    _deliveryFee = 0;
    _minimumOrder = 0;
  }
}
