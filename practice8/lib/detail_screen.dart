import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (context.mounted == false) return;
    if (confirmed == true) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(book.title, style: textTheme.headlineSmall),
              const SizedBox(height: 20),
              Text('Author: ${book.author}', style: textTheme.bodyLarge),
              const SizedBox(height: 12),
              Text('Pages: ${book.pages}', style: textTheme.bodyLarge),
              const SizedBox(height: 12),
              Text(
                book.year == null ? 'Year unknown' : 'Year: ${book.year}',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                book.read ? 'Status: Read' : 'Status: Unread',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(BookAction.toggleRead);
                },
                child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _delete(context),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
