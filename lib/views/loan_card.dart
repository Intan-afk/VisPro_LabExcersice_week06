import 'package:flutter/material.dart';

import '../models/library_status.dart';
import '../models/loan.dart';
import 'status_borrow.dart';
import 'views_helpers.dart';

/// Semua angka dan status dihitung ViewModel lalu dikirim ke sini.
class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.bookTitle,
    required this.status,
    required this.fine,
    required this.overdueDays,
    required this.canSettle,
    required this.onReturn,
    required this.onSettle,
  });

  final Loan loan;
  final String bookTitle;
  final LoanStatus status;
  final int fine;
  final int overdueDays;
  final bool canSettle;
  final VoidCallback onReturn;
  final VoidCallback onSettle;

  String? get _fineText {
    switch (status) {
      case LoanStatus.borrowed:
        return null;
      case LoanStatus.overdue:
        return fine == 0
            ? 'Terlambat $overdueDays hari, belum ada denda.'
            : 'Denda: ${formatRupiah(fine)} ($overdueDays hari terlambat)';
      case LoanStatus.missing:
        return 'Dinyatakan hilang ($overdueDays hari terlambat). '
            'Total ditagih (denda + harga ganti): ${formatRupiah(fine)}';
      case LoanStatus.returned:
        return fine == 0 ? null : 'Tagihan belum lunas: ${formatRupiah(fine)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fineText = _fineText;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(bookTitle, style: textTheme.titleMedium)),
                StatusChip.forLoan(status),
              ],
            ),
            Text('Pinjaman ${loan.id} · Mahasiswa ${loan.studentId}',
                style: textTheme.bodySmall),
            const SizedBox(height: 8),
            Text('Dipinjam: ${formatDate(loan.borrowDate)}'),
            Text('Jatuh tempo: ${formatDate(loan.dueDate)}'),
            if (loan.returnDate != null)
              Text('Dikembalikan: ${formatDate(loan.returnDate!)}'),
            if (fineText != null) ...[
              const SizedBox(height: 8),
              Text(
                fineText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (loan.isActive || canSettle) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: loan.isActive
                    ? FilledButton.tonal(
                        onPressed: onReturn,
                        child: const Text('Kembalikan'),
                      )
                    : OutlinedButton(
                        onPressed: onSettle,
                        child: const Text('Lunasi tagihan'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}