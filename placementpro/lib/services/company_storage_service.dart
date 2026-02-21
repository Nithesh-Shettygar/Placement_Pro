import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CompanyStorageService {
  static const String _companiesKey = 'companies_list';

  static Future<bool> saveCompanies(List<Map<String, String>> companies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(companies);
      return await prefs.setString(_companiesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, String>>> getCompanies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_companiesKey);
      if (jsonString == null) return [];
      final List parsed = jsonDecode(jsonString) as List;
      return parsed.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_companiesKey);
    } catch (e) {
      return false;
    }
  }
}
