import 'book.dart';
import 'loan.dart';
import 'library_service.dart';

class LibraryRepository {
  final LibraryService _service;

  LibraryRepository({LibraryService? service})
      : _service = service ?? LibraryService();

  Future<void> init() => _service.init();

  List<Book> getBooks() => _service.readBooks();
  void saveBooks(List<Book> books) => _service.writeBooks(books);
  List<Loan> getLoans() => _service.readLoans();
  void saveLoans(List<Loan> loans) => _service.writeLoans(loans);
}