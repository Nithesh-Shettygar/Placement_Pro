import 'package:flutter/material.dart';
import 'package:placementpro/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActivityPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ActivityPage({super.key, required this.userData});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String _studentEmail = '';
  String _studentName = '';

  DateTime _safeParseDate(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    final raw = value.toString().trim();
    if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    final normalized = raw.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Fetch applications when history tab is selected
      if (_tabController.index == 1) {
        _fetchData();
      }
    });
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();

      final widgetEmail = (widget.userData['email'] ?? '').toString().trim();
      final widgetName = (widget.userData['name'] ?? '').toString().trim();
      if (widgetEmail.isNotEmpty) {
        _studentEmail = widgetEmail.toLowerCase();
      }
      if (widgetName.isNotEmpty) {
        _studentName = widgetName.toLowerCase();
      }
      
      // Try to get student email from multiple sources
      String? email = prefs.getString('studentEmail');
      
      if (email == null) {
        // Try from studentData JSON
        final studentDataStr = prefs.getString('studentData');
        if (studentDataStr != null) {
          final studentData = jsonDecode(studentDataStr) as Map;
          email = studentData['email'] as String?;
        }
      }

      if (email == null) {
        // Try from userData
        final userDataStr = prefs.getString('userData');
        if (userDataStr != null) {
          final userData = jsonDecode(userDataStr) as Map;
          email = userData['email'] as String?;
        }
      }

      if (email != null) {
        _studentEmail = email.trim().toLowerCase();
        if (_studentName.isEmpty) {
          final studentDataStr = prefs.getString('studentData');
          if (studentDataStr != null && studentDataStr.isNotEmpty) {
            final studentData = jsonDecode(studentDataStr) as Map;
            _studentName = (studentData['name'] ?? '').toString().trim().toLowerCase();
          }
        }
        await _fetchApplications();
      } else {
        if (_studentEmail.isNotEmpty || _studentName.isNotEmpty) {
          await _fetchApplications();
          return;
        }
        setState(() {
          _isLoading = false;
          _applications = [];
        });
        print('Warning: No student email found in storage');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchApplications() async {
    try {
      final response = await ApiService.getStudentApplications(
        studentEmail: _studentEmail,
        studentName: _studentName,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        setState(() {
          _applications = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        print('Error: Status code ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching applications: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;
    _applications.sort((a, b) => 
        _safeParseDate(b['applied_at']).compareTo(_safeParseDate(a['applied_at'])));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          // --- Tab Bar for Navigation ---
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: themeColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: themeColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Active Tracking"),
                Tab(text: "Application History"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResponsiveActiveTracking(context, themeColor),
                _buildHistoryList(),
              ],
            ),
          ),
          ],
        ),
    );
  }

  // --- RESPONSIVE LAYOUT LOGIC ---
  Widget _buildResponsiveActiveTracking(BuildContext context, Color theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          // DESKTOP VIEW: Multi-column side-by-side
          return SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Interviews
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Upcoming Interviews", Icons.event_available),
                      const SizedBox(height: 16),
                      _buildInterviewCard("Microsoft", "Final Technical Round", "Tomorrow, 10:00 AM", theme),
                      _buildInterviewCard("Adobe", "HR Interview", "25th Oct, 02:00 PM", theme),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Right Column: Application Progress
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Application Progress", Icons.trending_up),
                      const SizedBox(height: 16),
                      _buildStatusTile("Google", "Software Engineer", "Shortlisted", Colors.green, 0.75),
                      _buildStatusTile("Tesla", "Data Analyst", "Assessment Pending", Colors.orange, 0.4),
                      _buildStatusTile("Amazon", "Cloud Intern", "Under Review", Colors.blue, 0.25),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // MOBILE VIEW: Single column scroll
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Upcoming Interviews", Icons.event_available),
                const SizedBox(height: 12),
                _buildInterviewCard("Microsoft", "Final Technical Round", "Tomorrow, 10:00 AM", theme),
                _buildInterviewCard("Adobe", "HR Interview", "25th Oct, 02:00 PM", theme),
                const SizedBox(height: 32),
                _buildSectionHeader("Application Progress", Icons.trending_up),
                const SizedBox(height: 12),
                _buildStatusTile("Google", "Software Engineer", "Shortlisted", Colors.green, 0.75),
                _buildStatusTile("Tesla", "Data Analyst", "Assessment Pending", Colors.orange, 0.4),
                _buildStatusTile("Amazon", "Cloud Intern", "Under Review", Colors.blue, 0.25),
              ],
            ),
          );
        }
      },
    );
  }

  // --- TAB 2: APPLICATION HISTORY ---
  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No applications yet',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Separate applications by status
    final accepted = _applications.where((app) => (app['status'] ?? 'Applied') == 'Accepted').toList();
    final rejected = _applications.where((app) => (app['status'] ?? 'Applied') == 'Rejected').toList();
    final pending = _applications.where((app) => (app['status'] ?? 'Applied') == 'Applied').toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Refresh Button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Accepted Section
        if (accepted.isNotEmpty) ...[
          _buildSectionHeader('✅ Accepted', Icons.check_circle),
          const SizedBox(height: 12),
          ...accepted.map((app) => _buildHistoryTile(
            app['company_name'] as String,
            app['role'] as String,
            'Accepted',
            app['applied_at'] as String,
            Colors.green,
          )),
          const SizedBox(height: 20),
        ],

        // Rejected Section
        if (rejected.isNotEmpty) ...[
          _buildSectionHeader('❌ Rejected', Icons.cancel),
          const SizedBox(height: 12),
          ...rejected.map((app) => _buildHistoryTile(
            app['company_name'] as String,
            app['role'] as String,
            'Rejected',
            app['applied_at'] as String,
            Colors.red,
          )),
          const SizedBox(height: 20),
        ],

        // Pending Section
        if (pending.isNotEmpty) ...[
          _buildSectionHeader('⏳ Pending Review', Icons.hourglass_top),
          const SizedBox(height: 12),
          ...pending.map((app) => _buildHistoryTile(
            app['company_name'] as String,
            app['role'] as String,
            'Applied',
            app['applied_at'] as String,
            Colors.blue,
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
        ],
      ),
    );
  }

  // --- REFINED HELPER WIDGETS ---

  Widget _buildInterviewCard(String company, String round, String time, Color theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.videocam_rounded, color: theme),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(round, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: theme,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Join"),
          )
        ],
      ),
    );
  }

  Widget _buildStatusTile(String company, String role, String status, Color color, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(role, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              color: color,
              minHeight: 8,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String company, String role, String status, String date, Color statusColor) {
    // Parse and format the date
    String formattedDate = date;
    try {
      final parsedDate = DateTime.parse(date);
      formattedDate = '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      // Keep original date if parsing fails
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            status == 'Accepted'
                ? Icons.check_circle
                : status == 'Rejected'
                    ? Icons.cancel
                    : Icons.hourglass_empty,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(company, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$role • $formattedDate"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}