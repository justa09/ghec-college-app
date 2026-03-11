import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentApi {
  final String baseUrl;

  StudentApi({required this.baseUrl});

  /// Add Student function
  Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      final url = Uri.parse('$baseUrl/add');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ghec_secret_123', // 🔐 security token
            },
            body: jsonEncode(studentData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in addStudent: $e');
      return false;
    }
  }

  /// Get all students
  Future<List<Map<String, dynamic>>> getStudents({
    String? branches,
    String? semesters,
  }) async {
    try {
      String urlStr = '$baseUrl/fetch_students';

      if (branches != null || semesters != null) {
        urlStr += '?';
        if (branches != null) urlStr += 'branches=$branches&';
        if (semesters != null) urlStr += 'semesters=$semesters';
      }

      final url = Uri.parse(urlStr);

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer ghec_secret_123', // 🔐 security token
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception in getStudents: $e');
      return [];
    }
  }
}
