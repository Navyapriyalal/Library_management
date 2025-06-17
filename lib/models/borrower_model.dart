class Borrower {
  int? id;
  int bookId;
  String userEmail;
  String deliveryDate;
  String returnDate;

  Borrower({
    this.id,
    required this.bookId,
    required this.userEmail,
    required this.deliveryDate,
    required this.returnDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'user_email': userEmail,
      'delivery_date': deliveryDate,
      'return_date': returnDate,
    };
  }

  factory Borrower.fromMap(Map<String, dynamic> map) {
    return Borrower(
      id: map['id'],
      bookId: map['book_id'],
      userEmail: map['user_email'],
      deliveryDate: map['delivery_date'],
      returnDate: map['return_date'],
    );
  }
}
