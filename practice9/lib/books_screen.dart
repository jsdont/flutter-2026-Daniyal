import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'main.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.onAdd,
  });

  final List<Book> cart;
  final int total;
  final void Function(Book) onAdd;

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [CartBadge(count: cart.length, total: total)],
      ),
      body: ListView(
        children: books.map((book) {
          debugPrint('row ${book.title}');

          return ListTile(
            title: Text(book.title),
            subtitle: Text('${book.author}\n${book.price} ₸'),
            isThreeLine: true,
            trailing: cart.contains(book)
                ? const Text('Added')
                : OutlinedButton(
                    onPressed: () => onAdd(book),
                    child: const Text('Add'),
                  ),
          );
        }).toList(),
      ),
    );
  }
}
