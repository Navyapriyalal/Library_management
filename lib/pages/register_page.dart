import 'package:flutter/material.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/models/user_model.dart';
import 'package:library_management/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPwdController = TextEditingController();
  final aadharController = TextEditingController();
  final genderController = TextEditingController();

  String selectedRole = 'user'; // default role
  String selectedGender = 'Male';

  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();
    final confirmPwd = confirmPwdController.text.trim();
    final aadhar = aadharController.text.trim();
    final gender = genderController.text.trim();

    if ([name, email, mobile, address, password, confirmPwd, aadhar].any((e) => e.isEmpty)) {
      _showError('All fields are required');
      return;
    }

    if (password != confirmPwd) {
      _showError('Passwords do not match');
      return;
    }

    try {
      final user = User(
        name: name,
        email: email,
        mobile: mobile,
        address: address,
        password: password,
        role: selectedRole,
        profile: '', // you’ll handle profile later
        aadhar: aadhar,
        gender: gender,
      );

      await DBHelper.insertUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered! Please login.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } catch (e) {
      _showError('Email already exists or registration failed');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Registration Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24),
            width: 600,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Register',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent)),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildTextField(nameController, 'Name')),
                    SizedBox(width: 16),
                    Expanded(child: _buildTextField(emailController, 'Email')),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(mobileController, 'Mobile')),
                    SizedBox(width: 16),
                    Expanded(child: _buildTextField(aadharController, 'Aadhar')),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        items: ['Male', 'Female'],
                        selectedValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                        labelText: 'Gender',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        items: ['user', 'admin'],
                        selectedValue: selectedRole,
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        labelText: 'Role',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    Expanded(child: _buildTextField(passwordController, 'Password', obscure: true)),
                    SizedBox(width: 16),
                    Expanded(child: _buildTextField(confirmPwdController, 'Confirm Password', obscure: true)),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Register', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: Text("Already have an account? Login"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
    required String labelText,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item[0].toUpperCase() + item.substring(1)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
