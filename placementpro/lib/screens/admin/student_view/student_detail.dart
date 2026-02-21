import 'package:flutter/material.dart';

class DepartmentStudentListPage extends StatefulWidget {
  final String deptName;
  final Color themeColor;

  const DepartmentStudentListPage({
    super.key,
    required this.deptName,
    required this.themeColor,
  });

  @override
  State<DepartmentStudentListPage> createState() => _DepartmentStudentListPageState();
}

class _DepartmentStudentListPageState extends State<DepartmentStudentListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: widget.themeColor),
        title: Text(
          widget.deptName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isDesktop) _buildExportButton(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildTopFilterBar(isDesktop),
          Expanded(
            child: isDesktop ? _buildDesktopTable() : _buildMobileList(),
          ),
        ],
      ),
    );
  }

  // --- TOP BAR: Search and Filter ---
  Widget _buildTopFilterBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        children: [
          Expanded(
            flex: isDesktop ? 2 : 0,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by USN or Name...',
                prefixIcon: Icon(Icons.search, color: widget.themeColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          if (!isDesktop) const SizedBox(height: 12),
          if (isDesktop) const SizedBox(width: 20),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['All', 'Placed', 'Unplaced', '7.5+ CGPA'].map((filter) {
          bool isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              selectedColor: widget.themeColor.withOpacity(0.2),
              checkmarkColor: widget.themeColor,
              labelStyle: TextStyle(
                color: isSelected ? widget.themeColor : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- DESKTOP VIEW: Data Table ---
  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text('Student Name')),
            DataColumn(label: Text('USN')),
            DataColumn(label: Text('CGPA')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: List.generate(10, (index) {
            bool isPlaced = index % 3 == 0;
            return DataRow(cells: [
              DataCell(Text('Student ${index + 1}')),
              DataCell(Text('1DS22CS0${index + 10}')),
              DataCell(Text('8.${index + 1}')),
              DataCell(_buildStatusChip(isPlaced)),
              DataCell(TextButton(onPressed: () {}, child: const Text("View Profile"))),
            ]);
          }),
        ),
      ),
    );
  }

  // --- MOBILE VIEW: Card List ---
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        bool isPlaced = index % 3 == 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
          borderOnForeground: true,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: widget.themeColor.withOpacity(0.1),
              child: Text("${index + 1}", style: TextStyle(color: widget.themeColor)),
            ),
            title: Text('Student Name ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('USN: 1DS21CS0${index + 10}'),
            trailing: _buildStatusChip(isPlaced),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem("CGPA", "8.${index + 1}"),
                    _buildDetailItem("Backlogs", "0"),
                    ElevatedButton(onPressed: () {}, child: const Text("Profile")),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildStatusChip(bool isPlaced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPlaced ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPlaced ? "Placed" : "Eligible",
        style: TextStyle(
            color: isPlaced ? Colors.green : Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.download, size: 18),
      label: const Text("Export CSV"),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}