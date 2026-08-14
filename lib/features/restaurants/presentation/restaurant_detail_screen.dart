import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/cart/application/cart_controller.dart';
import '../../../features/cart/presentation/cart_screen.dart';
import '../../../features/home/data/home_repository.dart';
import '../../../features/orders/data/order_repository.dart';
import '../../../shared/models/restaurant.dart';
import '../../../shared/widgets/basil_icon.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.repository,
    required this.orderRepository,
  });

  final String restaurantId;
  final HomeRepository repository;
  final OrderRepository orderRepository;

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Future<Restaurant> _restaurant;

  @override
  void initState() {
    super.initState();
    _restaurant = widget.repository.getRestaurant(widget.restaurantId);
  }

  Future<void> _add(Restaurant restaurant, MenuItem item) async {
    final cart = context.read<CartController>();
    if (!cart.canAddFrom(restaurant)) {
      final replace = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Start a new cart?'),
              content: Text(
                'Your cart contains items from ${cart.restaurantName}. Clear it and order from ${restaurant.name}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep cart'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Start new cart'),
                ),
              ],
            ),
      );
      if (replace != true || !mounted) return;
      cart.clear();
    }
    cart.addItem(restaurant, item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to your cart.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(repository: widget.orderRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Restaurant')),
    body: FutureBuilder<Restaurant>(
      future: _restaurant,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _DetailError(
            onRetry:
                () => setState(() {
                  _restaurant = widget.repository.getRestaurant(
                    widget.restaurantId,
                  );
                }),
          );
        }
        return _RestaurantBody(restaurant: snapshot.data!, onAdd: _add);
      },
    ),
    bottomNavigationBar: Consumer<CartController>(
      builder:
          (context, cart, _) =>
              cart.isEmpty
                  ? const SizedBox.shrink()
                  : SafeArea(
                    minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: FilledButton(
                      onPressed: _openCart,
                      child: Text(
                        'View cart · ${cart.itemCount} · ${_money(cart.estimatedTotal)}',
                      ),
                    ),
                  ),
    ),
  );
}

class _RestaurantBody extends StatelessWidget {
  const _RestaurantBody({required this.restaurant, required this.onAdd});

  final Restaurant restaurant;
  final Future<void> Function(Restaurant, MenuItem) onAdd;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 24),
    children: [
      AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          restaurant.imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => const ColoredBox(
                color: AppColors.primaryContainer,
                child: Center(
                  child: Text('🍲', style: TextStyle(fontSize: 64)),
                ),
              ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                _OpenBadge(isOpen: restaurant.isOpen),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.description,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Fact(
                  icon: 'star-solid',
                  label: restaurant.rating.toStringAsFixed(1),
                ),
                _Fact(
                  icon: 'clock-outline',
                  label:
                      '${restaurant.minimumDeliveryMinutes}-${restaurant.maximumDeliveryMinutes} min',
                ),
                _Fact(
                  icon: 'shopping-bag-outline',
                  label: '${_money(restaurant.deliveryFee)} delivery',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum order ${_money(restaurant.minimumOrder)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      for (final category in restaurant.menu) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final item in category.items)
          _MenuItemCard(
            item: item,
            restaurantOpen: restaurant.isOpen,
            onAdd: () => onAdd(restaurant, item),
          ),
      ],
      if (restaurant.menu.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('This restaurant has not published a menu yet.'),
          ),
        ),
    ],
  );
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.restaurantOpen,
    required this.onAdd,
  });

  final MenuItem item;
  final bool restaurantOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final available = restaurantOpen && item.isAvailable;
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                width: 86,
                height: 86,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const SizedBox.square(
                      dimension: 86,
                      child: ColoredBox(
                        color: AppColors.primaryContainer,
                        child: Center(
                          child: Text('🍛', style: TextStyle(fontSize: 34)),
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _money(item.price),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton.filled(
                        tooltip: available ? 'Add ${item.name}' : 'Unavailable',
                        onPressed: available ? onAdd : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      BasilIcon(icon, size: 17),
      const SizedBox(width: 4),
      Text(label),
    ],
  );
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isOpen ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      isOpen ? 'Open' : 'Closed',
      style: TextStyle(
        color: isOpen ? const Color(0xFF047857) : AppColors.error,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('We could not load this restaurant.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

String _money(int value) =>
    NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(value);
