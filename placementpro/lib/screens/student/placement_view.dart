import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:placementpro/screens/student/placement/company_details.dart';
import 'package:placementpro/services/api_service.dart';
import 'dart:convert';

class PlacementPage extends StatefulWidget {
  const PlacementPage({super.key});

  @override
  State<PlacementPage> createState() => _PlacementPageState();
}

class _PlacementPageState extends State<PlacementPage> {
  List<Map<String, dynamic>> _companies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final response = await ApiService.getCompanies();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _companies = data.map((c) => {
            'id': c['id'],
            'name': c['name'] as String,
            'category': c['category'] as String,
          }).cast<Map<String, dynamic>>().toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching companies: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        double sidePadding = isDesktop ? 60 : 20;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFB),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(sidePadding, 110, sidePadding, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDesktop),
                const SizedBox(height: 25),
                _buildSearchBar(),
                const SizedBox(height: 35),
                const Text('Upcoming Drives', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildGlassDriveNotify("Microsoft", "Direct Interview", Colors.blue),
                      _buildGlassDriveNotify("Adobe", "OA on 24th Oct", Colors.redAccent),
                      _buildGlassDriveNotify("Intel", "Registration Closing", Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Open Opportunities', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    TextButton(onPressed: () {}, child: const Text("Filter Results")),
                  ],
                ),
                const SizedBox(height: 15),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _companies.isEmpty
                        ? const Center(child: Text("No companies added yet"))
                        : isDesktop 
                            ? GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.5,
                                children: _getCompanyTiles(context, themeColor),
                              )
                            : Column(children: _getCompanyTiles(context, themeColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getCompanyTiles(BuildContext context, Color theme) {
    return _companies.map((c) {
      final name = c['name'] as String;
      final role = '${c['category']} Opportunities';
      return _buildMorphicCompanyTile(context, name, role, 'Various', 'TBD', theme);
    }).toList();
  }

  Widget _buildHeader(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Placement Cell", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
        Text(isDesktop ? "Find Your Dream Opportunity" : "Opportunities", 
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1C1E))),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search roles, skills, or companies...',
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.teal),
          suffixIcon: const Icon(Icons.tune_rounded, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildGlassDriveNotify(String company, String status, Color color) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(Icons.bolt_rounded, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(company, style: TextStyle(fontWeight: FontWeight.w800, color: color.withOpacity(0.9), fontSize: 16)),
                      Text(status, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorphicCompanyTile(BuildContext context, String name, String role, String loc, String package, Color theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: theme.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(name[0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1A1C1E))),
                const SizedBox(height: 2),
                Text("$name • $loc", style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: theme.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(package, style: TextStyle(color: theme, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // --- NAVIGATION TRIGGER ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailsPage(
                        companyName: name,
                        role: role,
                        package: package,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              // Also made "View Details" clickable
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailsPage(
                        companyName: name,
                        role: role,
                        package: package,
                      ),
                    ),
                  );
                },
                child: Text("View Details", 
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.grey.shade400, 
                    decoration: TextDecoration.underline
                  )
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}