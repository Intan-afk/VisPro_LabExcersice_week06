class FineCalculator {
  const FineCalculator({
    this.weeklyFine = 5000,
    this.loanPeriodDays = 14,
    this.missingAfterMonths = 6,
  });

  final int weeklyFine;
  final int loanPeriodDays;
  final int missingAfterMonths;
  static const int daysPerWeek = 7;
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

  static DateTime addMonths(DateTime d, int months) {
    final total = d.year * 12 + (d.month - 1) + months;
    final year = total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day > lastDay ? lastDay : d.day);
  }

  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  DateTime dueDateFor(DateTime borrowDate) => addDays(dateOnly(borrowDate), loanPeriodDays);

  DateTime missingDateFor(DateTime dueDate) => addMonths(dateOnly(dueDate), missingAfterMonths);

  int completedOverdueWeeks(DateTime dueDate, DateTime asOf) {
    final overdueDays = daysBetween(dueDate, asOf);
    if (overdueDays <= 0) return 0;
    return overdueDays ~/ daysPerWeek;
  }

  bool isMissing(DateTime dueDate, DateTime asOf) {
    return !dateOnly(asOf).isBefore(missingDateFor(dueDate));
  }

  int calculateFine({
    required DateTime dueDate,
    required DateTime asOf,
    required int replacementPrice,
  }) {
    if (isMissing(dueDate, asOf)) return replacementPrice;
    return completedOverdueWeeks(dueDate, asOf) * weeklyFine;
  }
}
