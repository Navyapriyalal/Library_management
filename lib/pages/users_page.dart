import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final pb = PocketBaseService.pb;
  List<RecordModel> users = [];
  bool isLoading = true;
  String currentUserRole = 'member';
  TextEditingController searchController = TextEditingController();
  String? selectedRole;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final currentUser = pb.authStore.model;
    currentUserRole = currentUser?.data['role'] ?? 'member';
    await fetchUsers();
  }

  Future<void> fetchUsers({String keyword = ''}) async {
    final result = await pb.collection('users').getFullList();
    List<RecordModel> filtered = result;

    if (keyword.isNotEmpty) {
      filtered = filtered.where((u) =>
      (u.data['name'] ?? '').toLowerCase().contains(keyword.toLowerCase()) ||
          (u.data['email'] ?? '').toLowerCase().contains(keyword.toLowerCase()) ||
          (u.data['role'] ?? '').toLowerCase().contains(keyword.toLowerCase())
      ).toList();
    }

    if (selectedRole != null) {
      filtered = filtered.where((u) => u.data['role'] == selectedRole).toList();
    }
    if (selectedGender != null) {
      filtered = filtered.where((u) => u.data['gender'] == selectedGender).toList();
    }

    setState(() {
      users = currentUserRole == 'librarian'
          ? filtered.where((u) => u.data['role'] == 'member').toList()
          : filtered;
      isLoading = false;
    });
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Filter Users", style: TextStyle(color: Color(0xFFF50057))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(labelText: 'Role'),
              items: ['admin', 'librarian', 'member']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => selectedRole = val,
            ),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(labelText: 'Gender'),
              items: ['male', 'female', 'other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => selectedGender = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedRole = null;
                selectedGender = null;
              });
              fetchUsers(keyword: searchController.text);
            },
            child: Text("Reset"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              fetchUsers(keyword: searchController.text);
            },
            child: Text("Apply"),
          ),
        ],
      ),
    );
  }

  Future<void> changePassword(String id, String userName) async {
    try {
      final adminUser = dotenv.env['ADMINUSERNAME'];
      final adminPwd = dotenv.env['ADMINPASSWORD'];
      await pb.admins.authWithPassword(adminUser!, adminPwd!);

      await pb.collection('users').update(id, body: {
        "password": 'newPassword',
        "passwordConfirm": 'newPassword',
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Password Reset Successful"),
          content: Text("Password for **$userName** has been changed to:\n\nnewPassword"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Color(0xFFF50057))),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to reset password.\nError: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> deleteUser(String id) async {
    await pb.collection('users').delete(id);
    fetchUsers();
  }

  Future<void> showUserDialog({RecordModel? user}) async {
    final name = TextEditingController(text: user?.data['name']);
    final email = TextEditingController(text: user?.data['email']);
    final address = TextEditingController(text: user?.data['address']);
    final mobile = TextEditingController(text: user?.data['mobile']);
    String selectedRole = user?.data['role'] ?? 'member';
    String selectedGender = user?.data['gender'] ?? 'female';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(user == null ? "Add User" : "Edit User",
            style: TextStyle(color: Color(0xFFF50057))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(name, 'Name'),
              if (user == null) _buildTextField(email, 'Email'),
              _buildTextField(address, 'Address'),
              _buildTextField(mobile, 'Mobile'),
              if (currentUserRole != 'librarian')
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: ['admin', 'librarian', 'member']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => selectedRole = val ?? 'member',
                ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['male', 'female', 'other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => selectedGender = val ?? 'female',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF50057),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final body = {
                "name": name.text.trim(),
                "email": email.text.trim(),
                "address": address.text.trim(),
                "mobile": mobile.text.trim(),
                "role": selectedRole,
                "gender": selectedGender,
              };

              if (user == null) {
                body["password"] = "default123";
                body["passwordConfirm"] = "default123";
                await pb.collection('users').create(body: body);
              } else {
                await pb.collection('users').update(user.id, body: body);
              }

              Navigator.pop(context);
              fetchUsers();
            },
            child: Text(user == null ? "Add" : "Save",style: TextStyle(color: Colors.white),),
          ),
          ElevatedButton(
              onPressed: () async {
                await changePassword(user!.id, user.data['name']);
              },
              child: Text("Change Password",))
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, index) {
        final user = users[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(user.data['name'] ?? 'Unknown'),
            subtitle: Text(
              currentUserRole == 'librarian'
                  ? "Email: ${user.data['email']}"
                  : "Email: ${user.data['email']} | Role: ${user.data['role']}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFFF50057)),
                    onPressed: () => showUserDialog(user: user)),
                IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteUser(user.id)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableView() {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return Scrollbar(
      controller: verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: verticalController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          controller: horizontalController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xFFF50057).withOpacity(0.2)),
              columnSpacing: 20,
              columns: [
                const DataColumn(label: Text("Name")),
                const DataColumn(label: Text("Email")),
                if (currentUserRole != 'librarian')
                  const DataColumn(label: Text("Role")),
                const DataColumn(label: Text("Gender")),
                const DataColumn(label: Text("Mobile")),
                const DataColumn(label: Text("Address")),
                const DataColumn(label: Text("Actions")),
              ],
              rows: users.map((user) {
                return DataRow(cells: [
                  DataCell(Text(user.data['name'] ?? '')),
                  DataCell(Text(user.data['email'] ?? '')),
                  if (currentUserRole != 'librarian')
                    DataCell(Text(user.data['role'] ?? '')),
                  DataCell(Text(user.data['gender'] ?? '')),
                  DataCell(Text(user.data['mobile'] ?? '')),
                  DataCell(Text(user.data['address'] ?? '')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Color(0xFFF50057)),
                        onPressed: () => showUserDialog(user: user),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteUser(user.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFF50057)))
        : Padding(
      padding: isWideScreen
          ? const EdgeInsets.only(left: 100, right: 100, top: 50, bottom: 25)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;

              return isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) => fetchUsers(keyword: value),
                    decoration: InputDecoration(
                      hintText: "Search by name, email, role...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Reset Filters',
                        onPressed: () {
                          setState(() {
                            selectedRole = null;
                            selectedGender = null;
                          });
                          fetchUsers(keyword: searchController.text);
                        },
                        icon: Icon(Icons.refresh, color: Color(0xFFF50057)),
                      ),
                      ElevatedButton.icon(
                        onPressed: showFilterDialog, // Define this
                        icon: Icon(Icons.filter_list, color: Colors.white),
                        label: Text("Filter", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF50057),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (currentUserRole != 'member')
                        ElevatedButton.icon(
                          onPressed: () => showUserDialog(),
                          icon: Icon(Icons.person_add, color: Colors.white),
                          label: Text("Add User", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF50057),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                    ],
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => fetchUsers(keyword: value),
                      decoration: InputDecoration(
                        hintText: "Search by name, email, role...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Reset Filters',
                    onPressed: () {
                      setState(() {
                        selectedRole = null;
                        selectedGender = null;
                      });
                      fetchUsers(keyword: searchController.text);
                    },
                    icon: Icon(Icons.refresh, color: Color(0xFFF50057)),
                  ),
                  ElevatedButton.icon(
                    onPressed: showFilterDialog, // Define this
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    label: Text("Filter", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF50057),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(width: 10),
                  if (currentUserRole != 'member')
                    ElevatedButton.icon(
                      onPressed: () => showUserDialog(),
                      icon: Icon(Icons.person_add, color: Colors.white),
                      label: Text("Add User", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF50057),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: screenWidth < 800 ? _buildCardView() : _buildTableView(),
          ),
        ],
      ),
    );
  }
}
