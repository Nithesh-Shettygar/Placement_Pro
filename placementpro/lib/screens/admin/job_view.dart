import 'package:flutter/material.dart';
import 'package:placementpro/services/company_storage_service.dart';
import 'package:placementpro/services/api_service.dart';
import 'dart:convert';

class JobPortalsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int? initialTab;
  const JobPortalsPage({super.key, required this.userData, this.initialTab});

  @override
  State<JobPortalsPage> createState() => _JobPortalsPageState();
}

class _JobPortalsPageState extends State<JobPortalsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // --- DATA SOURCES ---
  List<Map<String, String>> companies = [
    {"name": "Google", "sub": "Tech • Tier 1"},
    {"name": "Microsoft", "sub": "Tech • Tier 1"},
    {"name": "TCS", "sub": "Service • Tier 3"},
  ];

  List<Map<String, dynamic>> drives = [
    {"title": "Amazon SDE-1", "elig": "7.5+ CGPA", "status": "Active", "color": Colors.green},
    {"title": "Infosys System Eng.", "elig": "No Backlogs", "status": "Closing Soon", "color": Colors.orange},
  ];

  List<Map<String, String>> applications = [
    {"student": "John Doe", "role": "Frontend Intern", "date": "Oct 12, 2025"},
    {"student": "Jane Smith", "role": "Data Analyst", "date": "Oct 14, 2025"},
  ];

  List<Map<String, String>> announcements = [
    {"title": "Resume Workshop", "desc": "Mandatory for all 3rd year students.", "time": "2 hours ago"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _tabController.addListener(() {
      setState(() { _searchController.clear(); _searchQuery = ""; });
    });
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final response = await ApiService.getCompanies(alumniOnly: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          companies = data.map((c) => {
            "id": c['id'].toString(),
            "name": c['name'] as String,
            "sub": c['category'] as String,
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching companies: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- REUSABLE CRUD LOGIC ---
  void _deleteItem(List list, int index) => setState(() => list.removeAt(index));

  // --- DIALOGS ---
  void _showAnnouncementDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Post Announcement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Subject")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Message Body"), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() => announcements.insert(0, {"title": titleController.text, "desc": descController.text, "time": "Just now"}));
              Navigator.pop(context);
            },
            child: const Text("Post"),
          )
        ],
      ),
    );
  }

  void _showCompanyDialog({int? index}) {
    final nameController = TextEditingController(text: index != null ? companies[index]['name'] : "");
    final subController = TextEditingController(text: index != null ? companies[index]['sub'] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "Add New Company" : "Edit Company"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Company Name", prefixIcon: Icon(Icons.business))),
            const SizedBox(height: 10),
            TextField(controller: subController, decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.label))),
          ],
        ),
        actions: [
          if (index != null)
            TextButton(
              onPressed: () async {
                try {
                  final companyId = int.parse(companies[index]['id'] as String);
                  final response = await ApiService.deleteCompany(companyId);
                  if (response.statusCode == 200) {
                    await _fetchCompanies();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Company deleted"), backgroundColor: Colors.green),
                      );
                    }
                  } else {
                    final error = jsonDecode(response.body)['error'] ?? 'Failed to delete';
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                if (index == null) {
                  // Add new company to database
                  final response = await ApiService.addCompany(nameController.text, subController.text);
                  if (response.statusCode == 201) {
                    await _fetchCompanies();
                    if (mounted) Navigator.pop(context);
                  } else {
                    final error = jsonDecode(response.body)['error'];
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  // For now, local-only editing. Database update can be added later.
                  setState(() {
                    companies[index] = {
                      ...companies[index],
                      "name": nameController.text,
                      "sub": subController.text,
                    };
                  });
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- BUILDER METHODS ---
  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: isDesktop ? null : AppBar(
        title: const Text("TPO Portal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: _buildTabBar(),
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSideNav(),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildDesktopHeader(),
                _buildSearchBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCompanyTab(isDesktop),
                      _buildDriveTab(isDesktop),
                      _buildApplicationTab(),
                      _buildResultTab(),
                      _buildAnnounceTab(),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Search across records...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  // --- TAB CONTENT ---

  Widget _buildCompanyTab(bool isDesktop) {
    final filtered = companies.where((c) => c['name']!.toLowerCase().contains(_searchQuery)).toList();
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        childAspectRatio: 3,
        crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.indigoAccent, child: Icon(Icons.business, color: Colors.white)),
          title: Text(filtered[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(filtered[i]['sub']!),
          trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showCompanyDialog(index: i)),
        ),
      ),
    );
  }

  Widget _buildApplicationTab() {
    final filtered = applications.where((a) => a['student']!.toLowerCase().contains(_searchQuery)).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.person_outline, color: Colors.blue),
          title: Text(filtered[i]['student']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Applied for ${filtered[i]['role']}"),
          trailing: Text(filtered[i]['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildAnnounceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: announcements.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(announcements[i]['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(announcements[i]['time']!, style: const TextStyle(fontSize: 12, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcements[i]['desc']!),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSideNav() {
    return NavigationRail(
      backgroundColor: Colors.white,
      elevation: 1,
      selectedIndex: _tabController.index,
      onDestinationSelected: (index) => _tabController.animateTo(index),
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
      leading: const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircleAvatar(child: Icon(Icons.admin_panel_settings))),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.business), label: Text('Companies')),
        NavigationRailDestination(icon: Icon(Icons.event), label: Text('Drives')),
        NavigationRailDestination(icon: Icon(Icons.assignment_ind), label: Text('Apps')),
        NavigationRailDestination(icon: Icon(Icons.emoji_events), label: Text('Results')),
        NavigationRailDestination(icon: Icon(Icons.campaign), label: Text('News')),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Manage recruitment cycles and students", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text("Export Reports"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.indigo,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.indigo,
      tabs: const [Tab(text: 'Companies'), Tab(text: 'Drives'), Tab(text: 'Apps'), Tab(text: 'Results'), Tab(text: 'Announce')],
    );
  }

  Widget _buildDriveTab(bool isDesktop) {
    final filtered = drives.where((d) => d['title'].toLowerCase().contains(_searchQuery)).toList();
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildDriveActionCard(i, filtered[i]['title'], filtered[i]['elig'], filtered[i]['status'], filtered[i]['color']),
    );
  }

  Widget _buildDriveActionCard(int index, String title, String eligibility, String status, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text("Criteria: $eligibility", style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
            const Spacer(),
            Row(
              children: [
                TextButton.icon(onPressed: () => _deleteItem(drives, index), icon: const Icon(Icons.delete_outline, size: 18), label: const Text("Remove"), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                const Spacer(),
                OutlinedButton(onPressed: () {}, child: const Text("Applicants")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResultTab() {
    final filtered = companies.where((c) => c['name']!.toLowerCase().contains(_searchQuery)).toList();
    
    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No posted jobs yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filtered.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business_center, color: Colors.white, size: 28),
          ),
          title: Text(
            filtered[i]['name']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.indigo,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  filtered[i]['sub']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Active",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildContextualFAB() {
    switch (_tabController.index) {
      case 0: return FloatingActionButton.extended(onPressed: () => _showCompanyDialog(), label: const Text("New Company"), icon: const Icon(Icons.add));
      case 4: return FloatingActionButton.extended(onPressed: () => _showAnnouncementDialog(), label: const Text("Post News"), icon: const Icon(Icons.campaign), backgroundColor: Colors.orange);
      default: return null;
    }
  }
}