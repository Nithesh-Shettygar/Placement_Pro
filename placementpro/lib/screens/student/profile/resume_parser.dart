import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:placementpro/services/api_service.dart';
import 'package:placementpro/services/resume_storage_service.dart';
import 'package:placementpro/screens/student/profile/job_matching_results.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResumeParserPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ResumeParserPage({super.key, required this.userData});

  @override
  State<ResumeParserPage> createState() => _ResumeParserPageState();
}

class _ResumeParserPageState extends State<ResumeParserPage> {
  File? _selectedFile;
  PlatformFile? _selectedPlatformFile;
  String? _fileName;
  bool _isUploading = false;
  bool _uploadSuccess = false;

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // For web, we need to read bytes
      );

      if (result != null) {
        setState(() {
          _selectedPlatformFile = result.files.single;
          _fileName = result.files.single.name;
          _uploadSuccess = false;
          
          // Only create File object for non-web platforms
          if (!kIsWeb && result.files.single.path != null) {
            _selectedFile = File(result.files.single.path!);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadResume() async {
    if (_selectedFile == null && _selectedPlatformFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resume first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String email = widget.userData['email'] ?? '';
      
      // For web platform, we need to handle differently
      if (kIsWeb && _selectedPlatformFile != null && _selectedPlatformFile!.bytes != null) {
        // Create temporary file from bytes for web
        final response = await ApiService.uploadResumeBytes(
          email, 
          _selectedPlatformFile!.bytes!, 
          _selectedPlatformFile!.name
        );
        
        if (!mounted) return;

        if (response.statusCode == 200) {
          _handleUploadSuccess(response.body);
        } else {
          _handleUploadError(response.body);
        }
      } else if (_selectedFile != null) {
        // For mobile/desktop platforms
        final response = await ApiService.uploadResume(email, _selectedFile!);

        if (!mounted) return;

        if (response.statusCode == 200) {
          _handleUploadSuccess(response.body);
        } else {
          _handleUploadError(response.body);
        }
      } else {
        throw Exception('No file selected or file data unavailable');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleUploadSuccess(String responseBody) async {
    setState(() {
      _uploadSuccess = true;
      _isUploading = false;
    });
    
    try {
      final responseData = jsonDecode(responseBody);
      
      // Check if parsing was successful
      if (responseData['parsed_data'] != null && responseData['success'] == true) {
      final parsedData = responseData['parsed_data'];
      final jobRecommendations = responseData['job_recommendations'] ?? [];
      final atsScore = responseData['ats_score'] ?? {};
        
        // Extract resume data
        final resumeInfo = parsedData;

        // Persist ATS score and brief resume info to local storage for dashboard
        try {
          int parsedAts = 0;
          if (atsScore is int) {
            parsedAts = atsScore;
          } else if (atsScore is Map && atsScore['score'] != null) {
            parsedAts = (atsScore['score'] is int)
                ? atsScore['score']
                : int.tryParse(atsScore['score'].toString()) ?? 0;
          }

          final Map<String, String> storageMap = {
            'name': resumeInfo['name'] ?? widget.userData['name'] ?? '',
            'email': resumeInfo['email'] ?? widget.userData['email'] ?? '',
            'skills': (resumeInfo['skills'] as List?)?.join(', ') ?? '',
            'ats': parsedAts.toString(),
          };

          await ResumeStorageService.saveResumeData(storageMap);
        } catch (e) {
          // ignore storage errors but log in debug
        }
        
        // Navigate to job matching results page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => JobMatchingResultsPage(
              resumeData: {
                'fullName': resumeInfo['name'] ?? widget.userData['name'] ?? '',
                'email': resumeInfo['email'] ?? widget.userData['email'] ?? '',
                'phone': resumeInfo['phone']?.toString() ?? '',
                'linkedin': resumeInfo['linkedin'] ?? '',
                'summary': resumeInfo['summary'] ?? '',
                'skills': (resumeInfo['skills'] as List?)?.join(', ') ?? '',
                'experience': (resumeInfo['experience'] as List?)?.isNotEmpty == true
                    ? (resumeInfo['experience'] as List).map((e) => e.toString()).join('\n')
                    : '',
                'education': (resumeInfo['education'] as List?)?.isNotEmpty == true
                    ? (resumeInfo['education'] as List).map((e) => e.toString()).join('\n')
                    : '',
                'certifications': (resumeInfo['certifications'] as List?)?.join(', ') ?? '',
                'languages': (resumeInfo['languages'] as List?)?.join(', ') ?? '',
              },
              matchedJobs: jobRecommendations.map((job) {
                return {
                  'title': job['title'] ?? '',
                  'company': job['company'] ?? '',
                  'location': job['location'] ?? '',
                  'salary': job['salary'] ?? '',
                  'description': job['description'] ?? '',
                  'requiredSkills': job['skills'] ?? [],
                  'matchPercentage': job['match_score']?.round() ?? 0,
                  'experience': job['experience'] ?? '',
                  'type': job['type'] ?? 'Full-time',
                };
              }).toList(),
              atsScore: atsScore,
            ),
          ),
        );
      } else {
        // If no parsed data, show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['error'] ?? 'Failed to parse resume'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // If JSON parsing fails, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing resume: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleUploadError(String errorMessage) {
    setState(() {
      _isUploading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload failed: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Parser'),
        elevation: 0,
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor.withOpacity(0.1), Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_file_rounded, size: 48, color: themeColor),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Your Resume',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select a PDF file to upload and parse',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // File Selection Area
            InkWell(
              onTap: _isUploading ? null : _pickResume,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedPlatformFile != null ? themeColor : Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedPlatformFile != null
                          ? Icons.check_circle_rounded
                          : Icons.cloud_upload_outlined,
                      size: 64,
                      color: _selectedPlatformFile != null ? Colors.green : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedPlatformFile != null
                          ? 'File Selected'
                          : 'Click to Select Resume',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedPlatformFile != null ? Colors.green : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fileName ?? 'Only PDF files are supported',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Cards
            _buildInfoCard(
              icon: Icons.description_outlined,
              title: 'Supported Format',
              description: 'PDF files only (.pdf)',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.analytics_outlined,
              title: 'Auto Analysis',
              description: 'Resume will be automatically parsed and analyzed',
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.security_outlined,
              title: 'Secure Upload',
              description: 'Your data is encrypted and stored securely',
              color: Colors.orange,
            ),
            const SizedBox(height: 32),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Uploading...', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_rounded),
                          const SizedBox(width: 8),
                          Text(
                            _uploadSuccess ? 'Upload Success!' : 'Upload & Parse Resume',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _isUploading
                    ? null
                    : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
