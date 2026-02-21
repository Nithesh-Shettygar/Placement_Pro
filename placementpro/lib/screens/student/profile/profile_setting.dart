import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive width for settings list
          double horizontalPadding = constraints.maxWidth > 800 ? constraints.maxWidth * 0.2 : 20;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Account Management"),
                _buildSettingsGroup([
                  _buildSettingsTile("Edit Personal Info", Icons.person_outline, Colors.blue),
                  _buildSettingsTile("Change Password", Icons.lock_outline, Colors.orange),
                  _buildSettingsTile("Notification Preferences", Icons.notifications_none, Colors.purple),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader("Privacy & Security"),
                _buildSettingsGroup([
                  _buildSettingsTile("Resume Visibility", Icons.visibility_outlined, Colors.teal),
                  _buildSettingsTile("Two-Factor Authentication", Icons.security, Colors.green),
                  _buildSettingsTile("Data & Permissions", Icons.admin_panel_settings_outlined, Colors.blueGrey),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader("System & Support"),
                _buildSettingsGroup([
                  _buildSettingsTile("Help Center", Icons.help_outline, Colors.indigo),
                  _buildSettingsTile("Terms & Conditions", Icons.description_outlined, Colors.grey),
                  _buildSettingsTile("App Version", Icons.info_outline, Colors.grey, trailingText: "1.0.4"),
                ]),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(title, 
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: tiles),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color iconColor, {String? trailingText}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: trailingText != null 
        ? Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 13))
        : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}