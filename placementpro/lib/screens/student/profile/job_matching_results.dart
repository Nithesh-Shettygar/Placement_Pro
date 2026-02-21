import 'package:flutter/material.dart';
import 'package:placementpro/services/company_storage_service.dart';

class JobMatchingResultsPage extends StatefulWidget {
  final Map<String, String> resumeData;
  final List<dynamic> matchedJobs;
  final Map<String, dynamic>? atsScore;

  const JobMatchingResultsPage({
    super.key,
    required this.resumeData,
    required this.matchedJobs,
    this.atsScore,
  });

  @override
  State<JobMatchingResultsPage> createState() => _JobMatchingResultsPageState();
}

class _JobMatchingResultsPageState extends State<JobMatchingResultsPage> {
  List<Map<String, String>> _storedCompanies = [];

  @override
  void initState() {
    super.initState();
    _loadStoredCompanies();
  }

  Future<void> _loadStoredCompanies() async {
    try {
      final companies = await CompanyStorageService.getCompanies();
      setState(() => _storedCompanies = companies);
    } catch (_) {}
  }
  Widget _buildATSScoreCard() {
    final score = widget.atsScore?['score'] ?? 0;
    final grade = widget.atsScore?['grade'] ?? 'Not Available';
    final keywordsScore = widget.atsScore?['keywords_score'] ?? 0;
    final formatScore = widget.atsScore?['format_score'] ?? 0;
    final experienceScore = widget.atsScore?['experience_score'] ?? 0;
    final educationScore = widget.atsScore?['education_score'] ?? 0;

    Color scoreColor;
    if (score >= 90) {
      scoreColor = Colors.green;
    } else if (score >= 75) {
      scoreColor = Colors.lightGreen;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        'ATS',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resume ATS Score',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      grade,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreItem('Keywords', keywordsScore),
              _buildScoreItem('Format', formatScore),
              _buildScoreItem('Experience', experienceScore),
              _buildScoreItem('Education', educationScore),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score) {
    return Column(
      children: [
        Text(
          '$score',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Merge matched jobs with stored companies (as lightweight job entries)
    final mergedJobs = <dynamic>[];
    mergedJobs.addAll(widget.matchedJobs);
    for (var c in _storedCompanies) {
      mergedJobs.add({
        'title': '${c['name']} - Opportunities',
        'company': c['name'],
        'location': 'Various',
        'salary': 'TBD',
        'description': c['sub'] ?? '',
        'requiredSkills': [],
        'matchPercentage': 50,
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Jobs'),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: mergedJobs.isEmpty
          ? _buildNoJobsFound()
          : Column(
              children: [
                if (widget.atsScore != null) _buildATSScoreCard(),
                _buildResumeSummary(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mergedJobs.length,
                    itemBuilder: (context, index) => _buildJobCard(mergedJobs[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildResumeSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(
                  widget.resumeData['fullName']?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.resumeData['fullName'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.resumeData['email'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '🎯 ${widget.matchedJobs.length} Jobs Available - Apply to Any!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All students can apply regardless of skill match',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final matchPercentage = job['matchPercentage'] ?? 0;
    final jobTitle = job['title'] ?? 'Job Title';
    final company = job['company'] ?? 'Company';
    final location = job['location'] ?? 'Location';
    final salary = job['salary'] ?? 'Not specified';
    final description = job['description'] ?? '';
    final requiredSkills = job['requiredSkills'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showJobDetails(job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with match percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      jobTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getMatchColor(matchPercentage),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${matchPercentage}% Match',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Company and location
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    company,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Salary
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    salary,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Skills
              if (requiredSkills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (requiredSkills as List)
                      .take(3)
                      .map(
                        (skill) => Chip(
                          label: Text(
                            skill.toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.teal.shade50,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoJobsFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Jobs Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No job postings are currently available. Check back later for new opportunities!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showJobDetails(dynamic job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  job['title'] ?? 'Job Title',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job['company'] ?? 'Company',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Required Skills',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (job['requiredSkills'] as List? ?? [])
                      .map(
                        (skill) => Chip(
                          label: Text(skill.toString()),
                          backgroundColor: Colors.teal.shade50,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Apply for job
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application submitted!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}