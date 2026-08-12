import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_animation.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your orders', style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          const Center(
            child: AppAnimation(
              AppAnimationType.done,
              size: 150,
              semanticLabel: 'No orders yet',
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('No orders yet', style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 8),
          const Center(child: Text('Your active and previous orders will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary))),
          const Spacer(),
        ],
      ),
    ),
  );
}
