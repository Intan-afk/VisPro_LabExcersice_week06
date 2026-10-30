import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';

void showResultSnackBar(BuildContext context, ActionResult result) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            result.isSuccess ? null : Theme.of(context).colorScheme.error,
      ),
    );
}

String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return 'Rp$buffer';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatDate(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

Widget emptyState(BuildContext context, IconData icon, String message) {
  final color = Theme.of(context).colorScheme.outline;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}