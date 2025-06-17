import 'package:flutter/material.dart';
import 'package:library_management/db/db_helper.dart';
import 'package:library_management/models/borrower_model.dart';

class BorrowerPage extends StatefulWidget {
  @override
  State<BorrowerPage> createState() => _BorrowerPageState();
}

class _BorrowerPageState extends State<BorrowerPage> {
  List<Borrower> borrowers = [];

  @override
  void initState() {
    super.initState();
    fetchBorrowers();
  }

  void fetchBorrowers() async {
    final data = await DBHelper.getAllBorrowers();
    setState(() {
      borrowers = data;
    });
  }

  void showBorrowerForm({Borrower? borrower}) {
    final bookIdController = TextEditingController(text: borrower?.bookId.toString() ?? '');
    final emailController = TextEditingController(text: borrower?.userEmail ?? '');
    final deliveryController = TextEditingController(text: borrower?.deliveryDate ?? '');
    final returnController = TextEditingController(text: borrower?.returnDate ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(borrower == null ? 'Add Borrower' : 'Edit Borrower'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: bookIdController, decoration: InputDecoration(labelText: 'Book ID'), keyboardType: TextInputType.number),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'User Email')),
              TextField(controller: deliveryController, decoration: InputDecoration(labelText: 'Delivery Date')),
              TextField(controller: returnController, decoration: InputDecoration(labelText: 'Return Date')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newBorrower = Borrower(
                id: borrower?.id,
                bookId: int.tryParse(bookIdController.text) ?? 0,
                userEmail: emailController.text,
                deliveryDate: deliveryController.text,
                returnDate: returnController.text,
              );

              if (borrower == null) {
                await DBHelper.insertBorrower(newBorrower);
              } else {
                await DBHelper.updateBorrower(newBorrower);
              }

              fetchBorrowers();
              Navigator.pop(context);
            },
            child: Text(borrower == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void deleteBorrower(int id) async {
    await DBHelper.deleteBorrower(id);
    fetchBorrowers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Borrowers List', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => showBorrowerForm(),
                icon: Icon(Icons.add),
                label: Text('Add Borrower'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Book ID')),
                  DataColumn(label: Text('User Email')),
                  DataColumn(label: Text('Delivery Date')),
                  DataColumn(label: Text('Return Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: borrowers.map((b) => DataRow(cells: [
                  DataCell(Text(b.id?.toString() ?? '')),
                  DataCell(Text(b.bookId.toString())),
                  DataCell(Text(b.userEmail)),
                  DataCell(Text(b.deliveryDate)),
                  DataCell(Text(b.returnDate)),
                  DataCell(Row(
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => showBorrowerForm(borrower: b)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => deleteBorrower(b.id!)),
                    ],
                  )),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
