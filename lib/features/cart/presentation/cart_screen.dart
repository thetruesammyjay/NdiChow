import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/networking/ndichow_api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/presentation/order_detail_screen.dart';
import '../application/cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.repository});

  final OrderRepository repository;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  bool _submitting = false;
  String? _error;
  String? _lastFingerprint;
  String? _idempotencyKey;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  String _fingerprint(CartController cart, String address) => jsonEncode({
    'restaurantId': cart.restaurantId,
    'address': address,
    'items': [
      for (final line in cart.lines)
        {'id': line.item.id, 'quantity': line.quantity, 'notes': line.notes},
    ],
  });

  String _newIdempotencyKey() {
    final random = Random.secure();
    return base64Url
        .encode(List<int>.generate(24, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  Future<void> _checkout(CartController cart) async {
    final address = _addressController.text.trim();
    if (address.length < 5) {
      setState(() => _error = 'Enter a complete delivery address.');
      return;
    }
    if (!cart.meetsMinimumOrder) {
      setState(
        () =>
            _error =
                'Add ${_money(cart.minimumOrder - cart.subtotal)} more to meet the minimum order.',
      );
      return;
    }
    final fingerprint = _fingerprint(cart, address);
    if (_lastFingerprint != fingerprint) {
      _lastFingerprint = fingerprint;
      _idempotencyKey = _newIdempotencyKey();
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final order = await widget.repository.placeOrder(
        cart: cart,
        deliveryAddress: address,
        idempotencyKey: _idempotencyKey!,
      );
      if (!mounted) return;
      cart.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder:
              (_) => OrderDetailScreen(
                repository: widget.repository,
                initialOrder: order,
              ),
        ),
      );
    } on NdiChowApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = 'We could not place your order. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _editNotes(CartController cart, CartLine line) async {
    final controller = TextEditingController(text: line.notes);
    final notes = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Notes for ${line.item.name}'),
            content: TextField(
              controller: controller,
              maxLength: 300,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Example: No plantain',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (notes != null) cart.setNotes(line.item.id, notes);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your cart')),
    body: Consumer<CartController>(
      builder: (context, cart, _) {
        if (cart.isEmpty) {
          return const Center(child: Text('Your cart is empty.'));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              cart.restaurantName!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            for (final line in cart.lines)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.item.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _money(line.item.price),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Decrease quantity',
                            onPressed:
                                _submitting
                                    ? null
                                    : () => cart.decrement(line.item.id),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '${line.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          IconButton(
                            tooltip: 'Increase quantity',
                            onPressed:
                                _submitting
                                    ? null
                                    : () => cart.increment(line.item.id),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed:
                              _submitting ? null : () => _editNotes(cart, line),
                          icon: const Icon(Icons.edit_note),
                          label: Text(
                            line.notes?.isNotEmpty ?? false
                                ? line.notes!
                                : 'Add a note',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Delivery address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              enabled: !_submitting,
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Street, area, city'),
            ),
            const SizedBox(height: 20),
            _AmountRow(label: 'Subtotal', value: cart.subtotal),
            _AmountRow(label: 'Delivery fee', value: cart.deliveryFee),
            const Divider(height: 28),
            _AmountRow(
              label: 'Estimated total',
              value: cart.estimatedTotal,
              emphasized: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'The backend verifies current prices and returns the final total.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            if (!cart.meetsMinimumOrder) ...[
              const SizedBox(height: 10),
              Text(
                'Add ${_money(cart.minimumOrder - cart.subtotal)} more to reach the minimum order.',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : () => _checkout(cart),
              child:
                  _submitting
                      ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Place order'),
            ),
          ],
        );
      },
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
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          _money(value),
          style: TextStyle(
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w400,
            fontSize: emphasized ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}

String _money(int value) =>
    NumberFormat.currency(symbol: '₦', decimalDigits: 0).format(value);
