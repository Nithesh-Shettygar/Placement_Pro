import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:placementpro/services/resume_storage_service.dart';

class ViewResumePage extends StatefulWidget {
  final Map<String, dynamic>? initialResumeData;

  const ViewResumePage({
    super.key,
    this.initialResumeData,
  });

  @override
  State<ViewResumePage> createState() => _ViewResumePageState();
}

class _ViewResumePageState extends State<ViewResumePage> {
  Map<String, String>? resumeData;
  pw.Document? pdfDocument;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResume();
  }

  Future<void> _loadResume() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // First check if initial data is provided
      if (widget.initialResumeData != null) {
        resumeData = {};
        widget.initialResumeData!.forEach((key, value) {
          resumeData![key] = value?.toString() ?? '';
        });
      } else {
        // Otherwise load from storage
        resumeData = await ResumeStorageService.getResumeData();
      }

      if (resumeData != null && resumeData!.isNotEmpty) {
        // Generate PDF document
        pdfDocument = await _generatePdfDocument(resumeData!);
      } else {
        errorMessage = 'No resume found. Please create a resume first.';
      }
    } catch (e) {
      errorMessage = 'Error loading resume: $e';
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<pw.Document> _generatePdfDocument(Map<String, String> data) async {
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
                data['fullName'] ?? data['name'] ?? 'Your Name',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${data['email'] ?? ''} | ${data['phone'] ?? ''} | ${data['linkedin'] ?? ''}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 12),

              // Professional Summary
              if ((data['summary'] ?? '').isNotEmpty) ...[
                pw.Text(
                  'PROFESSIONAL SUMMARY',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data['summary']!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ],

              // Skills
              if ((data['skills'] ?? '').isNotEmpty) ...[
                pw.Text(
                  'SKILLS',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data['skills']!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ],

              // Experience
              if ((data['experience'] ?? '').isNotEmpty) ...[
                pw.Text(
                  'PROFESSIONAL EXPERIENCE',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data['experience']!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ],

              // Education
              if ((data['education'] ?? '').isNotEmpty) ...[
                pw.Text(
                  'EDUCATION',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data['education']!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ],

              // Certifications
              if ((data['certifications'] ?? '').isNotEmpty) ...[
                pw.Text(
                  'CERTIFICATIONS & TRAINING',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data['certifications']!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
              ],

              // Languages
              if ((data['languages'] ?? '').isNotEmpty) ...[
                pw.Text(
                  'LANGUAGES',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data['languages']!, style: const pw.TextStyle(fontSize: 10)),
              ],
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _downloadResume() async {
    if (pdfDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not ready for download'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfDocument!.save(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.teal.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Resume'),
        elevation: 0,
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          _loadResume();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // PDF Preview
                    Expanded(
                      child: pdfDocument != null
                          ? PdfPreview(
                              build: (format) => pdfDocument!.save(),
                              pdfFileName:
                                  "${resumeData?['fullName'] ?? resumeData?['name'] ?? 'resume'}_Resume.pdf",
                            )
                          : const Center(
                              child: Text('Unable to load resume'),
                            ),
                    ),

                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Go Back'),
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: themeColor,
                              side: BorderSide(color: themeColor),
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Download Resume'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _downloadResume,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
