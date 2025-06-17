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

  String selectedRole = 'user'; // default role

  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();
    final confirmPwd = confirmPwdController.text.trim();
    final aadhar = aadharController.text.trim();

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
            width: 400,
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
                _buildTextField(nameController, 'Name'),
                SizedBox(height: 16),
                _buildTextField(emailController, 'Email'),
                SizedBox(height: 16),
                _buildTextField(mobileController, 'Mobile'),
                SizedBox(height: 16),
                _buildTextField(addressController, 'Address'),
                SizedBox(height: 16),
                _buildTextField(aadharController, 'Aadhar'),
                SizedBox(height: 16),
                _buildTextField(passwordController, 'Password', obscure: true),
                SizedBox(height: 16),
                _buildTextField(confirmPwdController, 'Confirm Password', obscure: true),
                SizedBox(height: 16),
                _buildDropdownRole(),
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

  Widget _buildDropdownRole() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      items: ['user', 'admin'].map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(role[0].toUpperCase() + role.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRole = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Select Role',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
