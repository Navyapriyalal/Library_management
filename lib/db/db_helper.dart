import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:library_management/models/user_model.dart';
import 'package:library_management/models/book_model.dart';
import 'package:library_management/models/borrower_model.dart';

class DBHelper {
  static Database? _db;

  static Future<void> initDb() async {
    sqfliteFfiInit(); // Required for desktop
    var databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, 'library.db');

    _db = await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            mobile TEXT,
            address TEXT,
            password TEXT,
            role TEXT,
            profile TEXT,
            aadhar TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            author TEXT NOT NULL,
            genre TEXT,
            language TEXT,
            price REAL,
            year_of_release INTEGER,
            status TEXT CHECK(status IN ('available', 'unavailable')) DEFAULT 'available'
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS borrowers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            user_email TEXT,
            delivery_date TEXT,
            return_date TEXT,
            FOREIGN KEY(book_id) REFERENCES books(id),
            FOREIGN KEY(user_email) REFERENCES users(email)
          )
        ''');
      },
    ));
  }

  // ===================== USERS =====================

  static Future<int> insertUser(User user) async {
    return await _db!.insert('users', user.toMap());
  }

  static Future<User?> loginUser(String email, String password) async {
    final result = await _db!.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  static Future<List<User>> getAllUsers() async {
    final result = await _db!.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  // ===================== BOOKS =====================

  static Future<int> insertBook(Book book) async {
    return await _db!.insert('books', book.toMap());
  }

  static Future<List<Book>> getAllBooks() async {
    final result = await _db!.query('books');
    return result.map((e) => Book.fromMap(e)).toList();
  }

  static Future<int> updateBook(Book book) async {
    return await _db!.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  static Future<int> deleteBook(int id) async {
    return await _db!.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // ===================== BORROWERS =====================

  static Future<int> insertBorrower(Borrower borrower) async {
    return await _db!.insert('borrowers', borrower.toMap());
  }

  static Future<List<Borrower>> getAllBorrowers() async {
    final result = await _db!.query('borrowers');
    return result.map((e) => Borrower.fromMap(e)).toList();
  }

  static Future<List<Borrower>> getBorrowedBooksByUser(String email) async {
    final result = await _db!.query(
      'borrowers',
      where: 'user_email = ?',
      whereArgs: [email],
    );
    return result.map((e) => Borrower.fromMap(e)).toList();
  }
  static Future<void> updateBorrower(Borrower borrower) async {
    await _db!.update(
      'borrowers',
      borrower.toMap(),
      where: 'id = ?',
      whereArgs: [borrower.id],
    );
  }

  static Future<void> deleteBorrower(int id) async {
    await _db!.delete(
      'borrowers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
