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
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Logout Confirmation"),
                    content: Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Cancel
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text("Logout", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
