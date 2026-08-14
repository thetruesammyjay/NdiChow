class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.rating,
    required this.minimumDeliveryMinutes,
    required this.maximumDeliveryMinutes,
    required this.deliveryFee,
    required this.imageUrl,
    required this.isOpen,
  });

  final String id;
  final String name;
  final List<String> cuisines;
  final double rating;
  final int minimumDeliveryMinutes;
  final int maximumDeliveryMinutes;
  final int deliveryFee;
  final String imageUrl;
  final bool isOpen;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final delivery = json['estimatedDeliveryMinutes'] as Map<String, dynamic>?;
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      cuisines: (json['cuisine'] as List<dynamic>).cast<String>(),
      rating: (json['rating'] as num).toDouble(),
      minimumDeliveryMinutes: (delivery?['min'] as num).toInt(),
      maximumDeliveryMinutes: (delivery?['max'] as num).toInt(),
      deliveryFee: (json['deliveryFee'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      isOpen: json['isOpen'] as bool,
    );
  }
}
