import 'package:flutter/material.dart';
import 'book_page.dart';
import 'borrower_page.dart';
import 'user_page.dart';
import 'package:library_management/models/user_model.dart';

class AdminHomePage extends StatelessWidget {
  final User user;

  AdminHomePage({required this.user});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Library Admin Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Borrowers'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookPage(user: user,),
            BorrowerPage(),
            UserPage(),
          ],
        ),
      ),
    );
  }
}
