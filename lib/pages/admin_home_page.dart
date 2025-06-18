import 'package:flutter/material.dart';
import 'book_page.dart';
import 'borrower_page.dart';
import 'user_page.dart';
import 'package:library_management/models/user_model.dart';
import 'dashboard.dart';
import 'profile_page.dart';

class AdminHomePage extends StatelessWidget {
  final User user;

  AdminHomePage({required this.user});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Library Admin Dashboard'),
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
                          backgroundColor: Colors.redAccent,
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
              Tab(text: 'Dashboard',),
              Tab(text: 'Books'),
              Tab(text: 'Borrowers'),
              Tab(text: 'Users'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookDashboardWidget(),
            BookPage(user: user,),
            BorrowerPage(),
            UserPage(),
            ProfilePage(user: user),
          ],
        ),
      ),
    );
  }
}
