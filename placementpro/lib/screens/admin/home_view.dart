import 'package:flutter/material.dart';
import 'package:placementpro/services/api_service.dart';
import 'dart:convert';

class OfficerDashboardHome extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(int) onNavigationRequest;

  const OfficerDashboardHome({
    super.key,
    required this.userData,
    required this.onNavigationRequest,
  });

  @override
  State<OfficerDashboardHome> createState() => _OfficerDashboardHomeState();
}

class _OfficerDashboardHomeState extends State<OfficerDashboardHome> {
  int _studentCount = 0;
  int _alumniCount = 0;
  int _companiesCount = 0;
  int _drivesCount = 0;
  int _approvalsCount = 0;
  int _placedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiService.getStats();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _studentCount = (data['students'] as int?) ?? 0;
            _alumniCount = (data['alumni'] as int?) ?? 0;
            _companiesCount = (data['companies'] as int?) ?? 0;
            _drivesCount = (data['drives'] as int?) ?? 0;
            _approvalsCount = (data['approvals'] as int?) ?? 0;
            _placedCount = (data['placed'] as int?) ?? 0;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade700;
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;
    final bool isTablet = width > 600 && width <= 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40.0 : 20.0, 
              vertical: 20
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.8 : 1.5,
                  children: [
                    _buildSummaryStat('Total Students', '$_studentCount', Colors.blue, Icons.school_rounded),
                    _buildSummaryStat('Total Alumni', '$_alumniCount', Colors.purple, Icons.group_rounded),
                    _buildSummaryStat('Total Companies', '$_companiesCount', Colors.orange, Icons.business_rounded),
                    _buildSummaryStat('Active Drives', '$_drivesCount', Colors.green, Icons.campaign_rounded),
                    _buildSummaryStat('Pending Approvals', '$_approvalsCount', Colors.redAccent, Icons.pending_actions_rounded),
                    _buildSummaryStat('Placed Overall', '$_placedCount', Colors.teal, Icons.verified_user_rounded),
                  ],
                ),
                const SizedBox(height: 40),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildPerformanceSection(),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        flex: 2,
                        child: _buildActionSection(themeColor),
                      ),
                    ],
                  )
                else ...[
                  _buildPerformanceSection(),
                  const SizedBox(height: 30),
                  _buildActionSection(themeColor),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Grouped Performance UI
  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Placement Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildInfoCard('Highest Package', '45.0 LPA', Colors.amber.shade800, Icons.workspace_premium),
            const SizedBox(width: 12),
            _buildInfoCard('Average Package', '8.5 LPA', Colors.blueGrey, Icons.analytics_rounded),
          ],
        ),
        const SizedBox(height: 25),
        _buildDeptList(),
      ],
    );
  }

  // Grouped Action UI
  Widget _buildActionSection(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Management Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildActionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Manage Placement Drives',
          sub: 'Schedule and track recruitment',
          color: themeColor,
          onTap: () => widget.onNavigationRequest(2),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.notifications_active_rounded,
          title: 'Broadcast Announcement',
          sub: 'Send updates to students',
          color: Colors.deepOrange,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.event_note_rounded,
          title: 'Upcoming Interviews',
          sub: '4 scheduled for today',
          color: Colors.indigo,
          onTap: () {},
        ),
      ],
    );
  }

  // --- REUSABLE COMPONENTS (Kept mostly similar but optimized for cards) ---

  Widget _buildSummaryStat(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptList() {
    final depts = [
      {'name': 'Computer Science', 'percent': 0.92},
      {'name': 'Information Tech', 'percent': 0.88},
      {'name': 'Electronics (ECE)', 'percent': 0.75},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: depts.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${((d['percent'] as double) * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: d['percent'] as double,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String sub, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}