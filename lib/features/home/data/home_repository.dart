import '../../../shared/models/restaurant.dart';
import '../../../core/networking/ndichow_api_client.dart';

abstract interface class HomeRepository {
  Future<List<Restaurant>> getNearbyRestaurants({String? query});
  Future<Restaurant> getRestaurant(String restaurantId);
}

class HttpHomeRepository implements HomeRepository {
  const HttpHomeRepository(this._client);
  final NdiChowApiClient _client;

  @override
  Future<List<Restaurant>> getNearbyRestaurants({String? query}) =>
      _client.getRestaurants(query: query);

  @override
  Future<Restaurant> getRestaurant(String restaurantId) =>
      _client.getRestaurant(restaurantId);
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<List<Restaurant>> getNearbyRestaurants({String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Restaurant(
        id: 'jollof-corner',
        name: 'Jollof Corner',
        cuisines: ['Nigerian', 'Rice', 'Grill'],
        rating: 4.8,
        minimumDeliveryMinutes: 20,
        maximumDeliveryMinutes: 30,
        deliveryFee: 900,
        minimumOrder: 2500,
        imageUrl:
            'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=900',
        isOpen: true,
      ),
      Restaurant(
        id: 'mamas-kitchen',
        name: "Mama's Kitchen",
        cuisines: ['African', 'Local favourites'],
        rating: 4.7,
        minimumDeliveryMinutes: 30,
        maximumDeliveryMinutes: 40,
        deliveryFee: 700,
        minimumOrder: 3000,
        imageUrl:
            'https://images.unsplash.com/photo-1547592180-85f173990554?w=900',
        isOpen: true,
      ),
      Restaurant(
        id: 'suya-stop',
        name: 'Suya Stop',
        cuisines: ['Grill', 'Late night'],
        rating: 4.6,
        minimumDeliveryMinutes: 15,
        maximumDeliveryMinutes: 25,
        deliveryFee: 500,
        minimumOrder: 2000,
        imageUrl:
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=900',
        isOpen: true,
      ),
    ];
  }

  @override
  Future<Restaurant> getRestaurant(String restaurantId) async {
    final restaurants = await getNearbyRestaurants();
    return restaurants.firstWhere(
      (restaurant) => restaurant.id == restaurantId,
    );
  }
}
