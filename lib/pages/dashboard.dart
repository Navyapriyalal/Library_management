import 'package:flutter/material.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/widgets/dashboard_card.dart'; // if you created this separately

class BookDashboardWidget extends StatefulWidget {
  @override
  _BookDashboardWidgetState createState() => _BookDashboardWidgetState();
}

class _BookDashboardWidgetState extends State<BookDashboardWidget> {
  int totalBooks = 0;
  int availableBooks = 0;
  int unavailableBooks = 0;

  @override
  void initState() {
    super.initState();
    _fetchBookCounts();
  }

  Future<void> _fetchBookCounts() async {
    final books = await DBHelper.getAllBooks();
    setState(() {
      totalBooks = books.length;
      availableBooks = books.where((b) => b.status.toLowerCase() == 'available').length;
      unavailableBooks = totalBooks - availableBooks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: DashboardCard(
          title: "Total Books",
          count: totalBooks,
          color: Colors.blue,
          icon: Icons.library_books,
        )),
        SizedBox(width: 12),
        Expanded(child: DashboardCard(
          title: "Available",
          count: availableBooks,
          color: Colors.green,
          icon: Icons.check_circle_outline,
        )),
        SizedBox(width: 12),
        Expanded(child: DashboardCard(
          title: "Unavailable",
          count: unavailableBooks,
          color: Colors.red,
          icon: Icons.cancel_outlined,
        )),
      ],
    );
  }
}
