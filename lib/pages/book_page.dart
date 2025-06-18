// book_page.dart
import 'package:flutter/material.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/models/user_model.dart';
import 'package:library_management/models/borrower_model.dart';

class BookPage extends StatefulWidget {
  final User user; // 👈 Add this

  const BookPage({Key? key, required this.user}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  void fetchBooks() async {
    final data = await DBHelper.getAllBooks();
    setState(() {
      books = data;
    });
  }

  void borrowBook(int bookId) async {
    final borrower = Borrower(
      bookId: bookId,
      userEmail: widget.user.email,
      deliveryDate: DateTime.now().toString().split(' ')[0],
      returnDate: '', // You can set a return date if you like
    );

    await DBHelper.insertBorrower(borrower);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Book borrowed successfully!')),
    );
  }



  void showBookForm({Book? book}) {
    final nameController = TextEditingController(text: book?.name ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    final genreController = TextEditingController(text: book?.genre ?? '');
    final languageController = TextEditingController(text: book?.language ?? '');
    final priceController = TextEditingController(text: book?.price?.toString() ?? '');
    final yearController = TextEditingController(text: book?.yearOfRelease?.toString() ?? '');
    final status = book?.status ?? 'available';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(book == null ? 'Add Book' : 'Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: authorController, decoration: InputDecoration(labelText: 'Author')),
              TextField(controller: genreController, decoration: InputDecoration(labelText: 'Genre')),
              TextField(controller: languageController, decoration: InputDecoration(labelText: 'Language')),
              TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: yearController, decoration: InputDecoration(labelText: 'Year of Release'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newBook = Book(
                id: book?.id,
                name: nameController.text,
                author: authorController.text,
                genre: genreController.text,
                language: languageController.text,
                price: double.tryParse(priceController.text),
                yearOfRelease: int.tryParse(yearController.text),
                status: status,
              );
              if (book == null) {
                await DBHelper.insertBook(newBook);
              } else {
                await DBHelper.updateBook(newBook);
              }
              fetchBooks();
              Navigator.pop(context);
            },
            child: Text(book == null ? 'Add' : 'Update'),
          )
        ],
      ),
    );
  }

  void deleteBook(int id) async {
    await DBHelper.deleteBook(id);
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Books List', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              if (widget.user.role.toLowerCase() == 'admin')
              ElevatedButton.icon(
                onPressed: () => showBookForm(),
                icon: Icon(Icons.add),
                label: Text('Add Book'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Author')),
                  DataColumn(label: Text('Genre')),
                  DataColumn(label: Text('Language')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Year')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: books.map((book) => DataRow(cells: [
                  DataCell(Text(book.id.toString())),
                  DataCell(Text(book.name)),
                  DataCell(Text(book.author)),
                  DataCell(Text(book.genre ?? '')),
                  DataCell(Text(book.language ?? '')),
                  DataCell(Text(book.price?.toString() ?? '')),
                  DataCell(Text(book.yearOfRelease?.toString() ?? '')),
                  DataCell(Text(book.status)),
                  DataCell(Row(
                    children: [
                      if (widget.user.role.toLowerCase() == 'admin') ...[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => showBookForm(book: book),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteBook(book.id!),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () => borrowBook(book.id!), // 👈 Create this function
                          child: Text("Borrow"),
                        ),
                      ]
                    ],
                  )),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
