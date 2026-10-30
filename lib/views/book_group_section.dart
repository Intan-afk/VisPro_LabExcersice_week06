import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'status_borrow.dart';
import 'views_helpers.dart';

class BookGroupSection extends StatelessWidget {
  const BookGroupSection({
    super.key,
    required this.group,
    required this.availableCount,
    required this.totalCount,
    required this.canBorrow,
    required this.onBorrow,
  });

  final BookGroup group;
  final int availableCount;
  final int totalCount;
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
                  Text(group.title, style: textTheme.titleMedium),
                  Text(group.author),
                  const SizedBox(height: 4),
                  Text(
                    'Harga ganti: ${formatRupiah(group.replacementPrice)}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusChip(
                        label: canBorrow
                            ? 'Stok: $availableCount / $totalCount'
                            : 'Stok habis (0 / $totalCount)',
                        color: canBorrow
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      Text(
                        'Dipinjam: ${totalCount - availableCount}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
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