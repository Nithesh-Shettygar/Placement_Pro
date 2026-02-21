import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:placementpro/services/resume_storage_service.dart';
import 'package:placementpro/screens/chatbot/chatbot_screen.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Color themeColor;

  const HomePage({super.key, required this.userData, required this.themeColor});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int atsScore = 0;

  @override
  void initState() {
    super.initState();
    _loadAts();
  }

  Future<void> _loadAts() async {
    final data = await ResumeStorageService.getResumeData();
    if (data != null) {
      final stored = data['ats'] ?? data['score'] ?? data['ats_score'] ?? '';
      final parsed = int.tryParse(stored.toString()) ?? 0;
      if (mounted) setState(() => atsScore = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Soft neutral background
      body: Stack(
        children: [
          // Background decorative blobs for Glassmorphism effect
          Positioned(top: -100, right: -100, child: _buildBlob(300, widget.themeColor.withOpacity(0.1))),
          Positioned(bottom: -50, left: -50, child: _buildBlob(200, Colors.purple.withOpacity(0.05))),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 1000;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 20,
                    vertical: 20,
                  ),
                  child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatbotScreen(themeColor: widget.themeColor),
            ),
          );
        },
        backgroundColor: widget.themeColor,
        elevation: 8,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- Layout Wrappers ---

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Content Area
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDesktop: true),
                const SizedBox(height: 40),
                _buildMetricGrid(crossAxisCount: 2),
                const SizedBox(height: 30),
                _buildStatsRow(),
                const SizedBox(height: 40),
                const Text("Activity Insights", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildPlaceholderChart(), // Visual anchor
              ],
            ),
          ),
        ),
        const SizedBox(width: 40),
        // Glassmorphic Sidebar
        Expanded(
          flex: 1,
          child: _buildGlassContainer(
            child: Column(
              children: [
                _buildSidebarSection("Notifications", [
                  _buildNotificationTile("Google", "Application viewed", "2h ago"),
                  _buildNotificationTile("System", "Update profile", "5h ago"),
                  _buildNotificationTile("Tesla", "New job posted", "1d ago"),
                ]),
                const Divider(height: 40, color: Colors.black12),
                _buildSidebarSection("Quick Links", [
                  _buildLinkTile("Upcoming Interviews", Icons.calendar_today, Colors.blue),
                  _buildLinkTile("Saved Jobs", Icons.bookmark_outline, Colors.orange),
                  _buildLinkTile("Career Guidance", Icons.lightbulb_outline, Colors.green),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDesktop: false),
          const SizedBox(height: 25),
          _buildMetricGrid(crossAxisCount: 1),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 30),
          const Text("Recent Updates", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildGlassContainer(
            child: Column(
              children: [
                _buildNotificationTile("Google", "Application viewed", "2h ago"),
                _buildNotificationTile("System", "Update profile", "5h ago"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK,',
          style: TextStyle(
            letterSpacing: 1.5,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: widget.themeColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.userData['name']} 👋',
          style: TextStyle(
            fontSize: isDesktop ? 42 : 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid({required int crossAxisCount}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 2.2,
      children: [
        _buildBoxCard("Profile Completion", "85%", Icons.person_outline, Colors.teal),
        _buildBoxCard("Resume ATS Score", "${atsScore.clamp(0,100)}/100", Icons.description_outlined, Colors.purple),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatMiniCard('Applied', '08', Colors.blue)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatMiniCard('Eligible', '24', Colors.green)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatMiniCard('Shortlisted', '03', Colors.orange)),
      ],
    );
  }

  // --- Morphic Building Blocks ---

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBoxCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatMiniCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          const BoxShadow(color: Color(0x0A000000), blurRadius: 40, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Helper Helpers ---

  Widget _buildSidebarSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildNotificationTile(String title, String sub, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            height: 10, width: 10,
            decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLinkTile(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildPlaceholderChart() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Center(child: Text("Analytics Graph Placeholder", style: TextStyle(color: Colors.grey.shade400))),
    );
  }
}