import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/order.dart';
import '../data/order_repository.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.repository,
    this.orderId,
    this.initialOrder,
  }) : assert(orderId != null || initialOrder != null);

  final OrderRepository repository;
  final String? orderId;
  final CustomerOrder? initialOrder;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<CustomerOrder> _order;

  @override
  void initState() {
    super.initState();
    _order =
        widget.initialOrder == null
            ? widget.repository.getOrder(widget.orderId!)
            : Future.value(widget.initialOrder);
  }

  void _refresh() {
    final id = widget.orderId ?? widget.initialOrder!.id;
    setState(() {
      _order = widget.repository.getOrder(id);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Order details')),
    body: FutureBuilder<CustomerOrder>(
      future: _order,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: _refresh,
              child: const Text('Retry order details'),
            ),
          );
        }
        return _OrderBody(order: snapshot.data!, onRefresh: _refresh);
      },
    ),
  );
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order, required this.onRefresh});

  final CustomerOrder order;
  final VoidCallback onRefresh;

  static const statuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready_for_pickup',
    'out_for_delivery',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = statuses.indexOf(order.status);
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('d MMM yyyy · h:mm a').format(order.createdAt.toLocal()),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Text('Order progress', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (order.status == 'cancelled')
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cancel, color: AppColors.error),
              title: Text('Order cancelled'),
            )
          else
            for (var index = 0; index < statuses.length; index++)
              _TimelineRow(
                status: statuses[index],
                completed: index <= currentIndex,
                last: index == statuses.length - 1,
              ),
          const SizedBox(height: 20),
          Text('Items', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final item in order.items) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.quantity}×',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name),
                              if (item.notes != null)
                                Text(
                                  item.notes!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(_money(item.unitPrice * item.quantity)),
                      ],
                    ),
                    const Divider(height: 24),
                  ],
                  _AmountRow(label: 'Subtotal', value: order.subtotal),
                  _AmountRow(label: 'Delivery fee', value: order.deliveryFee),
                  const Divider(height: 24),
                  _AmountRow(
                    label: 'Total',
                    value: order.total,
                    emphasized: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Deliver to', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            order.deliveryAddress,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.status,
    required this.completed,
    required this.last,
  });

  final String status;
  final bool completed;
  final bool last;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? AppColors.secondary : AppColors.outline,
          ),
          if (!last)
            Container(
              width: 2,
              height: 28,
              color: completed ? AppColors.secondary : AppColors.outline,
            ),
        ],
      ),
      const SizedBox(width: 12),
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          _statusLabel(status),
          style: TextStyle(
            fontWeight: completed ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      _statusLabel(status),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final int value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          _money(value),
          style: TextStyle(
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

String _statusLabel(String status) => status
    .split('_')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

String _money(int value) =>
    NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(value);
