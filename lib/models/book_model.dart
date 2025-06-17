class Book {
  int? id;
  String name;
  String author;
  String? genre;
  String? language;
  double? price;
  int? yearOfRelease;
  String status; // 'available' or 'unavailable'

  Book({
    this.id,
    required this.name,
    required this.author,
    this.genre,
    this.language,
    this.price,
    this.yearOfRelease,
    this.status = 'available',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'genre': genre,
      'language': language,
      'price': price,
      'year_of_release': yearOfRelease,
      'status': status,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      author: map['author'],
      genre: map['genre'],
      language: map['language'],
      price: map['price']?.toDouble(),
      yearOfRelease: map['year_of_release'],
      status: map['status'],
    );
  }
}
