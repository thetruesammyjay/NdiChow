import '../../../shared/models/restaurant.dart';

abstract interface class HomeRepository {
  Future<List<Restaurant>> getNearbyRestaurants();
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<List<Restaurant>> getNearbyRestaurants() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Restaurant(
        id: 'jollof-corner',
        name: 'Jollof Corner',
        cuisine: 'Nigerian • Rice & Grill',
        rating: 4.8,
        deliveryMinutes: 25,
        deliveryFee: 900,
        imageUrl: 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=900',
        featuredDish: 'Smoky party jollof',
      ),
      Restaurant(
        id: 'mamas-kitchen',
        name: "Mama's Kitchen",
        cuisine: 'African • Local favourites',
        rating: 4.7,
        deliveryMinutes: 35,
        deliveryFee: 700,
        imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554?w=900',
        featuredDish: 'Egusi soup & pounded yam',
      ),
      Restaurant(
        id: 'suya-stop',
        name: 'Suya Stop',
        cuisine: 'Grill • Late night',
        rating: 4.6,
        deliveryMinutes: 20,
        deliveryFee: 500,
        imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=900',
        featuredDish: 'Spicy beef suya platter',
      ),
    ];
  }
}
