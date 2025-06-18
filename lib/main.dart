import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:library_management/pages/login_page.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/pages/admin_home_page.dart';
import 'package:library_management/pages/user_home_page.dart';
import 'models/user_model.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await DBHelper.initDb();// Set the FFI factory
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      home: LoginPage(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),          // 👈 your login page
        '/adminHome': (context) => AdminHomePage(user: ModalRoute.of(context)!.settings.arguments as User),
        '/userHome': (context) => UserHomePage(user: ModalRoute.of(context)!.settings.arguments as User),
        // Add more if needed
      },
    );
  }
}
