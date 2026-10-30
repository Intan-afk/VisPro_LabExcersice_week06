import 'package:flutter_test/flutter_test.dart';
import 'package:perpustakaan/viewmodels/fine_calculator.dart';

void main() {
  const calc = FineCalculator();
  const price = 100000;

  // Dipinjam 30 Okt 2026 -> jatuh tempo 5 Nov 2026 (6 hari).
  final borrow = DateTime(2026, 10, 30);
  final due = DateTime(2026, 11, 5);

  int fineOn(DateTime asOf) => calc.calculateFine(
        dueDate: due,
        asOf: asOf,
        replacementPrice: price,
      );

  group('jatuh tempo', () {
    test('dueDateFor = tanggal pinjam + loanPeriodDays', () {
      expect(calc.dueDateFor(borrow), due);
    });

    test('tepat di jatuh tempo: belum terlambat, denda 0', () {
      expect(calc.overdueDays(due, due), 0);
      expect(calc.isOverdue(due, due), isFalse);
      expect(fineOn(due), 0);
    });

    test('sebelum jatuh tempo: denda 0', () {
      final early = DateTime(2026, 11, 1);
      expect(calc.overdueDays(due, early), 0);
      expect(fineOn(early), 0);
    });

    test('jam di dalam hari yang sama tidak mengubah hasil', () {
      expect(calc.overdueDays(due, DateTime(2026, 11, 5, 23, 59)), 0);
      expect(calc.overdueDays(due, DateTime(2026, 11, 6, 0, 1)), 1);
    });
  });

  group('tarif harian naik tiap minggu', () {
    test('hari terlambat ke-1 = Rp5.000', () {
      final asOf = DateTime(2026, 11, 6);
      expect(calc.isOverdue(due, asOf), isTrue);
      expect(calc.overdueDays(due, asOf), 1);
      expect(fineOn(asOf), 5000);
    });

    test('minggu pertama penuh (7 hari) = 7 x 5.000', () {
      expect(fineOn(DateTime(2026, 11, 12)), 35000);
    });

    test('hari ke-8 masuk tarif minggu kedua (10.000)', () {
      expect(fineOn(DateTime(2026, 11, 13)), 35000 + 10000);
    });

    test('minggu kedua penuh (14 hari)', () {
      expect(fineOn(DateTime(2026, 11, 19)), 35000 + 7 * 10000);
    });

    test('hari ke-15 masuk tarif minggu ketiga (15.000)', () {
      expect(fineOn(DateTime(2026, 11, 20)), 105000 + 15000);
    });

    test('minggu ketiga penuh (21 hari)', () {
      expect(fineOn(DateTime(2026, 11, 26)), 105000 + 7 * 15000);
    });

    test('tarif berhenti di maxDailyRate', () {
      expect(calc.dailyRate(1), 5000);
      expect(calc.dailyRate(8), 10000);
      expect(calc.dailyRate(15), 15000);
      expect(calc.dailyRate(100), 15000);
    });
  });

  group('masa bebas denda (freeDays)', () {
    const withGrace = FineCalculator(freeDays: 6);

    test('1-6 hari terlambat: denda 0 dan belum dianggap terlambat', () {
      expect(withGrace.fineForOverdueDays(6), 0);
      expect(withGrace.isInGracePeriod(due, DateTime(2026, 11, 11)), isTrue);
      expect(withGrace.isOverdue(due, DateTime(2026, 11, 11)), isFalse);
    });

    test('hari ke-7 mulai kena denda Rp5.000', () {
      expect(withGrace.fineForOverdueDays(7), 5000);
      expect(withGrace.isOverdue(due, DateTime(2026, 11, 12)), isTrue);
    });
  });

  group('batas enam bulan (hilang)', () {
    // Jatuh tempo 5 Nov 2026 -> dianggap hilang 5 Mei 2027.
    final missingDate = DateTime(2027, 5, 5);

    test('missingDateFor = jatuh tempo + 6 bulan', () {
      expect(calc.missingDateFor(due), missingDate);
    });

    test('sehari sebelum batas: belum hilang, tanpa harga buku', () {
      final asOf = DateTime(2027, 5, 4);
      expect(calc.isMissing(due, asOf), isFalse);
      expect(calc.overdueDays(due, asOf), 180);
      expect(fineOn(asOf), 2595000); // 210.000 + 159 x 15.000
    });

    test('tepat di batas: hilang, denda 6 bulan + harga buku', () {
      expect(calc.isMissing(due, missingDate), isTrue);
      expect(calc.overdueDays(due, missingDate), 181);
      expect(fineOn(missingDate), 2610000 + price); // 210.000 + 160 x 15.000
    });

    test('setelah hilang, denda berhenti bertambah', () {
      expect(fineOn(DateTime(2027, 6, 5)), fineOn(missingDate));
      expect(fineOn(DateTime(2028, 1, 1)), fineOn(missingDate));
    });

    test('akhir bulan: 31 Agt + 6 bulan = 28 Feb (tahun biasa)', () {
      expect(
        calc.missingDateFor(DateTime(2026, 8, 31)),
        DateTime(2027, 2, 28),
      );
    });
  });
}