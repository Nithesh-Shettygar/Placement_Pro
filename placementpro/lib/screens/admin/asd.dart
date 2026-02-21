import 'package:flutter/material.dart';

class OfficerDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;
  const OfficerDashboard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Officer Console',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text('Administrative Overview',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
            Text('Welcome, ${userData['name']} 💼',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 25),

            // Statistics Row
            Row(
              children: [
                Expanded(child: _buildSummaryStat('Total Students', '1,240', Colors.blue)),
                const SizedBox(width: 15),
                Expanded(child: _buildSummaryStat('Placed', '856', Colors.green)),
              ],
            ),
            const SizedBox(height: 30),

            // Action Section Header
            const Text('Management Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 15),

            // Management Action Cards
            _buildActionCard(
              context,
              icon: Icons.campaign_rounded,
              title: 'Create New Placement Drive',
              sub: 'Broadcast job details to eligible batches',
              color: themeColor,
              onTap: () {
                // Navigate to Post Drive Page
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.verified_user_rounded,
              title: 'Verify Student Data',
              sub: 'Approve or reject pending registrations',
              color: Colors.orange.shade700,
              onTap: () {
                // Navigate to Verification Page
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.analytics_rounded,
              title: 'Placement Reports',
              sub: 'Download hiring trends and data (CSV/PDF)',
              color: Colors.purple.shade700,
              onTap: () {
                // Navigate to Reports Page
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.settings_suggest_rounded,
              title: 'System Configuration',
              sub: 'Manage departments and eligibility criteria',
              color: Colors.grey.shade800,
              onTap: () {
                // Navigate to Settings
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Summary Stat Card Helper ---
  Widget _buildSummaryStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: color.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // --- Action Card Helper ---
  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String title, required String sub, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}