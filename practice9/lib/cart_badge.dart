import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$total ₸'),
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
