import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_management/models/user_model.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/services/imagekit_service.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User currentUser;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final uploadedUrl = await ImageKitService.uploadImage(file);
      print(uploadedUrl);

      if (uploadedUrl != null) {
        print('inside fucntion');
        await DBHelper.updateUserProfileImage(currentUser.email, uploadedUrl);

        setState(() {
          currentUser = currentUser.copyWith(profile: uploadedUrl);
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Profile picture updated!"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: currentUser.profile != null && currentUser.profile!.isNotEmpty
                      ? NetworkImage(currentUser.profile!)
                      : AssetImage(
                    currentUser.gender.toLowerCase() == 'male'
                        ? 'assets/male.png'
                        : currentUser.gender.toLowerCase() == 'female'
                        ? 'assets/female.jpg'
                        : 'assets/default_profile.png',
                  ) as ImageProvider,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            Text(currentUser.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(currentUser.email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            Divider(height: 10),
            infoTile("Mobile", currentUser.mobile),
            infoTile("Address", currentUser.address),
            infoTile("Role", currentUser.role),
            infoTile("Aadhar", currentUser.aadhar),
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
