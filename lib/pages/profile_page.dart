import 'package:flutter/material.dart';
import 'package:library_management/models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst); // Go back to login page
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.profile != null && user.profile!.isNotEmpty
                  ? NetworkImage(user.profile!)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(user.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email, style: TextStyle(fontSize: 16, color: Colors.grey)),

            Divider(height: 20),

            infoTile("Mobile", user.mobile),
            infoTile("Address", user.address),
            infoTile("Role", user.role),
            infoTile("Aadhar", user.aadhar),
          ],
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value.isNotEmpty ? value : "Not provided"),
      leading: Icon(Icons.info_outline),
    );
  }
}
