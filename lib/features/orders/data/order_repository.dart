import '../../../core/networking/ndichow_api_client.dart';
import '../../../shared/models/order.dart';
import '../../cart/application/cart_controller.dart';

abstract interface class OrderRepository {
  Future<List<CustomerOrder>> getOrders();
  Future<CustomerOrder> getOrder(String orderId);
  Future<CustomerOrder> placeOrder({
    required CartController cart,
    required String deliveryAddress,
    required String idempotencyKey,
  });
}

class HttpOrderRepository implements OrderRepository {
  const HttpOrderRepository(this._api);

  final NdiChowApiClient _api;

  @override
  Future<List<CustomerOrder>> getOrders() => _api.getOrders();

  @override
  Future<CustomerOrder> getOrder(String orderId) => _api.getOrder(orderId);

  @override
  Future<CustomerOrder> placeOrder({
    required CartController cart,
    required String deliveryAddress,
    required String idempotencyKey,
  }) => _api.createOrder(
    restaurantId: cart.restaurantId!,
    deliveryAddress: deliveryAddress,
    idempotencyKey: idempotencyKey,
    items: cart.lines
        .map(
          (line) => <String, Object?>{
            'menuItemId': line.item.id,
            'quantity': line.quantity,
            if (line.notes?.isNotEmpty ?? false) 'notes': line.notes,
          },
        )
        .toList(growable: false),
  );
}
