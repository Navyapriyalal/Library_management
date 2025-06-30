import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:lms/services/image_picker.dart';
import 'package:lms/services/pocketbase_service.dart';

class ProfilePage extends StatefulWidget {
  final RecordModel user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late RecordModel currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      File file = File(picked.path);
      final uploadedUrl = await ImageKitService.uploadImage(file);

      if (uploadedUrl != null) {
        await PocketBaseService.pb.collection('users').update(currentUser.id, body: {
          "avatar": uploadedUrl,
        });

        setState(() {
          currentUser = currentUser..data['avatar'] = uploadedUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile picture updated!"),
          backgroundColor: Colors.green,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = currentUser.data['avatar'] ?? '';
    final name = currentUser.data['name'] ?? 'No name';
    final email = currentUser.data['email'] ?? 'No email';
    final mobile = currentUser.data['mobile'] ?? '-';
    final role = currentUser.data['role'] ?? '-';
    final gender = currentUser.data['gender'] ?? '-';
    final address = currentUser.data['address'] ?? '-';

    return Scaffold(
      body: SingleChildScrollView(
        padding: MediaQuery.of(context).size.width > 800
          ? const EdgeInsets.only(left: 100, right: 100, top: 25, bottom: 25)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundImage: avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : AssetImage(
                    gender.toLowerCase() == 'male'
                        ? 'assets/male.png'
                        : gender.toLowerCase() == 'female'
                        ? 'assets/female.jpg'
                        : 'assets/default_profile.png',
                  ) as ImageProvider,
                ),
                GestureDetector(
                  onTap: pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFF50057),
                    child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Divider(),
            _infoTile("Mobile", mobile),
            _infoTile("Role", role),
            _infoTile("Gender", gender),
            _infoTile("Address", address),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showEditDialog,
                  icon: Icon(Icons.edit,color: Colors.white,),
                  label: Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF50057),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => showChangePasswordDialog(context),
                  child: Text("Change Password"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF50057),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.info_outline),
      title: Text(title),
      subtitle: Text(value.isNotEmpty ? value : "Not provided"),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    final oldPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPwdController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Old Password'),
            ),
            TextField(
              controller: newPwdController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: confirmPwdController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF50057)),
            child: Text("Update", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final oldPwd = oldPwdController.text.trim();
              final newPwd = newPwdController.text.trim();
              final confirmPwd = confirmPwdController.text.trim();

              if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
                showError(context, "All fields are required.");
                return;
              }

              if (newPwd != confirmPwd) {
                showError(context, "New password and confirmation do not match.");
                return;
              }

              try {
                final pb = PocketBaseService.pb;
                final user = pb.authStore.model;

                await pb.collection('users').update(user.id, body: {
                  "oldPassword": oldPwd,
                  "password": newPwd,
                  "passwordConfirm": confirmPwd,
                });

                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Success"),
                    content: Text("Password changed successfully."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK", style: TextStyle(color: Color(0xFFF50057))),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                showError(context, "Failed to change password: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  void showError(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: currentUser.data['name'] ?? '');
    final mobileController = TextEditingController(text: currentUser.data['mobile'] ?? '');
    final addressController = TextEditingController(text: currentUser.data['address'] ?? '');
    final genderController = TextEditingController(text: currentUser.data['gender'] ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildInput("Name", nameController),
                _buildInput("Mobile", mobileController),
                _buildInput("Gender", genderController),
                _buildInput("Address", addressController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final body = {
                  'name': nameController.text.trim(),
                  'mobile': mobileController.text.trim(),
                  'gender': genderController.text.trim(),
                  'address': addressController.text.trim(),
                };

                final updatedUser = await PocketBaseService.pb
                    .collection('users')
                    .update(currentUser.id, body: body);

                setState(() {
                  currentUser = updatedUser;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Profile updated!"),
                  backgroundColor: Colors.green,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF50057),
                foregroundColor: Colors.white,
              ),
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

}
