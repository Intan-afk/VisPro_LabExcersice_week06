import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/library_status.dart';
import '../models/loan.dart';
import 'fine_calculator.dart';

typedef Clock = DateTime Function();

enum BookFilter { all, available, borrowed, overdue, missing }

enum LoanFilter { all, borrowed, overdue, missing, returned }

class ActionResult {
  const ActionResult.success(this.message) : isSuccess = true;
  const ActionResult.failure(this.message) : isSuccess = false;

  final bool isSuccess;
  final String message;
}

class FineSummary {
  const FineSummary({
    required this.totalOutstanding,
    required this.activeLoans,
    required this.overdueLoans,
    required this.missingLoans,
  });

  final int totalOutstanding;
  final int activeLoans;
  final int overdueLoans;
  final int missingLoans;
}

class BookGroup {
  const BookGroup({
    required this.title,
    required this.author,
    required this.replacementPrice,
    required this.copies,
  });

  final String title;
  final String author;
  final int replacementPrice;
  final List<Book> copies;
}

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    List<Book> books = const [],
    List<Loan> loans = const [],
    FineCalculator policy = const FineCalculator(),
    Clock? clock,
    this.currentStudentId = 'S2024001',
  })  : _books = List<Book>.of(books),
        _loans = List<Loan>.of(loans),
        _policy = policy,
        _clock = clock ?? DateTime.now {
    _loanSequence = _loans.length;
  }

  final List<Book> _books;
  final List<Loan> _loans;
  final FineCalculator _policy;
  final Clock _clock;

  final String currentStudentId;

  DateTime? _simulatedToday;
  int _loanSequence = 0;

  String _bookQuery = '';
  BookFilter _bookFilter = BookFilter.all;
  String _loanQuery = '';
  LoanFilter _loanFilter = LoanFilter.all;

  DateTime get today => FineCalculator.dateOnly(_simulatedToday ?? _clock());

  bool get isDateSimulated => _simulatedToday != null;

  void setSimulatedDate(DateTime date) {
    _simulatedToday = FineCalculator.dateOnly(date);
    notifyListeners();
  }

  void resetDate() {
    if (_simulatedToday == null) return;
    _simulatedToday = null;
    notifyListeners();
  }

  int get loanPeriodDays => _policy.loanPeriodDays;

  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get loans => List.unmodifiable(_loans);

  List<Book> get availableBooks =>
      List.unmodifiable(_books.where((b) => b.isAvailable));

  List<Loan> get activeLoans =>
      List.unmodifiable(_loans.where((l) => l.isActive));

  List<Loan> get overdueLoans => List.unmodifiable(_loans.where(
      (l) => l.isActive && getOverdueStatus(l) == OverdueStatus.overdue));

  List<Loan> get missingLoans => List.unmodifiable(_loans.where(
      (l) => l.isActive && getOverdueStatus(l) == OverdueStatus.missing));

  Book? bookById(String id) {
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  String bookTitle(String bookId) => bookById(bookId)?.title ?? 'Unknown book';

  Loan? activeLoanForBook(String bookId) {
    for (final loan in _loans) {
      if (loan.bookId == bookId && loan.isActive) return loan;
    }
    return null;
  }

  bool canBorrow(Book book) =>
      book.isAvailable && activeLoanForBook(book.id) == null;

  DateTime _evaluationDate(Loan loan) {
    final returned = loan.returnDate;
    return returned != null ? FineCalculator.dateOnly(returned) : today;
  }

  // DIUBAH: status terlambat sekarang memakai aturan di FineCalculator
  OverdueStatus getOverdueStatus(Loan loan) {
    final asOf = _evaluationDate(loan);
    if (_policy.isMissing(loan.dueDate, asOf)) return OverdueStatus.missing;
    if (_policy.isOverdue(loan.dueDate, asOf)) return OverdueStatus.overdue;
    return OverdueStatus.onTime;
  }

  // DIUBAH: menggantikan completedOverdueWeeks (sekarang dalam hari)
  int overdueDaysOf(Loan loan) =>
      _policy.overdueDays(loan.dueDate, _evaluationDate(loan));

  int calculateFine(Loan loan) {
    return _policy.calculateFine(
      dueDate: loan.dueDate,
      asOf: _evaluationDate(loan),
      replacementPrice: bookById(loan.bookId)?.replacementPrice ?? 0,
    );
  }

  int outstandingFine(Loan loan) =>
      loan.isFineSettled ? 0 : calculateFine(loan);

  bool canSettle(Loan loan) => loan.isReturned && outstandingFine(loan) > 0;

  LoanStatus statusOfLoan(Loan loan) {
    if (loan.isReturned) return LoanStatus.returned;
    return switch (getOverdueStatus(loan)) {
      OverdueStatus.onTime => LoanStatus.borrowed,
      OverdueStatus.overdue => LoanStatus.overdue,
      OverdueStatus.missing => LoanStatus.missing,
    };
  }

  BookStatus statusOfBook(Book book) {
    if (book.isAvailable) return BookStatus.available;
    final loan = activeLoanForBook(book.id);
    if (loan == null) return BookStatus.borrowed;
    return switch (getOverdueStatus(loan)) {
      OverdueStatus.onTime => BookStatus.borrowed,
      OverdueStatus.overdue => BookStatus.overdue,
      OverdueStatus.missing => BookStatus.missing,
    };
  }

  int get totalOutstandingFines =>
      _loans.fold<int>(0, (sum, loan) => sum + outstandingFine(loan));

  FineSummary get fineSummary => FineSummary(
        totalOutstanding: totalOutstandingFines,
        activeLoans: activeLoans.length,
        overdueLoans: overdueLoans.length,
        missingLoans: missingLoans.length,
      );

  String get bookQuery => _bookQuery;
  BookFilter get bookFilter => _bookFilter;
  String get loanQuery => _loanQuery;
  LoanFilter get loanFilter => _loanFilter;

  void setBookQuery(String query) {
    if (query == _bookQuery) return;
    _bookQuery = query;
    notifyListeners();
  }

  void setBookFilter(BookFilter filter) {
    if (filter == _bookFilter) return;
    _bookFilter = filter;
    notifyListeners();
  }

  void setLoanQuery(String query) {
    if (query == _loanQuery) return;
    _loanQuery = query;
    notifyListeners();
  }

  void setLoanFilter(LoanFilter filter) {
    if (filter == _loanFilter) return;
    _loanFilter = filter;
    notifyListeners();
  }

  String _titleKey(Book b) =>
      '${b.title.trim().toLowerCase()}|${b.author.trim().toLowerCase()}';

  List<Book> get visibleBooks {
    final q = _bookQuery.trim().toLowerCase();
    return List.unmodifiable(_books.where((book) {
      final matchesQuery = q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.id.toLowerCase().contains(q);
      return matchesQuery && _matchesBookFilter(book);
    }));
  }

  List<BookGroup> get bookGroups {
    final grouped = <String, List<Book>>{};
    for (final book in visibleBooks) {
      grouped.putIfAbsent(_titleKey(book), () => []).add(book);
    }
    return [
      for (final copies in grouped.values)
        BookGroup(
          title: copies.first.title,
          author: copies.first.author,
          replacementPrice: copies.first.replacementPrice,
          copies: List.unmodifiable(copies),
        ),
    ];
  }

  int totalCopies(BookGroup group) {
    final key = _titleKey(group.copies.first);
    return _books.where((b) => _titleKey(b) == key).length;
  }

  int availableCount(BookGroup group) {
    final key = _titleKey(group.copies.first);
    return _books.where((b) => _titleKey(b) == key && b.isAvailable).length;
  }

  bool canBorrowGroup(BookGroup group) => availableCount(group) > 0;

  ActionResult borrowFromGroup(BookGroup group, String studentId) {
    final key = _titleKey(group.copies.first);
    final copy =
        _books.where((b) => _titleKey(b) == key && canBorrow(b)).firstOrNull;
    if (copy == null) {
      return ActionResult.failure('Stok "${group.title}" habis.');
    }
    return borrowBook(copy.id, studentId);
  }

  List<Loan> get visibleLoans {
    final q = _loanQuery.trim().toLowerCase();
    final result = _loans.where((loan) {
      final matchesQuery = q.isEmpty ||
          bookTitle(loan.bookId).toLowerCase().contains(q) ||
          loan.studentId.toLowerCase().contains(q) ||
          loan.id.toLowerCase().contains(q);
      return matchesQuery && _matchesLoanFilter(loan);
    }).toList()
      ..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.dueDate.compareTo(b.dueDate);
      });
    return List.unmodifiable(result);
  }

  bool _matchesBookFilter(Book book) {
    final status = statusOfBook(book);
    return switch (_bookFilter) {
      BookFilter.all => true,
      BookFilter.available => status == BookStatus.available,
      BookFilter.borrowed => status == BookStatus.borrowed,
      BookFilter.overdue => status == BookStatus.overdue,
      BookFilter.missing => status == BookStatus.missing,
    };
  }

  bool _matchesLoanFilter(Loan loan) {
    final status = statusOfLoan(loan);
    return switch (_loanFilter) {
      LoanFilter.all => true,
      LoanFilter.borrowed => status == LoanStatus.borrowed,
      LoanFilter.overdue => status == LoanStatus.overdue,
      LoanFilter.missing => status == LoanStatus.missing,
      LoanFilter.returned => status == LoanStatus.returned,
    };
  }

  ActionResult borrowBook(String bookId, String studentId) {
    final student = studentId.trim();
    if (student.isEmpty) {
      return const ActionResult.failure('Student ID is required.');
    }

    final bookIndex = _books.indexWhere((b) => b.id == bookId);
    if (bookIndex < 0) {
      return const ActionResult.failure('Book not found.');
    }

    final book = _books[bookIndex];
    if (!canBorrow(book)) {
      return ActionResult.failure(
          '"${book.title}" is not available: it already has an active loan.');
    }

    final borrowDate = today;
    final loan = Loan(
      id: _newLoanId(),
      bookId: book.id,
      studentId: student,
      borrowDate: borrowDate,
      dueDate: _policy.dueDateFor(borrowDate),
    );

    _loans.add(loan);
    _books[bookIndex] = book.copyWith(availability: BookAvailability.onLoan);
    notifyListeners();
    return ActionResult.success(
        '"${book.title}" borrowed by $student. Due on ${_formatDate(loan.dueDate)}.');
    }
    ActionResult returnBook(String loanId) {
    final loanIndex = _loans.indexWhere((l) => l.id == loanId);
    if (loanIndex < 0) {
      return const ActionResult.failure('Loan not found.');
    }

    final loan = _loans[loanIndex];
    if (loan.isReturned) {
      return const ActionResult.failure('This loan has already been returned.');
    }

    final returnDate = today;
    if (returnDate.isBefore(FineCalculator.dateOnly(loan.borrowDate))) {
      return const ActionResult.failure(
          'The return date cannot be earlier than the borrowing date.');
    }

    final returned = loan.copyWith(returnDate: returnDate);
    _loans[loanIndex] = returned;

    final bookIndex = _books.indexWhere((b) => b.id == loan.bookId);
    if (bookIndex >= 0) {
      _books[bookIndex] =
          _books[bookIndex].copyWith(availability: BookAvailability.available);
    }
    notifyListeners();

    final title = bookTitle(loan.bookId);
    final fine = outstandingFine(returned);
    if (fine == 0) {
      return ActionResult.success('"$title" returned. No fine.');
    }
    if (getOverdueStatus(returned) == OverdueStatus.missing) {
      return ActionResult.success(
          '"$title" returned after being declared missing. The replacement '
          'charge of ${_formatRupiah(fine)} stays outstanding until it is settled.');
    }
    return ActionResult.success(
        '"$title" returned. Overdue fine: ${_formatRupiah(fine)}.');
  }

  ActionResult settleFine(String loanId) {
    final loanIndex = _loans.indexWhere((l) => l.id == loanId);
    if (loanIndex < 0) {
      return const ActionResult.failure('Loan not found.');
    }
    final loan = _loans[loanIndex];
    if (!loan.isReturned) {
      return const ActionResult.failure(
          'Return the book before settling its charge.');
    }
    final amount = outstandingFine(loan);
    if (amount == 0) {
      return const ActionResult.failure('There is no outstanding charge.');
    }

    _loans[loanIndex] = loan.copyWith(isFineSettled: true);
    notifyListeners();
    return ActionResult.success('Charge of ${_formatRupiah(amount)} settled.');
  }

  String _newLoanId() {
    String id;
    do {
      _loanSequence++;
      id = 'L${_loanSequence.toString().padLeft(3, '0')}';
    } while (_loans.any((l) => l.id == id));
    return id;
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return 'Rp$buffer';
  }
}