import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'book.dart';
import 'loan.dart';

class LibraryService {
  static const String _booksAsset = 'assets/data/books.json';

  static final List<Book> _books = [];
  static final List<Loan> _loans = [];
  static bool _loaded = false;

  Future<void> init() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(_booksAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['books'] as List<dynamic>;

    _books.clear();
    for (final item in list) {
      final json = item as Map<String, dynamic>;
      final quantity = (json['quantity'] as int?) ?? 1;
      for (var i = 1; i <= quantity; i++) {
        _books.add(Book.fromJson({...json, 'id': '${json['id']}-$i'}));
      }
    }
    _loaded = true;
  }

  List<Book> readBooks() => List.of(_books);

  void writeBooks(List<Book> books) {
    final copy = List.of(books);
    _books
      ..clear()
      ..addAll(copy);
  }

  List<Loan> readLoans() => List.of(_loans);

  void writeLoans(List<Loan> loans) {
    final copy = List.of(loans);
    _loans
      ..clear()
      ..addAll(copy);
  }
}