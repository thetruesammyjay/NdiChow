import 'package:flutter_test/flutter_test.dart';
import 'package:ndichow/features/cart/application/cart_controller.dart';
import 'package:ndichow/shared/models/restaurant.dart';

void main() {
  const item = MenuItem(
    id: 'rice',
    name: 'Jollof Rice',
    description: 'Smoky rice',
    price: 3000,
    imageUrl: 'https://example.com/rice.jpg',
    isAvailable: true,
    preparationMinutes: 15,
  );
  const restaurant = Restaurant(
    id: 'one',
    name: 'Restaurant One',
    cuisines: ['Nigerian'],
    rating: 4.5,
    minimumDeliveryMinutes: 20,
    maximumDeliveryMinutes: 30,
    deliveryFee: 700,
    minimumOrder: 5000,
    imageUrl: 'https://example.com/restaurant.jpg',
    isOpen: true,
  );

  test('calculates quantities, minimum order, and estimated total', () {
    final cart = CartController();
    cart.addItem(restaurant, item);
    expect(cart.subtotal, 3000);
    expect(cart.meetsMinimumOrder, isFalse);

    cart.increment(item.id);
    expect(cart.itemCount, 2);
    expect(cart.subtotal, 6000);
    expect(cart.estimatedTotal, 6700);
    expect(cart.meetsMinimumOrder, isTrue);
  });

  test('requires clearing before changing restaurants', () {
    final cart = CartController()..addItem(restaurant, item);
    const other = Restaurant(
      id: 'two',
      name: 'Restaurant Two',
      cuisines: ['Grill'],
      rating: 4.2,
      minimumDeliveryMinutes: 15,
      maximumDeliveryMinutes: 25,
      deliveryFee: 500,
      minimumOrder: 2000,
      imageUrl: 'https://example.com/other.jpg',
      isOpen: true,
    );

    expect(cart.canAddFrom(other), isFalse);
    expect(() => cart.addItem(other, item), throwsStateError);
    cart.clear();
    expect(cart.canAddFrom(other), isTrue);
  });
}
