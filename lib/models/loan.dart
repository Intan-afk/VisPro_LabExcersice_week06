/// One borrowing record. Pure data: no widgets, no BuildContext.
///
/// It stores everything needed to compute the deadline and the fine without
/// relying on any widget state: borrow date, due date, and (once returned)
/// the return date.
class Loan {
  const Loan({
    required this.id,
    required this.bookId,
    required this.studentId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.isFineSettled = false,
  });

  final String id;
  final String bookId;
  final String studentId;
  final DateTime borrowDate;
  final DateTime dueDate;

  /// `null` while the loan is still active.
  final DateTime? returnDate;

  /// True once the library has collected or waived the outstanding charge.
  final bool isFineSettled;

  bool get isReturned => returnDate != null;
  bool get isActive => returnDate == null;

  Loan copyWith({DateTime? returnDate, bool? isFineSettled}) {
    return Loan(
      id: id,
      bookId: bookId,
      studentId: studentId,
      borrowDate: borrowDate,
      dueDate: dueDate,
      returnDate: returnDate ?? this.returnDate,
      isFineSettled: isFineSettled ?? this.isFineSettled,
    );
  }
}
