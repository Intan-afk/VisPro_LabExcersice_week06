/// Whether a book is on the shelf or currently out on loan.
///
/// The richer statuses shown in the UI (Borrowed / Overdue / Missing) depend on
/// the current date, so they are derived by the ViewModel, not stored here.
enum BookAvailability { available, onLoan }

/// A book in the library catalogue. Pure data: no widgets, no BuildContext.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.replacementPrice,
    this.availability = BookAvailability.available,
  });

  final String id;
  final String title;
  final String author;

  /// Price (in Rupiah) charged when the book is declared Missing.
  final int replacementPrice;

  final BookAvailability availability;

  bool get isAvailable => availability == BookAvailability.available;

  Book copyWith({BookAvailability? availability}) {
    return Book(
      id: id,
      title: title,
      author: author,
      replacementPrice: replacementPrice,
      availability: availability ?? this.availability,
    );
  }

    factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      replacementPrice: json['replacementPrice'] as int,
    );
  }
}
