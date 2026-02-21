import 'package:flutter/material.dart';
import 'package:placementpro/screens/admin/alumini_view.dart';
import 'package:placementpro/screens/admin/home_view.dart';
import 'package:placementpro/screens/admin/job_view.dart';
import 'package:placementpro/screens/admin/placement_view.dart';
import 'package:placementpro/screens/admin/student_view.dart';
import 'package:placementpro/landing/landing_view.dart';
import 'package:placementpro/services/resume_storage_service.dart';
import 'package:placementpro/services/company_storage_service.dart';


class OfficerMainScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const OfficerMainScreen({super.key, required this.userData});

  @override
  State<OfficerMainScreen> createState() => _OfficerMainScreenState();
}

class _OfficerMainScreenState extends State<OfficerMainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 1000;
        final bool isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1000;

        final List<Widget> _pages = [
          OfficerDashboardHome(userData: widget.userData, onNavigationRequest: _onItemTapped),
          StudentDirectoryPage(userData: widget.userData),
          JobPortalsPage(userData: widget.userData),
          AlumniNetworkPage(userData: widget.userData),
          PlacementStatsPage(userData: widget.userData),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FA),
          appBar: isDesktop ? null : _buildMobileAppBar(widget.userData),
          
          // Updated Standard Bottom Navigation Bar
          bottomNavigationBar: isDesktop ? null : _buildStandardBottomNav(),
          
          // Set to false to make the nav bar solid/sticky at bottom
          extendBody: false, 

          body: Row(
            children: [
              if (isDesktop) _buildSidebar(true),
              if (isTablet) _buildSidebar(false),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop || isTablet) _buildTopHeader(widget.userData),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: IndexedStack(
                          key: ValueKey<int>(_selectedIndex),
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NEW: Standard Sticky Bottom Navigation Bar ---
  Widget _buildStandardBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures 5 items fit well
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.blueGrey.shade400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true, // Labels are now always required
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search_rounded),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            activeIcon: Icon(Icons.rocket_launch_rounded),
            label: 'Drives',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school_rounded),
            label: 'Alumni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // --- Professional Mobile AppBar ---
  PreferredSizeWidget _buildMobileAppBar(Map<String, dynamic> userData) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Placement Pro',
        style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 20),
      ),
      shape: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B)),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade50,
            child: Text(
              userData['name']?[0] ?? 'O',
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  // --- Sidebar Logic (Kept for Desktop Compatibility) ---
  Widget _buildSidebar(bool extended) {
    return Container(
      width: extended ? 260 : 80,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          _buildSidebarLogo(extended),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _sidebarItem(Icons.dashboard_rounded, 'Dashboard', 0, extended),
                _sidebarItem(Icons.people_alt_rounded, 'Student Directory', 1, extended),
                _sidebarItem(Icons.business_center_rounded, 'Placement Drives', 2, extended),
                _sidebarItem(Icons.school_rounded, 'Alumni Network', 3, extended),
                _sidebarItem(Icons.analytics_rounded, 'Insights', 4, extended),
              ],
            ),
          ),
          _sidebarFooter(extended),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index, bool extended) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: extended ? 16 : 0, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
            ? const Border(left: BorderSide(color: Colors.blue, width: 4))
            : null,
        ),
        child: Row(
          mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.blueGrey.shade300, size: 22),
            if (extended) ...[
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blueGrey.shade300,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(Map<String, dynamic> userData) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Text(
            ['Main Dashboard', 'Student Records', 'Drive Management', 'Alumni Hub', 'Reports'][_selectedIndex],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.notifications_rounded, color: Colors.blueGrey), onPressed: () {}),
          const VerticalDivider(indent: 20, endIndent: 20, width: 30),
          Text(userData['name'] ?? 'Officer', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: Text(userData['name']?[0] ?? 'O', style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarLogo(bool extended) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: extended 
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.blue, size: 28),
                SizedBox(width: 10),
                Text('PlacementPro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            )
          : const Icon(Icons.bolt_rounded, color: Colors.blue, size: 32),
    );
  }

  Widget _sidebarFooter(bool extended) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: extended 
          ? OutlinedButton.icon(
              onPressed: () async {
                try {
                  await ResumeStorageService.clearResumeData();
                  await CompanyStorageService.clear();
                } catch (_) {}
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
            )
          : IconButton(
              onPressed: () async {
                try {
                  await ResumeStorageService.clearResumeData();
                  await CompanyStorageService.clear();
                } catch (_) {}
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            ),
    );
  }
}