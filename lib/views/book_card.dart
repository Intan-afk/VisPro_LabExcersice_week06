import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/library_status.dart';
import 'status_borrow.dart';
import 'views_helpers.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.status,
    required this.canBorrow,
    required this.onBorrow,
  });

  final Book book;
  final BookStatus status;
  final bool canBorrow;
  final VoidCallback onBorrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: textTheme.titleMedium),
                  Text(book.author),
                  const SizedBox(height: 4),
                  Text(
                    'Harga ganti: ${formatRupiah(book.replacementPrice)}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  StatusChip.forBook(status),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: canBorrow ? onBorrow : null,
              child: const Text('Pinjam'),
            ),
          ],
        ),
      ),
    );
  }
}