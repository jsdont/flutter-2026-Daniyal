import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final count = context.select<Cart, int>((cart) => cart.count);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _CartTotal(),
        IconButton(
          tooltip: 'Open cart',
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
          icon: Badge(
            label: Text('$count'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _CartTotal extends StatelessWidget {
  const _CartTotal();

  @override
  Widget build(BuildContext context) {
    final total = context.select<Cart, int>((cart) => cart.total);
    return Text('$total ₸');
  }
}
