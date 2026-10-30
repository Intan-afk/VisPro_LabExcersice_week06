import 'package:flutter/material.dart';

import 'views_helpers.dart';

class FineSummaryCard extends StatelessWidget {
  const FineSummaryCard({
    super.key,
    required this.totalFine,
    required this.activeCount,
    required this.overdueCount,
    required this.missingCount,
    required this.today,
    this.isDateSimulated = false,
  });

  final int totalFine;
  final int activeCount;
  final int overdueCount;
  final int missingCount;
  final DateTime today;
  final bool isDateSimulated;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total denda', style: textTheme.labelLarge),
            Text(
              formatRupiah(totalFine),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: [
                Text('Dipinjam: $activeCount'),
                Text('Terlambat: $overdueCount'),
                Text('Hilang: $missingCount'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Hari ini: ${formatDate(today)}'
              '${isDateSimulated ? ' (simulasi)' : ''}',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}