import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';

class BooksPage extends StatefulWidget {
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final pb = PocketBaseService.pb;
  List<RecordModel> books = [];
  bool isLoading = true;
  String currentUserRole = 'member';
  TextEditingController searchController = TextEditingController();

  double? minPrice, maxPrice;
  double? minYear, maxYear;
  String? selectedLanguage;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    final currentUser = pb.authStore.model;
    currentUserRole = currentUser?.data['role'] ?? 'member';
    fetchBooks();
  }

  Future<void> fetchBooks({String keyword = ''}) async {
    final result = await pb.collection('books').getFullList();
    final filteredBooks = result.where((book) {
      final name = book.data['name']?.toString().toLowerCase() ?? '';
      final author = book.data['author']?.toString().toLowerCase() ?? '';
      final genre = book.data['genre']?.toString().toLowerCase() ?? '';
      final lowerKeyword = keyword.toLowerCase();

      final price = double.tryParse(book.data['price'].toString()) ?? 0;
      final year = double.tryParse(book.data['yr_of_release'].toString()) ?? 0;
      final language = book.data['language']?.toString();
      final count = double.tryParse(book.data['count'].toString()) ?? 0;
      final status = book.data['status']?.toString();

      final matchesKeyword = keyword.isEmpty ||
          name.contains(lowerKeyword) ||
          author.contains(lowerKeyword) ||
          genre.contains(lowerKeyword);

      final matchesPrice = (minPrice == null || price >= minPrice!) &&
          (maxPrice == null || price <= maxPrice!);
      final matchesYear = (minYear == null || year >= minYear!) &&
          (maxYear == null || year <= maxYear!);
      final matchesLanguage = selectedLanguage == null || selectedLanguage == language;
      final matchesStatus = selectedStatus == null || selectedStatus == status;

      return matchesKeyword && matchesPrice && matchesYear && matchesLanguage && matchesStatus;
    }).toList();

    setState(() {
      books = filteredBooks;
      isLoading = false;
    });
  }

  Future<void> showFilterDialog() async {
    final allBooks = await pb.collection('books').getFullList();
    final uniqueLanguages = allBooks
        .map((book) => book.data['language']?.toString())
        .where((lang) => lang != null)
        .toSet()
        .toList();

    double priceRangeStart = minPrice ?? 0;
    double priceRangeEnd = maxPrice ?? 1000;
    double yearRangeStart = minYear ?? 1900;
    double yearRangeEnd = maxYear ?? DateTime.now().year.toDouble();

    String? tempLanguage = selectedLanguage;
    String? tempStatus = selectedStatus;

    await showDialog(
      context: context,
        builder: (_) => StatefulBuilder(
      builder: (context, setModalState) => AlertDialog(
        title: Text("Filter Books", style: TextStyle(color: Color(0xFFF50057))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text("Price Range: ₹${priceRangeStart.toInt()} - ₹${priceRangeEnd.toInt()}"),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFFF50057),      // Color of the track between thumbs
                  inactiveTrackColor: Color(0xFFF50057).withOpacity(0.3), // Track outside the range
                  thumbColor: Color(0xFFF50057),            // Color of the thumbs
                  overlayColor: Color(0xFFF50057).withOpacity(0.2), // When thumb is pressed
                  valueIndicatorColor: Color(0xFFF50057),   // If you're showing value indicators
                  rangeTrackShape: RoundedRectRangeSliderTrackShape(),
                  rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: RangeSlider(
                  values: RangeValues(priceRangeStart, priceRangeEnd),
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  labels: RangeLabels(
                    priceRangeStart.toInt().toString(),
                    priceRangeEnd.toInt().toString(),
                  ),
                  onChanged: (values) {
                    setModalState(() {
                      priceRangeStart = values.start;
                      priceRangeEnd = values.end;
                    });
                  },
                ),
              ),
              Text("Year Range: ${yearRangeStart.toInt()} - ${yearRangeEnd.toInt()}"),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFFF50057),      // Color of the track between thumbs
                  inactiveTrackColor: Color(0xFFF50057).withOpacity(0.3), // Track outside the range
                  thumbColor: Color(0xFFF50057),            // Color of the thumbs
                  overlayColor: Color(0xFFF50057).withOpacity(0.2), // When thumb is pressed
                  valueIndicatorColor: Color(0xFFF50057),   // If you're showing value indicators
                  rangeTrackShape: RoundedRectRangeSliderTrackShape(),
                  rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: RangeSlider(
                  values: RangeValues(yearRangeStart, yearRangeEnd),
                  min: 1900,
                  max: DateTime.now().year.toDouble(),
                  divisions: DateTime.now().year - 1900,
                  labels: RangeLabels(
                    yearRangeStart.toInt().toString(),
                    yearRangeEnd.toInt().toString(),
                  ),
                  onChanged: (values) {
                    setModalState(() {
                      yearRangeStart = values.start;
                      yearRangeEnd = values.end;
                    });
                  },
                ),
              ),
              DropdownButtonFormField<String>(
                value: tempLanguage,
                decoration: InputDecoration(labelText: 'Language'),
                items: uniqueLanguages.map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang!),
                )).toList(),
                onChanged: (val) => setModalState(() => tempLanguage = val),
              ),
              DropdownButtonFormField<String>(
                value: tempStatus,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['available', 'unavailable', 'damaged', 'replaced']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (val) => setModalState(() => tempStatus = val),
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
            onPressed: () {
              setState(() {
                minPrice = priceRangeStart;
                maxPrice = priceRangeEnd;
                minYear = yearRangeStart;
                maxYear = yearRangeEnd;
                selectedLanguage = tempLanguage;
                selectedStatus = tempStatus;
              });
              Navigator.pop(context);
              fetchBooks(keyword: searchController.text);
            },
            child: Text("Apply", style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF50057)),
          )
        ],
      ),
    ));
  }

Future<void> showBookDialog({RecordModel? book}) async {
    final TextEditingController name = TextEditingController(text: book?.data['name']);
    final TextEditingController author = TextEditingController(text: book?.data['author']);
    final TextEditingController genre = TextEditingController(text: book?.data['genre']);
    final TextEditingController price = TextEditingController(text: book?.data['price']?.toString());
    final TextEditingController year = TextEditingController(text: book?.data['yr_of_release']?.toString());
    final TextEditingController language = TextEditingController(text: book?.data['language']);
    final TextEditingController count = TextEditingController(text: book?.data['count']?.toString());
    String status = book?.data['status'] ?? 'available';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(book == null ? "Add Book" : "Edit Book", style: TextStyle(color: Color(0xFFF50057))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(name, 'Name'),
              _buildTextField(author, 'Author'),
              _buildTextField(genre, 'Genre'),
              _buildTextField(price, 'Price', isNumber: true),
              _buildTextField(year, 'Year of Release', isNumber: true),
              _buildTextField(language, 'Language'),
              _buildTextField(count, 'Count', isNumber: true),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['available', 'unavailable', 'damaged', 'replaced']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => status = val ?? 'available',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF50057),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final body = {
                "name": name.text.trim(),
                "author": author.text.trim(),
                "genre": genre.text.trim(),
                "price": int.tryParse(price.text.trim()) ?? 0,
                "yr_of_release": int.tryParse(year.text.trim()) ?? 2000,
                "language": language.text.trim(),
                "count": int.tryParse(count.text.trim()) ?? 1,
                "status": status,
              };

              if (book == null) {
                await pb.collection('books').create(body: body);
              } else {
                await pb.collection('books').update(book.id, body: body);
              }

              Navigator.pop(context);
              fetchBooks(keyword: searchController.text);
            },
            child: Text(book == null ? "Add" : "Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFF50057)))
        : LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 800;

        return Padding(
          padding: isWideScreen
              ? const EdgeInsets.only(left: 100, right: 100, top: 50, bottom: 25)
              : EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;

                  return isMobile
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (value) => fetchBooks(keyword: value),
                        decoration: InputDecoration(
                          hintText: "Search by name, author, genre...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                minPrice = null;
                                maxPrice = null;
                                minYear = null;
                                maxYear = null;
                                selectedLanguage = null;
                                selectedStatus = null;
                              });
                              fetchBooks(keyword: searchController.text);
                            },
                            icon: Icon(Icons.refresh, color: Color(0xFFF50057)),
                          ),
                          ElevatedButton.icon(
                            onPressed: showFilterDialog,
                            icon: Icon(Icons.filter_list, color: Colors.white),
                            label: Text("Filter", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF50057),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          if (currentUserRole != 'member')
                            ElevatedButton.icon(
                              onPressed: () => showBookDialog(),
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text("Add Book", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF50057),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          onChanged: (value) => fetchBooks(keyword: value),
                          decoration: InputDecoration(
                            hintText: "Search by name, author, genre...",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Reset Filters',
                        onPressed: () {
                          setState(() {
                            minPrice = null;
                            maxPrice = null;
                            minYear = null;
                            maxYear = null;
                            selectedLanguage = null;
                            selectedStatus = null;
                          });
                          fetchBooks(keyword: searchController.text);
                        },
                        icon: Icon(Icons.refresh, color: Color(0xFFF50057)),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: showFilterDialog,
                        icon: Icon(Icons.filter_list, color: Colors.white),
                        label: Text("Filter", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF50057),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (currentUserRole != 'member')
                        ElevatedButton.icon(
                          onPressed: () => showBookDialog(),
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text("Add Book", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF50057),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: isWideScreen ? _buildTableView() : _buildCardView(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableView() {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          child: Scrollbar(
            controller: verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalController,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Color(0xFFF50057).withOpacity(0.2)),
                    columnSpacing: 20,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 70,
                    columns: [
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Author")),
                      DataColumn(label: Text("Genre")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Year")),
                      DataColumn(label: Text("Language")),
                      DataColumn(label: Text("Count")),
                      DataColumn(label: Text("Status")),
                      if (currentUserRole != 'member') DataColumn(label: Text("Actions")),
                    ],
                    rows: books.map((book) {
                      return DataRow(cells: [
                        DataCell(Text(book.data['name'] ?? '')),
                        DataCell(Text(book.data['author'] ?? '')),
                        DataCell(Text(book.data['genre'] ?? '')),
                        DataCell(Text(book.data['price'].toString())),
                        DataCell(Text(book.data['yr_of_release'].toString())),
                        DataCell(Text(book.data['language'] ?? '')),
                        DataCell(Text(book.data['count'].toString())),
                        DataCell(_buildStatusChip(book.data['status'] ?? '')),
                        if (currentUserRole != 'member')
                          DataCell(IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFFF50057)),
                            onPressed: () => showBookDialog(book: book),
                          )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        break;
      case 'unavailable':
        color = Colors.red;
        break;
      case 'damaged':
        color = Colors.orange;
        break;
      case 'replaced':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (_, index) {
        final book = books[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(book.data['name'] ?? 'Unknown'),
            subtitle: Text("Author: ${book.data['author'] ?? ''} | Status: ${book.data['status']}"),
            trailing: currentUserRole != 'member'
                ? IconButton(
              icon: Icon(Icons.edit, color: Color(0xFFF50057)),
              onPressed: () => showBookDialog(book: book),
            )
                : null,
          ),
        );
      },
    );
  }
}
