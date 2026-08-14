import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ndichow/core/networking/ndichow_api_client.dart';

void main() {
  test('parses restaurant details and categorized menu items', () async {
    final api = NdiChowApiClient(
      baseUrl: 'https://api.example.com/api/v1',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'data': {
              'id': 'jollof-corner',
              'name': 'Jollof Corner',
              'description': 'Smoky food',
              'cuisine': ['Nigerian'],
              'rating': 4.8,
              'deliveryFee': 900,
              'minimumOrder': 2500,
              'estimatedDeliveryMinutes': {'min': 20, 'max': 30},
              'imageUrl': 'https://example.com/image.jpg',
              'isOpen': true,
              'menu': [
                {
                  'id': 'popular',
                  'name': 'Popular',
                  'items': [
                    {
                      'id': 'rice',
                      'name': 'Jollof Rice',
                      'description': 'Smoky rice',
                      'price': 3000,
                      'imageUrl': 'https://example.com/rice.jpg',
                      'isAvailable': true,
                      'preparationMinutes': 15,
                    },
                  ],
                },
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final restaurant = await api.getRestaurant('jollof-corner');
    expect(restaurant.menu.single.items.single.price, 3000);
    expect(restaurant.minimumOrder, 2500);
  });

  test(
    'sends bearer authentication and idempotency without client prices',
    () async {
      late http.Request captured;
      final api = NdiChowApiClient(
        baseUrl: 'https://api.example.com/api/v1',
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'data': {
                'id': '550e8400-e29b-41d4-a716-446655440000',
                'customerId': 'customer-1',
                'restaurantId': 'jollof-corner',
                'deliveryAddress': '12 Lagos Street',
                'subtotal': 3000,
                'deliveryFee': 900,
                'total': 3900,
                'status': 'pending',
                'createdAt': '2026-08-14T00:00:00.000Z',
                'updatedAt': '2026-08-14T00:00:00.000Z',
                'items': [
                  {
                    'menuItemId': 'rice',
                    'name': 'Jollof Rice',
                    'unitPrice': 3000,
                    'quantity': 1,
                  },
                ],
              },
            }),
            201,
          );
        }),
      )..setSessionToken('session-token');

      await api.createOrder(
        restaurantId: 'jollof-corner',
        deliveryAddress: '12 Lagos Street',
        idempotencyKey: 'checkout-key-123',
        items: [
          {'menuItemId': 'rice', 'quantity': 1},
        ],
      );

      expect(captured.headers['authorization'], 'Bearer session-token');
      expect(captured.headers['idempotency-key'], 'checkout-key-123');
      final payload = jsonDecode(captured.body) as Map<String, dynamic>;
      final item =
          (payload['items'] as List<dynamic>).single as Map<String, dynamic>;
      expect(item.containsKey('unitPrice'), isFalse);
      expect(item.containsKey('name'), isFalse);
    },
  );
}
