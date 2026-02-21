import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ResumeStorageService {
  static const String _resumeDataKey = 'resume_data';
  static const String _resumePdfKey = 'resume_pdf_bytes';

  // Save resume data
  static Future<bool> saveResumeData(Map<String, String> resumeData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(resumeData);
      return await prefs.setString(_resumeDataKey, jsonString);
    } catch (e) {
      print('Error saving resume data: $e');
      return false;
    }
  }

  // Get resume data
  static Future<Map<String, String>?> getResumeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_resumeDataKey);
      
      if (jsonString != null) {
        return Map<String, String>.from(jsonDecode(jsonString));
      }
      return null;
    } catch (e) {
      print('Error getting resume data: $e');
      return null;
    }
  }

  // Check if resume exists
  static Future<bool> hasResume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_resumeDataKey);
    } catch (e) {
      print('Error checking resume: $e');
      return false;
    }
  }

  // Clear resume data
  static Future<bool> clearResumeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_resumeDataKey);
    } catch (e) {
      print('Error clearing resume data: $e');
      return false;
    }
  }

  // Save resume PDF bytes
  static Future<bool> savePdfBytes(List<int> pdfBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = base64Encode(pdfBytes);
      return await prefs.setString(_resumePdfKey, base64String);
    } catch (e) {
      print('Error saving PDF bytes: $e');
      return false;
    }
  }

  // Get resume PDF bytes
  static Future<List<int>?> getPdfBytes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_resumePdfKey);
      if (base64String != null) {
        return base64Decode(base64String);
      }
      return null;
    } catch (e) {
      print('Error getting PDF bytes: $e');
      return null;
    }
  }
}
