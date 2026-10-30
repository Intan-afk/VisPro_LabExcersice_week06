class FineCalculator {
  const FineCalculator({
    this.freeDays = 0,
    this.baseDailyRate = 5000,
    this.maxDailyRate = 15000,
    this.loanPeriodDays = 6,
    this.missingAfterMonths = 6,
  });

  final int freeDays;
  final int baseDailyRate;
  final int maxDailyRate;
  final int loanPeriodDays;
  final int missingAfterMonths;
  static const int daysPerWeek = 7;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime addDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

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

  DateTime dueDateFor(DateTime borrowDate) =>
      addDays(dateOnly(borrowDate), loanPeriodDays);

  DateTime missingDateFor(DateTime dueDate) =>
      addMonths(dateOnly(dueDate), missingAfterMonths);

  int overdueDays(DateTime dueDate, DateTime asOf) {
    final days = daysBetween(dueDate, asOf);
    return days > 0 ? days : 0;
  }

  bool isInGracePeriod(DateTime dueDate, DateTime asOf) {
    final days = overdueDays(dueDate, asOf);
    return days > 0 && days <= freeDays;
  }

  bool isOverdue(DateTime dueDate, DateTime asOf) {
    return overdueDays(dueDate, asOf) > freeDays;
  }

  bool isMissing(DateTime dueDate, DateTime asOf) {
    return !dateOnly(asOf).isBefore(missingDateFor(dueDate));
  }

  int dailyRate(int fineDay) {
    final week = (fineDay - 1) ~/ daysPerWeek + 1;
    final rate = baseDailyRate * week;
    return rate > maxDailyRate ? maxDailyRate : rate;
  }

  int fineForOverdueDays(int lateDays) {
    final fineDays = lateDays - freeDays;
    if (fineDays <= 0) return 0;
    var total = 0;
    for (var d = 1; d <= fineDays; d++) {
      total += dailyRate(d);
    }
    return total;
  }

  int lateFine({required DateTime dueDate, required DateTime asOf}) {
    final missingDate = missingDateFor(dueDate);
    final end = isMissing(dueDate, asOf) ? missingDate : asOf;
    return fineForOverdueDays(overdueDays(dueDate, end));
  }

  int calculateFine({
    required DateTime dueDate,
    required DateTime asOf,
    required int replacementPrice,
  }) {
    final fine = lateFine(dueDate: dueDate, asOf: asOf);
    return isMissing(dueDate, asOf) ? fine + replacementPrice : fine;
  }

  String fineLabel({
    required DateTime dueDate,
    required DateTime asOf,
    required int replacementPrice,
  }) {
    final fine = calculateFine(
      dueDate: dueDate,
      asOf: asOf,
      replacementPrice: replacementPrice,
    );
    final days = overdueDays(dueDate, asOf);
    if (isMissing(dueDate, asOf)) {
      return 'Denda: Rp$fine (buku hilang, $days hari terlambat)';
    }
    return 'Denda: Rp$fine ($days hari terlambat)';
  }
}