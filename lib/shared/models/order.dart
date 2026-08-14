class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String customerId;
  final String restaurantId;
  final List<OrderItem> items;
  final String deliveryAddress;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomerOrder.fromJson(Map<String, dynamic> json) => CustomerOrder(
    id: json['id'] as String,
    customerId: json['customerId'] as String,
    restaurantId: json['restaurantId'] as String,
    items: (json['items'] as List<dynamic>)
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    deliveryAddress: json['deliveryAddress'] as String,
    subtotal: (json['subtotal'] as num).toInt(),
    deliveryFee: (json['deliveryFee'] as num).toInt(),
    total: (json['total'] as num).toInt(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class OrderItem {
  const OrderItem({
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.notes,
  });

  final String menuItemId;
  final String name;
  final int unitPrice;
  final int quantity;
  final String? notes;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    menuItemId: json['menuItemId'] as String,
    name: json['name'] as String,
    unitPrice: (json['unitPrice'] as num).toInt(),
    quantity: (json['quantity'] as num).toInt(),
    notes: json['notes'] as String?,
  );
}
