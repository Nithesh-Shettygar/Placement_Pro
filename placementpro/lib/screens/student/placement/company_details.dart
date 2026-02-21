import 'package:flutter/material.dart';
import 'package:placementpro/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CompanyDetailsPage extends StatefulWidget {
  final String companyName;
  final String role;
  final String package;
  final int? companyId;

  const CompanyDetailsPage({
    super.key,
    required this.companyName,
    required this.role,
    required this.package,
    this.companyId,
  });

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  late Map<String, dynamic> _companyData;
  bool _isLoading = true;

  Future<Map<String, String>> _resolveStudentIdentity() async {
    final prefs = await SharedPreferences.getInstance();

    String email = prefs.getString('studentEmail') ?? '';
    String name = prefs.getString('userName') ?? '';

    if (email.isEmpty) {
      final studentDataStr = prefs.getString('studentData');
      if (studentDataStr != null && studentDataStr.isNotEmpty) {
        final studentData = jsonDecode(studentDataStr) as Map<String, dynamic>;
        email = (studentData['email'] ?? '').toString();
        name = name.isNotEmpty ? name : (studentData['name'] ?? '').toString();
      }
    }

    if (email.isEmpty) {
      final userDataStr = prefs.getString('userData');
      if (userDataStr != null && userDataStr.isNotEmpty) {
        final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
        email = (userData['email'] ?? '').toString();
        name = name.isNotEmpty ? name : (userData['name'] ?? '').toString();
      }
    }

    return {
      'email': email.trim(),
      'name': name.trim().isEmpty ? 'Student' : name.trim(),
    };
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      final response = await ApiService.getCompanies();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final company = data.firstWhere(
          (c) => c['name'] == widget.companyName,
          orElse: () => null,
        );
        
        setState(() {
          _companyData = company ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border_rounded, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // --- Company Logo & Info ---
                Center(
                  child: Column(
                    children: [
                      Hero(
                        tag: widget.companyName,
                        child: Container(
                          height: 80, width: 80,
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(widget.companyName[0],
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: themeColor)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.role, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(widget.companyName, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      Text(widget.package, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Encouraging Message ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "All students are encouraged to apply! Don't worry about skill requirements.",
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade900, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text("Job Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  "As a ${widget.role} at ${widget.companyName}, you will be responsible for developing high-quality software solutions and contributing to the complete software development lifecycle.",
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6),
                ),
                
                const SizedBox(height: 30),
                const Text("Requirements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildRequirementItem("Minimum 7.5 CGPA required."),
                _buildRequirementItem("Strong understanding of Data Structures & Algorithms."),
                _buildRequirementItem("Knowledge of Flutter or Native Android/iOS."),
                
                const SizedBox(height: 120), 
              ],
            ),
          ),

          // --- Bottom Action Button ---
          _buildBottomButton(context, themeColor),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 18, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, Color themeColor) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white.withOpacity(0.9),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => _showApplicationSuccess(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text("Confirm Application", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _showApplicationSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Applied Successfully!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final identity = await _resolveStudentIdentity();
                    final studentEmail = identity['email'] ?? '';
                    final studentName = identity['name'] ?? 'Student';

                    if (studentEmail.isEmpty) {
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Unable to find logged-in student email. Please login again.')),
                        );
                      }
                      return;
                    }

                    // Submit application to backend
                    final response = await ApiService.submitApplication(
                      studentEmail: studentEmail,
                      studentName: studentName,
                      companyName: widget.companyName,
                      role: widget.role,
                    );

                    if (response.statusCode == 201) {
                      if (mounted) {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to placement page
                      }
                    }
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Done", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}