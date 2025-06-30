import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'books_page.dart';
import 'users_page.dart';
import 'transactions_page.dart';
import 'profile_page.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import 'package:pocketbase/pocketbase.dart';

class LibHomePage extends StatefulWidget {
  final RecordModel user;

  const LibHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<LibHomePage> createState() => _LibHomePageState();
}

class _LibHomePageState extends State<LibHomePage> {
  int selectedIndex = 0;
  late List<Widget> _pages;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    'Dashboard',
    'Books',
    'Members',
    'Transactions',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboard(),
      BooksPage(),
      UsersPage(),
      TransactionsPage(),
      ProfilePage(user: widget.user),
    ];
  }

  void _logout() {
    AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void _onNavItemTap(int index) {
    Navigator.pop(context); // Close drawer first (for mobile)
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildNavItem(String title, int index, {bool isDrawer = false}) {
    final isSelected = selectedIndex == index;

    return isDrawer
        ? ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Color(0xFFF50057) : Colors.black,
        ),
      ),
      onTap: () => _onNavItemTap(index),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () => setState(() => selectedIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white24 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopNav() {
    return Container(
      color: Color(0xFFF50057),
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          for (int i = 0; i < _titles.length; i++)
            _buildNavItem(_titles[i], i),
          Spacer(),
          TextButton(
            onPressed: _logout,
            child: Text('Logout', style: TextStyle(fontSize: 18, color: Colors.white)),
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileNav() {
    return AppBar(
      backgroundColor: Color(0xFFF50057),
      title: Text(_titles[selectedIndex],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.white,),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white,),
          onPressed: _logout,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isWideScreen ? null : _buildMobileNav(),
      drawer: isWideScreen
          ? null
          : Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFF50057)),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            for (int i = 0; i < _titles.length; i++)
              _buildNavItem(_titles[i], i, isDrawer: true),
            Divider(),
            ListTile(
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            )
          ],
        ),
      ),
      body: Column(
        children: [
          if (isWideScreen) _buildDesktopNav(),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }
}
