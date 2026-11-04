import 'package:flutter/material.dart';

import 'main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});

  final List<Book> items;
  final void Function(Book) onRemove;

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0, (sum, book) => sum + book.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Cart is empty'))
                  : ListView(
                      children: items.map((book) {
                        return ListTile(
                          title: Text(book.title),
                          subtitle: Text('${book.price} ₸'),
                          trailing: IconButton(
                            tooltip: 'Remove book',
                            onPressed: () => onRemove(book),
                            icon: const Icon(Icons.close),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Total: $total ₸'),
            ),
          ],
        ),
      ),
    );
  }
}
