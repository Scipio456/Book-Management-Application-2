class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String pdfUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.pdfUrl,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
    );
  }
}