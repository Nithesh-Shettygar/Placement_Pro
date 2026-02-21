import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ResumeResultsPage extends StatefulWidget {
  final Map<String, String> resumeData;
  final pw.Document? pdfDocument;
  final Map<String, dynamic>? parsedData;

  const ResumeResultsPage({
    super.key,
    required this.resumeData,
    required this.pdfDocument,
    this.parsedData,
  });

  @override
  State<ResumeResultsPage> createState() => _ResumeResultsPageState();
}

class _ResumeResultsPageState extends State<ResumeResultsPage> {
  Future<void> _downloadResume() async {
    if (widget.pdfDocument == null) return;

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => widget.pdfDocument!.save(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Resume"),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // PDF Preview
          Expanded(
            child: widget.pdfDocument != null
                ? PdfPreview(
                    build: (format) => widget.pdfDocument!.save(),
                    pdfFileName: "${widget.resumeData['fullName']}_Resume.pdf",
                  )
                : Center(
                    child: Text(
                      "No resume generated",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
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
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Go Back"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download Resume"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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