import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/cart/application/cart_controller.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/home/data/home_repository.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/orders/data/order_repository.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/restaurants/presentation/restaurant_detail_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../shared/widgets/basil_icon.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.homeRepository,
    required this.orderRepository,
    this.loadingBuilder,
  });

  final HomeRepository homeRepository;
  final OrderRepository orderRepository;
  final WidgetBuilder? loadingBuilder;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _ordersKey = GlobalKey<OrdersScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(
      repository: widget.homeRepository,
      onSearchTap: () => _selectDestination(1),
      onRestaurantTap: _openRestaurant,
      loadingBuilder: widget.loadingBuilder,
    ),
    SearchScreen(
      repository: widget.homeRepository,
      onRestaurantTap: _openRestaurant,
    ),
    OrdersScreen(key: _ordersKey, repository: widget.orderRepository),
    const ProfileScreen(),
  ];

  void _selectDestination(int value) {
    if (value == 2) _ordersKey.currentState?.refresh();
    if (_selectedIndex != value) setState(() => _selectedIndex = value);
  }

  void _openRestaurant(String restaurantId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => RestaurantDetailScreen(
              restaurantId: restaurantId,
              repository: widget.homeRepository,
              orderRepository: widget.orderRepository,
            ),
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
    body: Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(index: _selectedIndex, children: _screens),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 92,
          child: Consumer<CartController>(
            builder:
                (context, cart, _) =>
                    cart.isEmpty
                        ? const SizedBox.shrink()
                        : FilledButton.icon(
                          onPressed: _openCart,
                          icon: const BasilIcon(
                            'shopping-bag-solid',
                            color: Colors.white,
                          ),
                          label: Text(
                            'View cart · ${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                          ),
                        ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 14,
          child: SafeArea(
            top: false,
            child: _BottomNavigation(
              selectedIndex: _selectedIndex,
              onSelected: _selectDestination,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = [
    ('home-outline', 'home-solid', 'Home'),
    ('search-outline', 'search-solid', 'Search'),
    ('shopping-bag-outline', 'shopping-bag-solid', 'Orders'),
    ('user-outline', 'user-solid', 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    height: 68,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 28,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final selected = selectedIndex == index;
        return Expanded(
          child: Semantics(
            button: true,
            selected: selected,
            label: item.$3,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onSelected(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BasilIcon(
                    selected ? item.$2 : item.$1,
                    size: 24,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$3,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );
}
