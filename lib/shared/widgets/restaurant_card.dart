import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/restaurant.dart';
import 'basil_icon.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, this.onTap});

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: AppColors.primaryContainer,
                      alignment: Alignment.center,
                      child: const Text('🍲', style: TextStyle(fontSize: 52)),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const BasilIcon(
                        'star-solid',
                        color: AppColors.warning,
                        size: 20,
                      ),
                      Text(' ${restaurant.rating}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurant.cuisines.join(' • '),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const BasilIcon('clock-outline', size: 18),
                      Text(
                        ' ${restaurant.minimumDeliveryMinutes}-${restaurant.maximumDeliveryMinutes} min',
                      ),
                      const SizedBox(width: 16),
                      const BasilIcon('shopping-bag-outline', size: 18),
                      Text(' ${currency.format(restaurant.deliveryFee)}'),
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
