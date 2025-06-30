import 'package:flutter/material.dart';
import 'package:lms/services/auth_service.dart';
import 'login_page.dart';
//import '../services/seeder.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final auth = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();

  String selectedGender = 'male';

  bool isLoading = false;

  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final address = addressController.text.trim();
    final mobile = mobileController.text.trim();
    final gender = selectedGender;

    if ([name, email, password, confirmPassword, address, mobile].any((e) => e.isEmpty)) {
      _showError('Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    try {
      setState(() => isLoading = true);
      await auth.signup(email, password, name, gender, address, mobile);
      if (!mounted) return;
      setState(() => isLoading = false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Registration failed. Try again.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
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

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 6.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((e) {
          return DropdownMenuItem<T>(
            value: e,
            child: Text(e.toString()),
          );
        }).toList(),
        onChanged: onChanged,
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
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Library Registration',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF50057),
                  ),
                ),
                SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 500;
                    return isMobile
                        ? Column(
                      children: [
                        _buildTextField(nameController, 'Name'),
                        SizedBox(height: 12),
                        _buildTextField(emailController, 'Email'),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(child: _buildTextField(nameController, 'Name')),
                        Expanded(child: _buildTextField(emailController, 'Email')),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),


                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 500;
                    return isMobile
                        ? Column(
                      children: [
                        _buildTextField(passwordController, 'Password', obscure: true),
                        SizedBox(height: 12),
                        _buildTextField(confirmPasswordController, 'Confirm Password', obscure: true),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(child: _buildTextField(passwordController, 'Password', obscure: true)),
                        Expanded(child: _buildTextField(confirmPasswordController, 'Confirm Password', obscure: true)),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),

                // Row 3: Role & Gender
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 500;
                    return isMobile
                        ? Column(
                      children: [
                        SizedBox(height: 12),
                        _buildDropdown<String>(
                          label: 'Gender',
                          value: selectedGender,
                          items: ['male', 'female', 'other'],
                          onChanged: (val) => setState(() => selectedGender = val!),
                        ),
                        SizedBox(height: 12),
                        _buildTextField(mobileController, 'Mobile'),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Gender',
                            value: selectedGender,
                            items: ['male', 'female', 'other'],
                            onChanged: (val) => setState(() => selectedGender = val!),
                          ),
                        ),
                        Expanded(child: _buildTextField(mobileController, 'Mobile')),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 500;
                    return isMobile
                        ? Column(
                      children: [
                        _buildTextField(addressController, 'Address'),
                      ],
                    )
                        : Row(
                      children: [
                        Expanded(child: _buildTextField(addressController, 'Address')),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),

                isLoading
                    ? CircularProgressIndicator(color: Color(0xFFF50057))
                    : ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xFFF50057),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Register', style: TextStyle(fontSize: 18,color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text('Already have an account? Login', style: TextStyle(color: Color(0xFFF50057))),
                ),
                // TextButton(
                //   onPressed: () {
                //     updateAllBookCountsTo10();
                //   },
                //   child: Text('Seed', style: TextStyle(color: Color(0xFFF50057))),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
