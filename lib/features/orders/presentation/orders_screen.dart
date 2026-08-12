import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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
          const Center(child: Icon(Icons.receipt_long_rounded, size: 72, color: AppColors.primary)),
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
