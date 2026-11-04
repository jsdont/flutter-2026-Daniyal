import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all books from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          TextButton(
            onPressed: () => _clearCart(context),
            child: const Text('Clear cart'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<Cart>(
                builder: (context, cart, child) {
                  if (cart.items.isEmpty) {
                    return const Center(child: Text('Cart is empty'));
                  }

                  return ListView(
                    children: [
                      for (final book in cart.items)
                        ListTile(
                          title: Text(book.title),
                          subtitle: Text(
                            '${book.price} ₸ ×${cart.qtyOf(book)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Increase quantity',
                                onPressed: () => cart.increment(book),
                                icon: const Icon(Icons.add),
                              ),
                              IconButton(
                                tooltip: 'Remove book',
                                onPressed: () => cart.remove(book),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Consumer<Cart>(
              child: const TotalLabel(),
              builder: (context, cart, child) {
                return ExpansionTile(
                  initiallyExpanded: true,
                  title: child!,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${cart.total} ₸',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TotalLabel extends StatelessWidget {
  const TotalLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [Icon(Icons.receipt_long), SizedBox(width: 8), Text('Total')],
    );
  }
}
