import 'package:flutter/material.dart';
import 'package:placementpro/services/api_service.dart';
import 'dart:convert';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  // Modern Azure Palette
  final Color primaryNavy = const Color(0xFF1A237E);
  final Color electricBlue = const Color(0xFF2979FF);
  final Color skyBlue = const Color(0xFFE3F2FD);

  List<Map<String, dynamic>> postedJobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostedJobs();
  }

  Future<void> _fetchPostedJobs() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getCompanies(alumniOnly: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          postedJobs = data.map((job) => {
            'id': job['id'],
            'name': job['name'] as String,
            'category': job['category'] as String,
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching jobs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background gradient is handled by Dashboard
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Offset for the custom bottom nav
        child: FloatingActionButton.extended(
          onPressed: () => _showCreateJobSheet(context),
          label: const Text("Create Job", style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add_rounded),
          backgroundColor: electricBlue,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPostedJobs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Posted Jobs", "${postedJobs.length} Openings"),
                    const SizedBox(height: 20),
                    if (postedJobs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.work_outline, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                "No jobs posted yet",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Click 'Create Job' to post an opportunity",
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...postedJobs.map((job) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildManageJobCard(
                          context,
                          title: job['name'],
                          applicants: 0,
                          status: "Active",
                          shortlisted: 0,
                          eligibility: job['category'],
                        ),
                      )),
                    const SizedBox(height: 120), // Padding for the bottom nav
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primaryNavy.withOpacity(0.05), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Text(count, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: electricBlue)),
        ),
      ],
    );
  }

  Widget _buildManageJobCard(
    BuildContext context, {
    required String title,
    required int applicants,
    required String status,
    required int shortlisted,
    required String eligibility,
    bool isClosed = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isClosed ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(28), // Squircle
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.06), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: primaryNavy)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, size: 16, color: electricBlue),
                  const SizedBox(width: 6),
                  Text(eligibility, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isClosed ? Colors.grey.shade200 : electricBlue.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text(status, style: TextStyle(
                color: isClosed ? Colors.grey.shade600 : electricBlue, 
                fontWeight: FontWeight.bold, 
                fontSize: 11
              )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: skyBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(Icons.people_alt_rounded, "$applicants"),
                  _buildQuickAction(Icons.how_to_reg_rounded, "$shortlisted"),
                  _buildQuickAction(Icons.edit_calendar_rounded, "Manage"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: primaryNavy),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryNavy)),
      ],
    );
  }

  void _showCreateJobSheet(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: primaryNavy, // Navy Glassmorphism
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32, 
          left: 32, right: 32, top: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 30),
            const Text("New Recruitment", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 25),
            _buildGlassTextField("Job Title", titleController),
            const SizedBox(height: 16),
            _buildGlassTextField("Category (e.g., Tech • Tier 1)", categoryController),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _postJobOpportunity(context, titleController.text, categoryController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: electricBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: const Text("Post Opportunity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Future<void> _postJobOpportunity(BuildContext context, String title, String category) async {
    // Validation
    if (title.trim().isEmpty || category.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final response = await ApiService.addCompany(title, category, postedByAlumni: true);
      
      if (response.statusCode == 201) {
        Navigator.pop(context); // Close modal
        
        // Refresh the jobs list to show the new job
        await _fetchPostedJobs();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Job posted successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to post job';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}