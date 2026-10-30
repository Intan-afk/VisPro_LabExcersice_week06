/// Status of a book as shown in the catalogue.
enum BookStatus { available, borrowed, overdue, missing }

/// How late a loan is, evaluated at "today" (active loan) or at the return
/// date (returned loan).
enum OverdueStatus { onTime, overdue, missing }

/// Status of a loan as shown in the "Borrowed" list.
enum LoanStatus { borrowed, overdue, missing, returned }
