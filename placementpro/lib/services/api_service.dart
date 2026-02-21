import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ApiService {
  static const String _fixedBaseUrl = 'http://172.18.159.176:5000';
  static String get baseUrl => _fixedBaseUrl;

  static List<String> _chatbotBaseUrls() {
    return const [
      _fixedBaseUrl,
    ];
  }

  static Future<http.Response> register(Map<String, dynamic> data) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception("Connection failed: $e");
    }
  }

  static Future<http.Response> registerStudentWithPhoto(
      Map<String, String> data, File? photoFile) async {
    try {
      var uri = Uri.parse('$baseUrl/register');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields.addAll(data);

      // Add image file if exists
      if (photoFile != null && await photoFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            photoFile.path,
            filename: photoFile.path.split('/').last,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  static Future<http.Response> login(String email, String password) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim(), "password": password}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Login service unavailable: $e");
    }
  }

  static Future<http.Response> resetPassword(
      String email, String name, String newPassword) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "name": name.trim(),
          "newPassword": newPassword,
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Reset service unavailable: $e");
    }
  }

  static Future<http.Response> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      throw Exception("Health check failed: $e");
    }
  }

  static Future<http.Response> getStats() async {
    try {
      return await http.get(
        Uri.parse('$baseUrl/stats'),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Stats request failed: $e");
    }
  }

  static Future<bool> healthCheckSimple() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<http.Response> uploadResume(String email, File resumeFile) async {
    try {
      var uri = Uri.parse('$baseUrl/upload-resume');
      var request = http.MultipartRequest('POST', uri);

      // Add email field
      request.fields['email'] = email;

      // Add resume file
      if (await resumeFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'resume',
            resumeFile.path,
            filename: resumeFile.path.split('/').last,
          ),
        );
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception("Resume upload failed: $e");
    }
  }

  static Future<http.Response> uploadResumeBytes(String email, Uint8List fileBytes, String fileName) async {
    try {
      var uri = Uri.parse('$baseUrl/upload-resume');
      var request = http.MultipartRequest('POST', uri);

      // Add email field
      request.fields['email'] = email;

      // Add resume file from bytes (for web platform)
      request.files.add(
        http.MultipartFile.fromBytes(
          'resume',
          fileBytes,
          filename: fileName,
        ),
      );

      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception("Resume upload failed: $e");
    }
  }

  static Future<http.Response> getCompanies({bool alumniOnly = false}) async {
    try {
      final queryParams = alumniOnly ? '?alumni_only=true' : '';
      return await http.get(
        Uri.parse('$baseUrl/companies$queryParams'),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to fetch companies: $e");
    }
  }

  static Future<http.Response> addCompany(String name, String category, {bool postedByAlumni = false}) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/companies'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "category": category, "posted_by_alumni": postedByAlumni}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to add company: $e");
    }
  }

  static Future<http.Response> deleteCompany(int companyId) async {
    try {
      return await http.delete(
        Uri.parse('$baseUrl/companies/$companyId'),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to delete company: $e");
    }
  }

  // --- APPLICATION ENDPOINTS ---

  static Future<http.Response> submitApplication({
    required String studentEmail,
    required String studentName,
    required String companyName,
    required String role,
  }) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/applications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_email': studentEmail,
          'student_name': studentName,
          'company_name': companyName,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to submit application: $e");
    }
  }

  static Future<http.Response> getApplications() async {
    try {
      return await http.get(
        Uri.parse('$baseUrl/applications'),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to fetch applications: $e");
    }
  }

  static Future<http.Response> getStudentApplications({
    String? studentEmail,
    String? studentName,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (studentEmail != null && studentEmail.trim().isNotEmpty) {
        queryParams['student_email'] = studentEmail.trim();
      }
      if (studentName != null && studentName.trim().isNotEmpty) {
        queryParams['student_name'] = studentName.trim();
      }

      final uri = Uri.parse('$baseUrl/applications').replace(queryParameters: queryParams);
      return await http.get(uri).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to fetch student applications: $e");
    }
  }

  static Future<http.Response> updateApplicationStatus(int appId, String status) async {
    try {
      return await http.patch(
        Uri.parse('$baseUrl/applications/$appId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception("Failed to update application: $e");
    }
  }
  // --- CHATBOT ENDPOINTS ---
  
  static Future<http.Response> sendChatMessage(String message, String sessionId) async {
    Exception? lastError;

    for (final host in _chatbotBaseUrls()) {
      try {
        return await http.post(
          Uri.parse('$host/chatbot/message'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "message": message,
            "session_id": sessionId,
          }),
        ).timeout(const Duration(seconds: 30));
      } catch (e) {
        lastError = Exception("$host => $e");
      }
    }

    throw Exception("Failed to send chat message: $lastError");
  }

  static Future<http.Response> clearChatSession(String sessionId) async {
    Exception? lastError;

    for (final host in _chatbotBaseUrls()) {
      try {
        return await http.post(
          Uri.parse('$host/chatbot/clear'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"session_id": sessionId}),
        ).timeout(const Duration(seconds: 10));
      } catch (e) {
        lastError = Exception("$host => $e");
      }
    }
    throw Exception("Failed to clear chat session: $lastError");
  }
}

