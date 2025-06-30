import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';
import '../services/pocketbase_service.dart';

class YourBooksPage extends StatefulWidget {
  final RecordModel user;

  const YourBooksPage({required this.user});

  @override
  State<YourBooksPage> createState() => _YourBooksPageState();
}

class _YourBooksPageState extends State<YourBooksPage> {
  final pb = PocketBaseService.pb;
  List<RecordModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserTransactions();
  }

  Future<void> fetchUserTransactions() async {
    try {
      final result = await pb.collection('transactions').getFullList(
        expand: 'book_id',
        filter: 'user_id="${widget.user.id}"',
      );

      setState(() {
        transactions = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user transactions: $e');
    }
  }

  String formatDate(String date) {
    if (date.isEmpty) return '—';
    return DateFormat.yMMMd().format(DateTime.parse(date));
  }

  Widget _buildTransactionCard(RecordModel tx) {
    final book = tx.expand['book_id']?[0];
    final status = tx.data['status'] ?? 'borrowed';
    final dueDate = tx.data['due_date'] ?? '';

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFF50057), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book?.data['name'] ?? 'Unknown Book',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF50057))),
          SizedBox(height: 8),
          Text("Status: $status", style: TextStyle(fontSize: 16)),
          if (status != 'returned' && dueDate.isNotEmpty)
            Text("Due: ${formatDate(dueDate)}", style: TextStyle(fontSize: 14, color: Colors.redAccent)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFF50057)))
        : Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Borrowed Books",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text("No borrowed books yet."))
                : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;

                if (constraints.maxWidth >= 1000) {
                  crossAxisCount = 3; // Desktop
                } else if (constraints.maxWidth >= 660) {
                  crossAxisCount = 2; // Tablet
                } else {
                  crossAxisCount = 1; // Mobile
                }

                return GridView.builder(
                  itemCount: transactions.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemBuilder: (context, index) =>
                      _buildTransactionCard(transactions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
