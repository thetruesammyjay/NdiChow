import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ndichow/main.dart';
import 'package:ndichow/features/auth/application/auth_controller.dart';
import 'package:ndichow/features/cart/application/cart_controller.dart';
import 'package:ndichow/features/home/data/home_repository.dart';
import 'package:ndichow/features/orders/data/order_repository.dart';
import 'package:ndichow/shared/models/customer.dart';
import 'package:ndichow/shared/models/order.dart';

AuthController authenticatedController() => AuthController.authenticated(
  Customer(
    id: 'customer-1',
    email: 'customer@example.com',
    name: 'Test Customer',
    createdAt: DateTime.utc(2026),
  ),
);

class FakeOrderRepository implements OrderRepository {
  @override
  Future<CustomerOrder> getOrder(String orderId) => throw UnimplementedError();

  @override
  Future<List<CustomerOrder>> getOrders() async => const [];

  @override
  Future<CustomerOrder> placeOrder({
    required CartController cart,
    required String deliveryAddress,
    required String idempotencyKey,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('renders the main food discovery shell', (tester) async {
    await tester.pumpWidget(
      NdiChowApp(
        homeRepository: MockHomeRepository(),
        authController: authenticatedController(),
        orderRepository: FakeOrderRepository(),
        loadingBuilder: (_) => const CircularProgressIndicator(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('What are you\nchowing today?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('switches between the main destinations', (tester) async {
    await tester.pumpWidget(
      NdiChowApp(
        homeRepository: MockHomeRepository(),
        authController: authenticatedController(),
        orderRepository: FakeOrderRepository(),
        loadingBuilder: (_) => const CircularProgressIndicator(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('Your orders'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Basil icons by Craftwork • CC BY 4.0'), findsOneWidget);
  });
}
