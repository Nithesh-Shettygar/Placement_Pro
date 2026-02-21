import 'package:flutter/material.dart';
import 'package:placementpro/auth/login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect if the screen is wide (Desktop/Tablet)
    bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Side: University Branding (Only visible on Desktop)
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.blue.shade50,
                child: Stack(
                  children: [
                    // University Background Image Placeholder
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1541339907198-e08756ebafe3?auto=format&fit=crop&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'PlacementPro',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Empowering the next generation of professionals.',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildInfoStat('500+', 'Partner Companies'),
                          _buildInfoStat('95%', 'Placement Rate'),
                          _buildInfoStat('10k+', 'Alumni Network'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right Side: Portal Selection (Visible on both)
          Expanded(
            flex: 4,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDesktop) ...[
                      const Icon(Icons.bolt, color: Colors.blue, size: 40),
                      const SizedBox(height: 20),
                    ],
                    const Text(
                      'Select Portal',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your role to continue to the dashboard.',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 40),
                    _buildRoleCard(
                      context,
                      title: 'Placement Officer',
                      subtitle: 'Coordinate drives and manage data',
                      icon: Icons.admin_panel_settings_outlined,
                      accentColor: Colors.blue,
                      role: 'officer',
                    ),
                    _buildRoleCard(
                      context,
                      title: 'Student',
                      subtitle: 'Browse jobs and track applications',
                      icon: Icons.school_outlined,
                      accentColor: Colors.teal,
                      role: 'student',
                    ),
                    _buildRoleCard(
                      context,
                      title: 'Alumni',
                      subtitle: 'Share opportunities and mentor',
                      icon: Icons.auto_awesome_outlined,
                      accentColor: Colors.indigo,
                      role: 'alumni',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat(String title, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
          Text(label, style: TextStyle(fontSize: 16, color: Colors.blue.shade900)),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String role,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(role: title, roleType: role),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}