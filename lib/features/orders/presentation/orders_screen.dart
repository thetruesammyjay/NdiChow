import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/app_animation.dart';
import '../data/order_repository.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.repository});

  final OrderRepository repository;

  @override
  State<OrdersScreen> createState() => OrdersScreenState();
}

class OrdersScreenState extends State<OrdersScreen> {
  late Future<List<CustomerOrder>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = widget.repository.getOrders();
  }

  void refresh() {
    if (mounted) {
      setState(() {
        _orders = widget.repository.getOrders();
      });
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: FutureBuilder<List<CustomerOrder>>(
      future: _orders,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _OrdersError(onRetry: refresh);
        }
        final orders = snapshot.data ?? const [];
        return RefreshIndicator(
          onRefresh: () async {
            refresh();
            await _orders;
          },
          child:
              orders.isEmpty
                  ? const _EmptyOrders()
                  : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    children: [
                      Text(
                        'Your orders',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 18),
                      for (final order in orders)
                        _OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder:
                                    (_) => OrderDetailScreen(
                                      repository: widget.repository,
                                      orderId: order.id,
                                      initialOrder: order,
                                    ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
        );
      },
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final CustomerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  _label(order.status),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.items
                  .map((item) => '${item.quantity}× ${item.name}')
                  .join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat(
                      'd MMM · h:mm a',
                    ).format(order.createdAt.toLocal()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  _money(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
    children: [
      Text('Your orders', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 80),
      const AppAnimation(
        AppAnimationType.done,
        size: 150,
        semanticLabel: 'No orders yet',
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          'No orders yet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Place your first order and it will appear here.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    ],
  );
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('We could not load your orders.'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}

String _label(String status) => status
    .split('_')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

String _money(int value) =>
    NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(value);
