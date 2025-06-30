import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final pb = PocketBaseService.pb; // or your hosted PB URL

  int totalBooks = 0;
  int availableBooks = 0;
  int unavailableBooks = 0;
  int damagedBooks = 0;
  int replacedBooks = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookData();
  }

  Future<void> fetchBookData() async {
    try {
      final records = await pb.collection('books').getFullList();

      setState(() {
        totalBooks = records.length;
        availableBooks = records.where((b) => b.data['status'] == 'available').length;
        unavailableBooks = records.where((b) => b.data['status'] == 'unavailable').length;
        damagedBooks = records.where((b) => b.data['status'] == 'damaged').length;
        replacedBooks = records.where((b) => b.data['status'] == 'replaced').length;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching book data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFF50057)))
        : SingleChildScrollView(
      padding: MediaQuery.of(context).size.width > 800
          ? const EdgeInsets.only(left: 100, right: 100, top: 50, bottom: 25)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard("Total Books", totalBooks.toString(), color: Color(0xFFF50057), big: true),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("Available", availableBooks.toString(), Colors.green)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard("Unavailable", unavailableBooks.toString(), Colors.orange)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard("Damaged", damagedBooks.toString(), Colors.red)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard("Replaced", replacedBooks.toString(), Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String title, String value, {required Color color, bool big = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
