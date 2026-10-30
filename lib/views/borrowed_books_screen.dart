import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'loan_card.dart';
import 'views_helpers.dart';

class BorrowedBooksScreen extends StatelessWidget {
  const BorrowedBooksScreen({super.key, required this.viewModel});

  final LibraryViewModel viewModel;

  static String _label(LoanFilter filter) => switch (filter) {
        LoanFilter.all => 'Semua',
        LoanFilter.borrowed => 'Dipinjam',
        LoanFilter.overdue => 'Terlambat',
        LoanFilter.missing => 'Hilang',
        LoanFilter.returned => 'Dikembalikan',
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final loans = viewModel.visibleLoans;

        return Scaffold(
          appBar: AppBar(title: const Text('Pinjaman')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextField(
                  onChanged: viewModel.setLoanQuery,
                  decoration: const InputDecoration(
                    hintText: 'Cari judul, mahasiswa, atau ID pinjaman',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    for (final filter in LoanFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_label(filter)),
                          selected: viewModel.loanFilter == filter,
                          onSelected: (_) => viewModel.setLoanFilter(filter),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: loans.isEmpty
                    ? emptyState(
                        context,
                        Icons.bookmark_border,
                        'Belum ada pinjaman.\nPinjam buku dari katalog atau ubah filter.',
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          for (final loan in loans)
                            LoanCard(
                              loan: loan,
                              bookTitle: viewModel.bookTitle(loan.bookId),
                              status: viewModel.statusOfLoan(loan),
                              fine: viewModel.outstandingFine(loan),
                              overdueDays: viewModel.overdueDaysOf(loan), // DIUBAH
                              canSettle: viewModel.canSettle(loan),
                              onReturn: () => showResultSnackBar(
                                  context, viewModel.returnBook(loan.id)),
                              onSettle: () => showResultSnackBar(
                                  context, viewModel.settleFine(loan.id)),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}