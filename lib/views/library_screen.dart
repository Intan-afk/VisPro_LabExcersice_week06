import 'package:flutter/material.dart';

import '../viewmodels/library_view_model.dart';
import 'book_group_section.dart';
import 'borrowed_books_screen.dart';
import 'summary_card.dart';
import 'views_helpers.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key, required this.viewModel});

  final LibraryViewModel viewModel;

  Future<void> _borrow(BuildContext context, BookGroup group) async {
    final studentId = await showDialog<String>(
      context: context,
      builder: (_) => _StudentIdDialog(bookTitle: group.title),
    );
    if (studentId == null || !context.mounted) return;
    showResultSnackBar(context, viewModel.borrowFromGroup(group, studentId));
  }

  Future<void> _pickTestDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) viewModel.setSimulatedDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final groups = viewModel.bookGroups;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perpustakaan'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.event),
                tooltip: 'Uji tanggal',
                onSelected: (value) {
                  if (value == 'pick') {
                    _pickTestDate(context);
                  } else {
                    viewModel.resetDate();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'pick',
                    child: Text('Ubah tanggal (uji)'),
                  ),
                  PopupMenuItem(
                    value: 'reset',
                    child: Text('Reset ke hari ini'),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long),
                tooltip: 'Pinjaman',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BorrowedBooksScreen(viewModel: viewModel),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FineSummaryCard(
                totalFine: viewModel.totalOutstandingFines,
                activeCount: viewModel.activeLoans.length,
                overdueCount: viewModel.overdueLoans.length,
                missingCount: viewModel.missingLoans.length,
                today: viewModel.today,
                isDateSimulated: viewModel.isDateSimulated,
              ),
              const SizedBox(height: 16),
              Text(
                'Katalog buku',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (groups.isEmpty)
                SizedBox(
                  height: 220,
                  child: emptyState(
                    context,
                    Icons.menu_book_outlined,
                    'Katalog masih kosong.',
                  ),
                )
              else
                for (final group in groups)
                  BookGroupSection(
                    group: group,
                    availableCount: viewModel.availableCount(group),
                    totalCount: viewModel.totalCopies(group),
                    canBorrow: viewModel.canBorrowGroup(group),
                    onBorrow: () => _borrow(context, group),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentIdDialog extends StatefulWidget {
  const _StudentIdDialog({required this.bookTitle});

  final String bookTitle;

  @override
  State<_StudentIdDialog> createState() => _StudentIdDialogState();
}

class _StudentIdDialogState extends State<_StudentIdDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pinjam buku'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'ID mahasiswa',
          helperText: widget.bookTitle,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Pinjam'),
        ),
      ],
    );
  }
}
