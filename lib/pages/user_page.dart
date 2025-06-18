import 'package:flutter/material.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/models/user_model.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    final data = await DBHelper.getAllUsers();
    setState(() {
      users = data;
    });
  }

  void showUserForm({User? user}) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final mobileController = TextEditingController(text: user?.mobile ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');
    final passwordController = TextEditingController(text: user?.password ?? '');
    final roleController = TextEditingController(text: user?.role ?? '');
    final profileController = TextEditingController(text: user?.profile ?? '');
    final aadharController = TextEditingController(text: user?.aadhar ?? '');
    final genderController = TextEditingController(text: user?.gender ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: mobileController, decoration: InputDecoration(labelText: 'Mobile')),
              TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
              TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password')),
              TextField(controller: roleController, decoration: InputDecoration(labelText: 'Role')),
              TextField(controller: profileController, decoration: InputDecoration(labelText: 'Profile')),
              TextField(controller: aadharController, decoration: InputDecoration(labelText: 'Aadhar')),
              TextField(controller: genderController, decoration: InputDecoration(labelText: 'Gender')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newUser = User(
                id: user?.id,
                name: nameController.text,
                email: emailController.text,
                mobile: mobileController.text,
                address: addressController.text,
                password: passwordController.text,
                role: roleController.text,
                profile: profileController.text,
                aadhar: aadharController.text,
                gender: genderController.text,
              );
              if (user == null) {
                await DBHelper.insertUser(newUser);
              } else {
                await DBHelper.updateUser(newUser);
              }
              fetchUsers();
              Navigator.pop(context);
            },
            child: Text(user == null ? 'Add' : 'Update'),
          )
        ],
      ),
    );
  }

  void deleteUser(int id) async {
    await DBHelper.deleteUser(id);
    fetchUsers();
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
              Text('Users List', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => showUserForm(),
                icon: Icon(Icons.add),
                label: Text('Add User'),
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
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Mobile')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Gender')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((user) => DataRow(cells: [
                  DataCell(Text(user.id.toString())),
                  DataCell(Text(user.name)),
                  DataCell(Text(user.email)),
                  DataCell(Text(user.mobile)),
                  DataCell(Text(user.address)),
                  DataCell(Text(user.gender)),
                  DataCell(Text(user.role)),
                  DataCell(Row(
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => showUserForm(user: user)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => deleteUser(user.id!)),
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
