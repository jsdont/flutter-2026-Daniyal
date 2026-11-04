import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'widgets/book_row.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final visibleBooks = books.where((book) {
      return book.title.toLowerCase().contains(_search) ||
          book.author.toLowerCase().contains(_search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search books',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _search = value.trim().toLowerCase());
              },
            ),
          ),
        ),
      ),
      body: visibleBooks.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final book in visibleBooks)
                  BookRow(key: ValueKey(book), book: book),
              ],
            ),
    );
  }
}
