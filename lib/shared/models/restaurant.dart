class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryMinutes,
    required this.deliveryFee,
    required this.imageUrl,
    required this.featuredDish,
  });

  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int deliveryMinutes;
  final double deliveryFee;
  final String imageUrl;
  final String featuredDish;
}
