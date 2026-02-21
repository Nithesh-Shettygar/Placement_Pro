import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:placementpro/screens/student/activity_view.dart';
import 'package:placementpro/screens/student/home_view.dart';
import 'package:placementpro/screens/student/placement_view.dart';
import 'package:placementpro/screens/student/profile_view.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const StudentDashboard({super.key, required this.userData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    final List<Widget> _pages = [
      HomePage(userData: widget.userData, themeColor: themeColor),
      const PlacementPage(),
      ActivityPage(userData: widget.userData),
      ProfilePage(userData: widget.userData),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint: If width is greater than 800, show Desktop View
        bool isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          extendBody: !isDesktop, // Floating bar effect only on mobile
          backgroundColor: const Color(0xFFF8FAFB),
          appBar: _buildResponsiveAppBar(themeColor, isDesktop),
          body: Row(
            children: [
              // --- Side Menu for Desktop ---
              if (isDesktop) _buildNavigationRail(themeColor),
              
              // --- Main Content Area ---
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
          // --- Bottom Bar for Mobile ---
          bottomNavigationBar: isDesktop ? null : _buildFantasticNavBar(themeColor),
        );
      },
    );
  }

  // --- Desktop Sidebar (Navigation Rail) ---
  Widget _buildNavigationRail(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.transparent,
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        labelType: NavigationRailLabelType.all,
        selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        useIndicator: true,
        indicatorColor: themeColor,
        destinations: const [
          NavigationRailDestination(icon: Icon(Icons.grid_view_rounded), label: Text('Home')),
          NavigationRailDestination(icon: Icon(Icons.rocket_launch_rounded), label: Text('Placement')),
          NavigationRailDestination(icon: Icon(Icons.auto_graph_rounded), label: Text('Activity')),
          NavigationRailDestination(icon: Icon(Icons.person_2_rounded), label: Text('Profile')),
        ],
      ),
    );
  }

  // --- Adaptive AppBar ---
  PreferredSizeWidget _buildResponsiveAppBar(Color themeColor, bool isDesktop) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: !isDesktop, // Center on mobile, left-aligned on desktop
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 24, letterSpacing: -0.5),
            children: [
              const TextSpan(text: 'Placement', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w400)),
              TextSpan(text: 'Pro', style: TextStyle(color: themeColor, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Mobile Floating Nav Bar ---
  Widget _buildFantasticNavBar(Color themeColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, "Home", 0, themeColor),
          _buildNavItem(Icons.rocket_launch_rounded, "Jobs", 1, themeColor),
          _buildNavItem(Icons.auto_graph_rounded, "Activity", 2, themeColor),
          _buildNavItem(Icons.person_2_rounded, "Profile", 3, themeColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color themeColor) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? themeColor : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade500, size: 24),
            if (isSelected) Padding(padding: const EdgeInsets.only(left: 8), child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}