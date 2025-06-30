import 'package:flutter/material.dart';
import 'package:lms/services/auth_service.dart';
import 'package:lms/pages/admin_home_page.dart';
import 'lib_home_page.dart';
import 'member_home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool isLoading = false;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    try {
      setState(() => isLoading = true);
      final result = await auth.login(email, password);
      final role = result.record.data['role'] as String;

      if (!mounted) return;
      setState(() => isLoading = false);

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomePage(user: result.record),
          ),
        );
      } else if (role == 'librarian') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LibHomePage(user: result.record),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MemberHomePage(user: result.record),
          ),
        );
      }

    } catch (e) {
      setState(() => isLoading = false);
      emailController.clear();
      passwordController.clear();
      _showError('Invalid email or password');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFFF50057))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 700;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 900),
              padding: EdgeInsets.all(30),
              child: isWideScreen
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Image.asset(
                        'assets/login_image.png',
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(child: _buildLoginForm()),
                ],
              )
                  : _buildLoginForm(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      height: 500,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Library Login',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF50057),
            ),
          ),
          SizedBox(height: 20),
          _buildTextField(emailController, 'Email'),
          SizedBox(height: 16),
          _buildTextField(passwordController, 'Password', obscure: true),
          SizedBox(height: 24),
          isLoading
              ? CircularProgressIndicator(color: Color(0xFFF50057))
              : ElevatedButton(
            onPressed: login,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Color(0xFFF50057),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text(
              "Don't have an account? Register",
              style: TextStyle(color: Color(0xFFF50057)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
