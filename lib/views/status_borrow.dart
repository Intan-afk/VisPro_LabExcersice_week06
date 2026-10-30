import 'package:flutter/material.dart';

import '../models/library_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.forBook(BookStatus status) {
    return switch (status) {
      BookStatus.available =>
        StatusChip(label: 'Tersedia', color: Colors.green.shade700),
      BookStatus.borrowed =>
        StatusChip(label: 'Dipinjam', color: Colors.blue.shade700),
      BookStatus.overdue =>
        StatusChip(label: 'Terlambat', color: Colors.orange.shade800),
      BookStatus.missing =>
        StatusChip(label: 'Hilang', color: Colors.red.shade700),
    };
  }

  factory StatusChip.forLoan(LoanStatus status) {
    return switch (status) {
      LoanStatus.borrowed =>
        StatusChip(label: 'Dipinjam', color: Colors.blue.shade700),
      LoanStatus.overdue =>
        StatusChip(label: 'Terlambat', color: Colors.orange.shade800),
      LoanStatus.missing =>
        StatusChip(label: 'Hilang', color: Colors.red.shade700),
      LoanStatus.returned =>
        StatusChip(label: 'Dikembalikan', color: Colors.green.shade700),
    };
  }

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}