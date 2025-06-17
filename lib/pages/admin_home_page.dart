import 'package:flutter/material.dart';
import 'book_page.dart';
import 'borrower_page.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Library Admin Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Borrowers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookPage(),
            BorrowerPage(),
          ],
        ),
      ),
    );
  }
}
