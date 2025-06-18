import 'package:flutter/material.dart';
import 'book_page.dart';
import 'user_book_page.dart';
import 'profile_page.dart';
import 'package:library_management/models/user_model.dart';

class UserHomePage extends StatelessWidget {

  final User user;

  UserHomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Library User Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Your Books'),
              Tab(text: 'Profile',)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookPage(user: user,),
            YourBooksPage(userEmail: user.email,),
            ProfilePage(user:user),
          ],
        ),
      ),
    );
  }
}
