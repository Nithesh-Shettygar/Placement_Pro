import 'package:flutter/material.dart';

class AlumniNetworkPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AlumniNetworkPage({super.key, required this.userData});

  @override
  State<AlumniNetworkPage> createState() => _AlumniNetworkPageState();
}

class _AlumniNetworkPageState extends State<AlumniNetworkPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Listen to tab changes to rebuild FAB
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check width for responsiveness
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: isDesktop ? null : AppBar(
        title: const Text("Alumni Network", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // 1. Desktop Side Navigation
          if (isDesktop) _buildSideNavigation(),

          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                if (!isDesktop) _buildMobileTabBar(),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResponsiveGrid(_buildAlumniDirectoryTab()), 
                      _buildResponsiveGrid(_buildAccessControlTab()),   
                      _buildResponsiveGrid(_buildJobManagementTab()),   
                      _buildResponsiveGrid(_buildActivityTrackingTab()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildContextualFAB(),
    );
  }

  // Wraps tabs in a centered constraint so they don't look weird on wide screens
  Widget _buildResponsiveGrid(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }

  Widget _buildSideNavigation() {
    return NavigationRail(
      selectedIndex: _tabController.index,
      onDestinationSelected: (index) => _tabController.animateTo(index),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: Colors.blue.shade800),
      selectedLabelTextStyle: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Directory')),
        NavigationRailDestination(icon: Icon(Icons.admin_panel_settings), label: Text('Access')),
        NavigationRailDestination(icon: Icon(Icons.work_outline), label: Text('Jobs')),
        NavigationRailDestination(icon: Icon(Icons.history), label: Text('Activity')),
      ],
    );
  }

  Widget _buildMobileTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue.shade800,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue.shade800,
        tabs: const [
          Tab(text: 'Directory'),
          Tab(text: 'Access Control'),
          Tab(text: 'Job Posts'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          if (isDesktop)
            const Text(
              "Alumni Network",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          if (isDesktop) const Spacer(),
          Expanded(
            flex: isDesktop ? 0 : 1,
            child: SizedBox(
              width: isDesktop ? 400 : double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search alumni, company or USN...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE TAB BUILDERS ---
  // (Using GridView.builder for Desktop vs ListView for Mobile)

  Widget _buildAlumniDirectoryTab() {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => _buildModernTile(
          title: "Alumni Name ${index + 1}",
          subtitle: "Batch 2020 • Amazon",
          trailing: const Icon(Icons.chevron_right),
          leadingIcon: Icons.person,
          color: Colors.blue,
        ),
      );
    });
  }

  Widget _buildAccessControlTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text("Registration Request ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("USN: CS18040 | Verified via Email"),
          trailing: Wrap(
            children: [
              IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () {}),
              IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobManagementTab() {
     return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 2.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _buildJobPostItem("Backend Engineer", "Google", "Active", Colors.green),
      );
    });
  }

  Widget _buildActivityTrackingTab() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        itemCount: 10,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) => _buildActivityItem("User $index", "posted a new job", "5m ago"),
      ),
    );
  }

  // --- EXISTING HELPERS (Modified for UI consistency) ---

  Widget _buildModernTile({required String title, required String subtitle, required Widget trailing, required IconData leadingIcon, required Color color}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Center(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(leadingIcon, color: color, size: 20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: trailing,
        ),
      ),
    );
  }

  Widget _buildJobPostItem(String title, String company, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Chip(label: Text(status, style: TextStyle(color: statusColor, fontSize: 10)), backgroundColor: statusColor.withOpacity(0.1)),
            ],
          ),
          Text(company, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text("Edit")),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {}, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, elevation: 0),
                child: const Text("Approve", style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(String name, String action, String time) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.notifications_none, size: 18)),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: " $action"),
          ],
        ),
      ),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget? _buildContextualFAB() {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Add Alumni'),
        icon: const Icon(Icons.person_add_rounded),
        backgroundColor: Colors.blue.shade800,
      );
    } else if (_tabController.index == 2) {
      return FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('New Job Post'),
        icon: const Icon(Icons.add_business_rounded),
        backgroundColor: Colors.blue.shade800,
      );
    }
    return null;
  }
}