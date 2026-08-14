class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.rating,
    required this.minimumDeliveryMinutes,
    required this.maximumDeliveryMinutes,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.imageUrl,
    required this.isOpen,
    this.description = '',
    this.menu = const [],
  });

  final String id;
  final String name;
  final String description;
  final List<String> cuisines;
  final double rating;
  final int minimumDeliveryMinutes;
  final int maximumDeliveryMinutes;
  final int deliveryFee;
  final int minimumOrder;
  final String imageUrl;
  final bool isOpen;
  final List<MenuCategory> menu;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final delivery = json['estimatedDeliveryMinutes'] as Map<String, dynamic>?;
    final menu = json['menu'] as List<dynamic>?;
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      cuisines: (json['cuisine'] as List<dynamic>).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      minimumDeliveryMinutes: (delivery?['min'] as num).toInt(),
      maximumDeliveryMinutes: (delivery?['max'] as num).toInt(),
      deliveryFee: (json['deliveryFee'] as num).toInt(),
      minimumOrder: (json['minimumOrder'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      isOpen: json['isOpen'] as bool,
      menu:
          menu
              ?.map(
                (item) => MenuCategory.fromJson(item as Map<String, dynamic>),
              )
              .toList(growable: false) ??
          const [],
    );
  }
}

class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<MenuItem> items;

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    items: (json['items'] as List<dynamic>)
        .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.preparationMinutes,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final bool isAvailable;
  final int preparationMinutes;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toInt(),
    imageUrl: json['imageUrl'] as String,
    isAvailable: json['isAvailable'] as bool,
    preparationMinutes: (json['preparationMinutes'] as num).toInt(),
  );
}
