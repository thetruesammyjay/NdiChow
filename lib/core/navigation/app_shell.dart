import 'package:flutter/material.dart';
import '../../features/home/data/home_repository.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final List<Widget> _screens = [
    HomeScreen(repository: MockHomeRepository()),
    const SearchScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(child: IndexedStack(index: _selectedIndex, children: _screens)),
        Positioned(left: 12, right: 12, bottom: 14, child: SafeArea(top: false, child: _BottomNavigation(selectedIndex: _selectedIndex, onSelected: (value) => setState(() => _selectedIndex = value)))),
      ],
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.search_outlined, Icons.search_rounded, 'Search'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    height: 68,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 28, offset: Offset(0, 8))],
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
                  Icon(selected ? item.$2 : item.$1, color: selected ? AppColors.primary : AppColors.textSecondary),
                  const SizedBox(height: 3),
                  Text(item.$3, style: TextStyle(fontSize: 11, color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w800 : FontWeight.w400)),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );
}
