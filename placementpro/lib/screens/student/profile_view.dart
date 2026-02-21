import 'package:flutter/material.dart';
import 'package:placementpro/screens/student/profile/profile_setting.dart';
import 'package:placementpro/screens/student/profile/resume.dart';
import 'package:placementpro/screens/student/profile/resume_parser.dart';
import 'package:placementpro/screens/student/profile/view_resume.dart';
import 'package:placementpro/landing/landing_view.dart';
import 'package:placementpro/services/resume_storage_service.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        double sidePadding = isDesktop ? constraints.maxWidth * 0.1 : 24;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(sidePadding, 120, sidePadding, 120),
          child: isDesktop 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Header and Settings Card
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildProfileHeader(themeColor),
                        const SizedBox(height: 40),
                        _buildSettingsCard(context, themeColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60),
                  // Right Side: Actions, Status, and Logout
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionGrid(context, themeColor),
                        const SizedBox(height: 30),
                        _buildResumeStatusCard(themeColor),
                        const SizedBox(height: 40),
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildProfileHeader(themeColor),
                  const SizedBox(height: 30),
                  _buildActionGrid(context, themeColor),
                  const SizedBox(height: 25),
                  _buildResumeStatusCard(themeColor),
                  const SizedBox(height: 25),
                  _buildSettingsCard(context, themeColor),
                  const SizedBox(height: 40),
                  _buildLogoutButton(context),
                ],
              ),
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildProfileHeader(Color theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 65,
          backgroundColor: theme.withOpacity(0.1),
          child: Text(userData['name']?[0] ?? 'S', 
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: theme)),
        ),
        const SizedBox(height: 15),
        Text(userData['name'] ?? 'Student Name', 
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(userData['email'] ?? 'student@university.edu', 
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, Color theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "View Resume",
                Icons.visibility_rounded,
                Colors.blue,
                () => _showResumePreview(context),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                context,
                "Update Resume",
                Icons.auto_fix_high_rounded,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpdateResumePage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "Upload Resume",
                Icons.upload_file_rounded,
                Colors.orange,
                () => _uploadResume(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, Color theme) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.settings_suggest_rounded, color: theme, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("App Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Notifications, Privacy, Security", style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeStatusCard(Color theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: Colors.teal, size: 28),
              const SizedBox(width: 12),
              const Text("Current_Resume.pdf", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Icon(Icons.check_circle, color: theme, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: 0.75, color: theme, backgroundColor: theme.withOpacity(0.1), minHeight: 8, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 12),
          const Text("ATS Optimization: 75/100", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          // Clear stored resume/session data and navigate back to landing
          try {
            await ResumeStorageService.clearResumeData();
          } catch (_) {}
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text("Logout Session", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showResumePreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 30),
            const Text("Resume Preview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Expanded(child: Center(child: Icon(Icons.picture_as_pdf_rounded, size: 120, color: Colors.redAccent))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close Preview")),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadResume(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumeParserPage(userData: userData),
      ),
    );
  }
}