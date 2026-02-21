import 'package:flutter/material.dart';

class PlacementStatsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PlacementStatsPage({super.key, required this.userData});

  @override
  State<PlacementStatsPage> createState() => _PlacementStatsPageState();
}

class _PlacementStatsPageState extends State<PlacementStatsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedYear = "2024-25";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for more granular control over responsiveness
    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 900;
      final bool isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;

      return Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),
        // On Mobile/Tablet, we use the AppBar with the TabBar
        appBar: !isDesktop
            ? AppBar(
                title: const Text('Placement History', 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                backgroundColor: Colors.white,
                elevation: 0,
                bottom: _buildTabBar(),
              )
            : null,
        body: Row(
          children: [
            // Only show Side Navigation Rail on Desktop
            if (isDesktop) _buildSideNav(),
            
            Expanded(
              child: Column(
                children: [
                  // Desktop specific Header
                  if (isDesktop) _buildDesktopHeader(),
                  
                  _buildYearSelector(isDesktop),
                  
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildResponsiveContainer(_buildCompanyWiseSelections(isDesktop), isDesktop),
                        _buildResponsiveContainer(_buildDeptWiseStats(isDesktop), isDesktop),
                        _buildResponsiveContainer(_buildPackageStats(isDesktop, isTablet), isDesktop),
                        _buildResponsiveContainer(_buildArchivedDrives(isDesktop), isDesktop),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- UI COMPONENTS ---

  Widget _buildYearSelector(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text("Year: ", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: selectedYear,
            underline: const SizedBox(),
            items: ["2024-25", "2023-24", "2022-23"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
            }).toList(),
            onChanged: (val) => setState(() => selectedYear = val!),
          ),
          const Spacer(),
          // Shortened button for mobile
          isDesktop 
            ? ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text("Export PDF"))
            : IconButton(onPressed: () {}, icon: const Icon(Icons.download, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _buildSideNav() {
    return NavigationRail(
      selectedIndex: _tabController.index,
      onDestinationSelected: (index) => _tabController.animateTo(index),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      minWidth: 100,
      selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.business_center), label: Text('Companies')),
        NavigationRailDestination(icon: Icon(Icons.pie_chart), label: Text('Dept %')),
        NavigationRailDestination(icon: Icon(Icons.payments), label: Text('Packages')),
        NavigationRailDestination(icon: Icon(Icons.inventory_2), label: Text('Archive')),
      ],
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.blueAccent,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blueAccent,
      tabs: const [
        Tab(text: 'Selections'),
        Tab(text: 'Dept Wise'),
        Tab(text: 'Packages'),
        Tab(text: 'Archive'),
      ],
    );
  }

  // --- DATA VIEWS ---

  Widget _buildCompanyWiseSelections(bool isDesktop) {
    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        _buildSummaryHeader("Total Selected", "412 Students", Colors.blue, isDesktop),
        const SizedBox(height: 20),
        _buildSelectionTile("Google", "12 Students", "CTC: 32 LPA"),
        _buildSelectionTile("Microsoft", "08 Students", "CTC: 44 LPA"),
        _buildSelectionTile("Accenture", "145 Students", "CTC: 4.5 LPA"),
        _buildSelectionTile("Zomato", "04 Students", "CTC: 18 LPA"),
      ],
    );
  }

  Widget _buildDeptWiseStats(bool isDesktop) {
    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        Text("Dept. Placement Rate ($selectedYear)", 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDeptRow("Computer Science", 0.94),
        _buildDeptRow("Information Technology", 0.88),
        _buildDeptRow("Electronics & Comm.", 0.72),
        _buildDeptRow("Mechanical Eng.", 0.54),
      ],
    );
  }

  Widget _buildPackageStats(bool isDesktop, bool isTablet) {
    // Dynamic column count based on width
    int crossAxisCount = isDesktop ? 2 : (isTablet ? 2 : 1);
    
    return GridView.count(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      crossAxisCount: crossAxisCount,
      childAspectRatio: isDesktop ? 2.2 : 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard("Highest", "₹ 48.5 LPA", Icons.trending_up, Colors.green),
        _buildStatCard("Average", "₹ 6.8 LPA", Icons.bar_chart, Colors.orange),
        _buildStatCard("Median", "₹ 5.2 LPA", Icons.align_horizontal_center, Colors.blue),
        _buildStatCard("Lowest", "₹ 3.5 LPA", Icons.trending_down, Colors.red),
      ],
    );
  }

  Widget _buildArchivedDrives(bool isDesktop) {
    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      itemCount: 4,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
        child: ListTile(
          leading: const Icon(Icons.folder_zip, color: Colors.grey),
          title: Text("Phase ${4 - index} - $selectedYear"),
          subtitle: const Text("Verified & Locked"),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  // --- REUSABLE ADAPTIVE WIDGETS ---

  Widget _buildResponsiveContainer(Widget child, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : double.infinity),
        child: child,
      ),
    );
  }

  Widget _buildSummaryHeader(String title, String value, Color color, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withBlue(255)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: isDesktop ? 32 : 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile(String company, String count, String detail) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        title: Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(detail, style: const TextStyle(fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
          child: Text(count, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildDeptRow(String dept, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dept, style: const TextStyle(fontSize: 14)), 
              Text("${(percent * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey.shade200, color: Colors.blueAccent, minHeight: 6),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: const Row(
        children: [
          Icon(Icons.analytics, color: Colors.blueAccent, size: 28),
          SizedBox(width: 12),
          Text("Placement Analytics Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}