import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:placementpro/services/resume_storage_service.dart';
import 'package:placementpro/screens/student/profile/view_resume.dart';

class UpdateResumePage extends StatefulWidget {
  const UpdateResumePage({super.key});

  @override
  State<UpdateResumePage> createState() => _UpdateResumePageState();
}

class _UpdateResumePageState extends State<UpdateResumePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form field controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _languagesController = TextEditingController();

  Map<String, String> resumeData = {};
  bool isGenerating = false;
  pw.Document? generatedPdf;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _certificationsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<pw.Document> _createPdfDocument() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                resumeData['fullName']!,
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${resumeData['email']} | ${resumeData['phone']} | ${resumeData['linkedin']}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 12),

              // Professional Summary
              pw.Text(
                'PROFESSIONAL SUMMARY',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(resumeData['summary']!, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),

              // Skills
              pw.Text(
                'SKILLS',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(resumeData['skills']!, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),

              // Experience
              pw.Text(
                'PROFESSIONAL EXPERIENCE',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(resumeData['experience']!, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),

              // Education
              pw.Text(
                'EDUCATION',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(resumeData['education']!, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),

              // Certifications
              pw.Text(
                'CERTIFICATIONS & TRAINING',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(resumeData['certifications']!, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),

              // Languages
              pw.Text(
                'LANGUAGES',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(resumeData['languages']!, style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _generateAndDownloadResume() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isGenerating = true;
      });

      // Store form data
      resumeData = {
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'linkedin': _linkedinController.text,
        'summary': _summaryController.text,
        'skills': _skillsController.text,
        'experience': _experienceController.text,
        'education': _educationController.text,
        'certifications': _certificationsController.text,
        'languages': _languagesController.text,
      };

      try {
        // Create PDF document
        generatedPdf = await _createPdfDocument();

        // Save resume data to local storage
        await ResumeStorageService.saveResumeData(resumeData);

        // Save and print (download)
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => generatedPdf!.save(),
        );

        if (mounted) {
          setState(() {
            isGenerating = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Resume generated and saved successfully!"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to ViewResumePage after success
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewResumePage(
                    initialResumeData: resumeData,
                  ),
                ),
              );
            }
          });
        }
      } catch (e) {
        setState(() {
          isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error generating resume: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadResumeFromView() async {
    if (generatedPdf == null) return;

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => generatedPdf!.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Resume downloaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error downloading resume: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showViewResume() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Your Resume"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResumeSection("Full Name", resumeData['fullName'] ?? ''),
              _buildResumeSection("Contact", '${resumeData['email']} | ${resumeData['phone']}'),
              _buildResumeSection("LinkedIn", resumeData['linkedin'] ?? ''),
              _buildResumeSection("Professional Summary", resumeData['summary'] ?? ''),
              _buildResumeSection("Skills", resumeData['skills'] ?? ''),
              _buildResumeSection("Experience", resumeData['experience'] ?? ''),
              _buildResumeSection("Education", resumeData['education'] ?? ''),
              _buildResumeSection("Certifications", resumeData['certifications'] ?? ''),
              _buildResumeSection("Languages", resumeData['languages'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Download Resume"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _downloadResumeFromView();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 11)),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Build Resume"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Your Professional Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Fill in the information below to auto-generate your resume.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 25),

              // Basic Information Section
              _sectionHeader("Basic Information"),
              _buildField("Full Name", Icons.person_outline, _fullNameController),
              _buildField("Contact Number", Icons.phone_android_outlined, _phoneController, keyboardType: TextInputType.phone),
              _buildField("Email Address", Icons.alternate_email_outlined, _emailController, keyboardType: TextInputType.emailAddress),
              _buildField("LinkedIn Profile URL", Icons.link_rounded, _linkedinController),

              const SizedBox(height: 15),
              _sectionHeader("Professional Profile"),
              _buildField("Professional Summary", Icons.description_outlined, _summaryController, maxLines: 3),
              _buildField("Skills (e.g. Flutter, Java, SQL)", Icons.psychology_outlined, _skillsController),
              _buildField("Professional Experience", Icons.work_outline_rounded, _experienceController, maxLines: 3, hint: "Enter role, company, and duration"),

              const SizedBox(height: 15),
              _sectionHeader("Academic & Others"),
              _buildField("Education", Icons.school_outlined, _educationController, hint: "Degree, University, CGPA"),
              _buildField("Certifications & Training", Icons.card_membership_outlined, _certificationsController),
              _buildField("Languages Known", Icons.language_rounded, _languagesController),

              const SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: isGenerating ? null : _generateAndDownloadResume,
                  child: isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Generate & Submit Resume",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true,
          prefixIcon: Icon(icon, size: 22, color: Colors.teal.shade400),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}