import 'package:flutter/material.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/models/user_model.dart';

class YourBooksPage extends StatefulWidget {
  final String userEmail;

  YourBooksPage({required this.userEmail});

  @override
  State<YourBooksPage> createState() => _YourBooksPageState();
}

class _YourBooksPageState extends State<YourBooksPage> {
  List<Book> userBooks = [];

  @override
  void initState() {
    super.initState();
    fetchUserBooks();
  }

  void fetchUserBooks() async {
    final books = await DBHelper.getBooksForUser(widget.userEmail);
    setState(() {
      userBooks = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Borrowed Books")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userBooks.isEmpty
            ? Center(child: Text("No books borrowed yet!"))
            : ListView.builder(
          itemCount: userBooks.length,
          itemBuilder: (context, index) {
            final book = userBooks[index];
            return Card(
              child: ListTile(
                title: Text(book.name),
                subtitle: Text("Author: ${book.author}\nStatus: ${book.status}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
