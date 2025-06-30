import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart';
import '../services/pocketbase_service.dart';

class TransactionsPage extends StatefulWidget {
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final pb = PocketBaseService.pb;

  List<RecordModel> transactions = [];
  List<RecordModel> filteredTransactions = [];
  List<RecordModel> books = [];
  List<RecordModel> users = [];

  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    books = await pb.collection('books').getFullList();
    users = await pb.collection('users').getFullList();
    transactions = await pb.collection('transactions').getFullList(expand: 'book_id,user_id');
    searchController.addListener(filterTransactions);
    selectedStatus = null;
    filteredTransactions = List.from(transactions); // <-- show everything initially
    setState(() {
      isLoading = false;
    });
  }

  void filterTransactions() {
    final keyword = searchController.text.toLowerCase();
    setState(() {
      filteredTransactions = transactions.where((tx) {
        final book = tx.expand['book_id']?[0]?.data['name']?.toString().toLowerCase() ?? '';
        final user = tx.expand['user_id']?[0]?.data['name']?.toString().toLowerCase() ?? '';
        final matchKeyword = book.contains(keyword) || user.contains(keyword);
        final matchStatus = selectedStatus == null || tx.data['status'] == selectedStatus;
        return matchKeyword && matchStatus;
      }).toList();
    });
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Filter Transactions"),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: InputDecoration(labelText: 'Status'),
          items: [null, 'borrowed', 'returned', 'overdue']
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e ?? 'All'),
          ))
              .toList(),
          onChanged: (val) {
            setState(() => selectedStatus = val);
            Navigator.pop(context);
            filterTransactions();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Validation Error'),
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


  String formatDate(String date) {
    if (date.isEmpty) return '—';
    return DateFormat.yMMMd().format(DateTime.parse(date));
  }

  Future<void> showTransactionDialog({RecordModel? transaction}) async {
    RecordModel? selectedBook = transaction != null
        ? books.firstWhere((b) => b.id == transaction.data['book_id'],
        orElse: () => books.first)
        : null;

    RecordModel? selectedUser = transaction != null
        ? users.firstWhere((u) => u.id == transaction.data['user_id'],
        orElse: () => users.first)
        : null;

    final borrowedOn = TextEditingController(
        text: transaction?.data['borrowed_on'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction!.data['borrowed_on']))
            : ''
    );

    final dueDate = TextEditingController(
        text: transaction?.data['due_date'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction!.data['due_date']))
            : ''
    );

    final returnedOn = TextEditingController(
        text: transaction?.data['returned_on'] != null && transaction!.data['returned_on'].toString().isNotEmpty
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction!.data['returned_on']))
            : ''
    );
    String status = transaction?.data['status'] ?? 'borrowed';

    await showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
                transaction == null ? "Add Transaction" : "Edit Transaction",
                style: TextStyle(color: Color(0xFFF50057))),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<RecordModel>(
                    value: selectedBook,
                    hint: Text("Select Book"),
                    decoration: InputDecoration(labelText: 'Book'),

                    // ✅ Include selectedBook if it's not available/replaced
                    items: [
                      ...books
                          .where((book) =>
                      book.data['status'] == 'available' ||
                          book.data['status'] == 'replaced' ||
                          book.id == selectedBook?.id) // 🔥 ensures selected book is in the list
                          .toSet() // 👈 removes any duplicates (if selectedBook is already available)
                          .toList()
                          .map((book) => DropdownMenuItem(
                        value: book,
                        child: Text(book.data['name']),
                      ))
                    ],

                    onChanged: (val) {
                      setState(() {
                        selectedBook = val;
                      });
                    },
                  ),
                  DropdownButtonFormField<RecordModel>(
                    value: selectedUser,
                    hint: Text("Select User"),
                    decoration: InputDecoration(labelText: 'User'),
                    items: users.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(user.data['name']),
                      );
                    }).toList(),
                    onChanged: (val) => selectedUser = val,
                  ),
                  _buildDateField(borrowedOn, 'Borrowed On'),
                  _buildDateField(dueDate, 'Due Date'),
                  _buildDateField(returnedOn, 'Returned On'),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(labelText: 'Status'),
                    items: ['borrowed', 'returned', 'overdue']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => status = val ?? 'borrowed',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF50057),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                    if (selectedBook == null || selectedUser == null || borrowedOn.text.trim().isEmpty || dueDate.text.trim().isEmpty) {
                    showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                    title: Text("Missing Fields"),
                    content: Text("Book, user, borrowed date, and due date are required."),
                    actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
                    ],
                    ),
                    );
                    return;
                    }

                    DateTime? borrowed;
                    DateTime? due;
                    DateTime? returned;

                    try {
                    borrowed = DateTime.parse(borrowedOn.text.trim());
                    due = DateTime.parse(dueDate.text.trim());
                    if (returnedOn.text.trim().isNotEmpty) {
                    returned = DateTime.parse(returnedOn.text.trim());
                    }
                    } catch (e) {
                    showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                    title: Text("Invalid Date"),
                    content: Text("Please make sure all dates are in correct format."),
                    actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
                    ],
                    ),
                    );
                    return;
                    }

                    if (!due.isAfter(borrowed)) {
                    showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                    title: Text("Invalid Due Date"),
                    content: Text("Due date must be after the borrowed date."),
                    actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
                    ],
                    ),
                    );
                    return;
                    }

                    if (returned != null && !returned.isAfter(borrowed)) {
                    showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                    title: Text("Invalid Return Date"),
                    content: Text("Return date must be after the borrowed date."),
                    actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
                    ],
                    ),
                    );
                    return;
                    }

                    // Determine status
                    DateTime now = DateTime.now();
                    String status;
                    if (returned != null) {
                    status = 'returned';
                    } else if (now.isAfter(due)) {
                    status = 'overdue';
                    } else {
                    status = 'borrowed';
                    }

                    final body = {
                    "book_id": selectedBook?.id,
                    "user_id": selectedUser?.id,
                    "borrowed_on": borrowedOn.text.trim(),
                    "due_date": dueDate.text.trim(),
                    "returned_on": returnedOn.text.trim(),
                    "status": status,
                    };

                    if (transaction == null) {
                      // Create new transaction
                      await pb.collection('transactions').create(body: body);

                      // ↓ Decrease book count
                      final book = await pb.collection('books').getOne(selectedBook!.id);
                      int count = int.tryParse(book.data['count'].toString()) ?? 0;
                      count = (count > 0) ? count - 1 : 0;

                      await pb.collection('books').update(selectedBook!.id, body: {
                        "count": count,
                        "status": count == 0 ? "unavailable" : "available",
                      });

                    } else {
                      // Update transaction
                      await pb.collection('transactions').update(transaction.id, body: body);

                      final book = await pb.collection('books').getOne(selectedBook!.id);
                      int count = int.tryParse(book.data['count'].toString()) ?? 0;

                      if (returned != null && transaction.data['returned_on'].toString().isEmpty) {
                        // If this transaction was not previously returned but now is
                        count += 1;
                      } else if (returned == null && transaction.data['returned_on'].toString().isNotEmpty) {
                        // If it was previously returned, but now being edited as not returned
                        count = (count > 0) ? count - 1 : 0;
                      }

                      await pb.collection('books').update(selectedBook!.id, body: {
                        "count": count,
                        "status": count == 0 ? "unavailable" : "available",
                      });
                    }

                    Navigator.pop(context);
                    fetchData();
    },
    child: Text(transaction == null ? "Add" : "Save",style: TextStyle(color: Colors.white),),
              )
            ],
          ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.text.isNotEmpty
                ? DateTime.parse(controller.text)
                : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
            controller.text = formattedDate;
          }
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFF50057)))
        : Padding(
      padding: screenWidth > 800
          ? const EdgeInsets.only(left: 100, right: 100, top: 50, bottom: 25)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (_) => filterTransactions(),
                    decoration: InputDecoration(
                      hintText: "Search by book or user...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Reset Filters',
                        onPressed: () {
                          setState(() {
                            selectedStatus = null;
                            searchController.clear();
                          });
                          filterTransactions();
                        },
                        icon: Icon(Icons.refresh, color: Color(0xFFF50057)),
                      ),
                      ElevatedButton.icon(
                        onPressed: showFilterDialog,
                        icon: Icon(Icons.filter_list, color: Colors.white),
                        label: Text("Filter", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF50057),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => showTransactionDialog(),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text("Add Transaction",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF50057),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => filterTransactions(),
                      decoration: InputDecoration(
                        hintText: "Search by book or user...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Reset Filters',
                    onPressed: () {
                      setState(() {
                        selectedStatus = null;
                        searchController.clear();
                      });
                      filterTransactions();
                    },
                    icon: Icon(Icons.refresh, color: Color(0xFFF50057)),
                  ),
                  ElevatedButton.icon(
                    onPressed: showFilterDialog,
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    label:
                    Text("Filter", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF50057),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => showTransactionDialog(),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text("Add Transaction",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF50057),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: screenWidth < 800 ? _buildCardView() : _buildTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (_, index) {
        final tx = filteredTransactions[index];
        final bookName = tx.expand['book_id']?[0]?.data['name'] ?? 'Unknown';
        final userName = tx.expand['user_id']?[0]?.data['name'] ?? 'Unknown';
        final userMobile = tx.expand['user_id']?[0]?.data['mobile'] ?? '—';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text("Book: $bookName"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("User: $userName"),
                Text("Mobile: $userMobile"),
                Text("Borrowed: ${formatDate(tx.data['borrowed_on'])}"),
                Text("Due: ${formatDate(tx.data['due_date'])}"),
                Text("Returned: ${formatDate(tx.data['returned_on'])}"),
                Text("Status: ${tx.data['status']}",
                    style: TextStyle(
                      color: tx.data['status'] == 'overdue'
                          ? Colors.red
                          : Colors.black,
                    )),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Color(0xFFF50057)),
              onPressed: () => showTransactionDialog(transaction: tx),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableView() {
    final verticalController = ScrollController();

    return Scrollbar(
      controller: verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: verticalController,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: DataTable(
              headingRowColor:
              MaterialStateProperty.all(Color(0xFFF50057).withOpacity(0.1)),
              columns: const [
                DataColumn(label: Text("Book")),
                DataColumn(label: Text("User")),
                DataColumn(label: Text("User Mobile")),
                DataColumn(label: Text("Borrowed")),
                DataColumn(label: Text("Due")),
                DataColumn(label: Text("Returned")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Actions")),
              ],
              rows: filteredTransactions.map((tx) {
                final book = tx.expand['book_id']?[0]?.data['name'] ?? 'Unknown';
                final user = tx.expand['user_id']?[0]?.data['name'] ?? 'Unknown';
                final userMobile = tx.expand['user_id']?[0]?.data['mobile'] ?? '—';

                return DataRow(cells: [
                  DataCell(Text(book)),
                  DataCell(Text(user)),
                  DataCell(Text(userMobile)),
                  DataCell(Text(formatDate(tx.data['borrowed_on']))),
                  DataCell(Text(formatDate(tx.data['due_date']))),
                  DataCell(Text(formatDate(tx.data['returned_on']))),
                  DataCell(Text("Status: ${tx.data['status']}",
                      style: TextStyle(
                        color: tx.data['status'] == 'overdue'
                            ? Colors.red
                            : Colors.black,
                      ))),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.edit, color: Color(0xFFF50057)),
                      onPressed: () => showTransactionDialog(transaction: tx),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}