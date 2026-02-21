import 'package:flutter/material.dart';
import 'package:placementpro/screens/admin/student_view/student_detail.dart';
import 'package:placementpro/services/api_service.dart';
import 'dart:convert';

class StudentDirectoryPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const StudentDirectoryPage({super.key, required this.userData});

  @override
  State<StudentDirectoryPage> createState() => _StudentDirectoryPageState();
}

class _StudentDirectoryPageState extends State<StudentDirectoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _applications = [];
  bool _applicationsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Listen to tab changes to update side navigation index
    _tabController.addListener(() {
      setState(() {});
      if (_tabController.index == 2) {
        _fetchApplications();
      }
    });
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final response = await ApiService.getApplications();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _applications = data.cast<Map<String, dynamic>>();
          _applicationsLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching applications: $e');
      setState(() => _applicationsLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: isDesktop ? null : _buildMobileAppBar(),
      body: Row(
        children: [
          if (isDesktop) _buildSideNavigation(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResponsiveContainer(_buildDirectoryTab(isDesktop), isDesktop),
                      _buildResponsiveContainer(_buildAccessControlTab(), isDesktop),
                      _buildResponsiveContainer(_buildApplicationsTab(), isDesktop),
                      _buildResponsiveContainer(_buildPerformanceTab(), isDesktop),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- RESPONSIVE HELPERS ---

  AppBar _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text("Student Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue.shade800,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue.shade800,
        tabs: const [
          Tab(text: 'Directory'),
          Tab(text: 'Access Control'),
          Tab(text: 'Applications'),
          Tab(text: 'Performance'),
        ],
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
        NavigationRailDestination(icon: Icon(Icons.folder_shared), label: Text('Directory')),
        NavigationRailDestination(icon: Icon(Icons.security), label: Text('Access')),
        NavigationRailDestination(icon: Icon(Icons.assignment), label: Text('Apps')),
        NavigationRailDestination(icon: Icon(Icons.assessment), label: Text('Stats')),
      ],
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (isDesktop) ...[
            const Text("Student Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
          ],
          Expanded(
            flex: isDesktop ? 0 : 1,
            child: SizedBox(
              width: isDesktop ? 400 : double.infinity,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search USN, Name, or Branch...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveContainer(Widget child, bool isDesktop) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
        child: child,
      ),
    );
  }

  // --- MODIFIED DIRECTORY TAB ---

  Widget _buildDirectoryTab(bool isDesktop) {
    final List<Map<String, dynamic>> departments = [
      {'name': 'Computer Science', 'icon': Icons.computer, 'count': '420', 'color': Colors.blue},
      {'name': 'Information Tech', 'icon': Icons.language, 'count': '310', 'color': Colors.indigo},
      {'name': 'Electronics', 'icon': Icons.memory, 'count': '280', 'color': Colors.teal},
      {'name': 'Mechanical', 'icon': Icons.settings, 'count': '250', 'color': Colors.orange},
      {'name': 'Civil Eng.', 'icon': Icons.architecture, 'count': '190', 'color': Colors.brown},
      {'name': 'MBA', 'icon': Icons.business_center, 'count': '150', 'color': Colors.purple},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2, // 4 columns on desktop, 2 on mobile
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isDesktop ? 1.3 : 1.1,
      ),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final dept = departments[index];
        return _buildDepartmentCard(dept);
      },
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DepartmentStudentListPage(
            deptName: dept['name'],
            themeColor: dept['color'],
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: dept['color'].withOpacity(0.1),
              child: Icon(dept['icon'], color: dept['color']),
            ),
            const SizedBox(height: 12),
            Text(dept['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            Text('${dept['count']} Students', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // --- PLACEHOLDERS ---
  Widget _buildAccessControlTab() {
    if (_applicationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_applications.isEmpty) {
      return const Center(child: Text("No application notifications"));
    }

    // Filter for accepted applications (notifications)
    final acceptedApps = _applications.where((app) => app['status'] == 'Accepted').toList();
    final rejectedApps = _applications.where((app) => app['status'] == 'Rejected').toList();
    final pendingApps = _applications.where((app) => app['status'] == 'Applied').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accepted Notifications
          if (acceptedApps.isNotEmpty) ...[
            const Text('✅ Accepted Applications', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 12),
            ...acceptedApps.map((app) => _buildNotificationCard(
              app,
              Colors.green,
              '🎉 Application Accepted',
              'Student has been accepted for the position',
            )),
            const SizedBox(height: 24),
          ],

          // Rejected Notifications
          if (rejectedApps.isNotEmpty) ...[
            const Text('❌ Rejected Applications', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 12),
            ...rejectedApps.map((app) => _buildNotificationCard(
              app,
              Colors.red,
              '❌ Application Rejected',
              'Student application was not accepted',
            )),
            const SizedBox(height: 24),
          ],

          // Pending Notifications
          if (pendingApps.isNotEmpty) ...[
            const Text('⏳ Pending Applications', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 12),
            ...pendingApps.map((app) => _buildNotificationCard(
              app,
              Colors.blue,
              '⏳ Awaiting Review',
              'Please review and accept/reject this application',
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> app,
    Color statusColor,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: statusColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(app['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  )),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student: ${app['student_name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Company: ${app['company_name']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text('Role: ${app['role']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Applied: ${app['applied_at']}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          if (app['status'] == 'Applied') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService.updateApplicationStatus(app['id'], 'Accepted');
                      await _fetchApplications();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService.updateApplicationStatus(app['id'], 'Rejected');
                      await _fetchApplications();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildApplicationsTab() {
    if (_applicationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_applications.isEmpty) {
      return const Center(child: Text("No applications yet"));
    }

    final filtered = _applications
        .where((app) {
          final studentName = (app['student_name'] as String?) ?? '';
          final companyName = (app['company_name'] as String?) ?? '';
          final searchText = _searchController.text.toLowerCase();
          return studentName.toLowerCase().contains(searchText) || 
                 companyName.toLowerCase().contains(searchText);
        })
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No matching applications"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final app = filtered[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(((app['student_name'] as String?) ?? 'S')[0], 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
              ),
            ),
            title: Text((app['student_name'] as String?) ?? 'Unknown', 
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Company: ${(app['company_name'] as String?) ?? 'Unknown'}'),
                Text('Role: ${(app['role'] as String?) ?? 'Unknown'}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(app['status'] as String?).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(app['status'] as String? ?? 'Applied',
                style: TextStyle(
                  color: _getStatusColor(app['status'] as String?),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                )),
            ),
            onTap: () => _showApplicationDetails(context, app),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showApplicationDetails(BuildContext context, Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${app['student_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${app['student_email']}'),
            const SizedBox(height: 8),
            Text('Company: ${app['company_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Role: ${app['role']}'),
            const SizedBox(height: 8),
            Text('Applied: ${app['applied_at']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Text('Status: ${app['status']}', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(app['status']),
              )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateApplicationStatus(app['id'], 'Accepted');
              await _fetchApplications();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateApplicationStatus(app['id'], 'Rejected');
              await _fetchApplications();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  Widget _buildPerformanceTab() => const Center(child: Text("Performance Content"));
}