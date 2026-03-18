import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceApi {
  final String baseUrl = "http://192.168.43.46:8000/api";

  /// Submit bulk attendance
  /// payload = List of {roll_num, subject_id, status, lecture_no, date}
  Future<bool> submitAttendance(List<Map<String, dynamic>> payload) async {
    final uri = Uri.parse("$baseUrl/attendance/");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
          "Attendance submission failed: ${response.statusCode}, body: ${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("Error submitting attendance: $e");
      return false;
    }
  }
}

class ShowAttendanceApi {
  final String baseUrl = "http://192.168.43.46:8000/api";

  /// Existing method (FIXED + SAFE)
  Future<List<dynamic>?> showAttendance(List<String> rollNumbers) async {
    final url = Uri.parse("$baseUrl/attendance/show/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(rollNumbers),
      );

      print("STATUS: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // ✅ Handle multiple backend formats
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'];
        } else {
          print("Unexpected response format");
          return null;
        }
      } else {
        print(
          "Failed to fetch attendance: ${response.statusCode}, body: ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Error fetching attendance: $e");
      return null;
    }
  }

  /// 🔹 Future-ready method: fetch all subjects for a student
  Future<List<String>> getSubjectsForStudent(String rollNo) async {
    final url = Uri.parse("$baseUrl/attendance/subjects/$rollNo/");
    try {
      final response = await http.get(url);

      print("SUBJECT STATUS: ${response.statusCode}");
      print("SUBJECT RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return List<String>.from(data);
        } else if (data is Map && data.containsKey('subjects')) {
          return List<String>.from(data['subjects']);
        } else {
          return [];
        }
      } else {
        print("Failed to fetch subjects: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      return [];
    }
  }

  /// 🔹 Future-ready: fetch attendance for a specific subject
  Future<Map<String, int>> getAttendanceForSubject(
    String rollNo,
    String subject,
  ) async {
    final url = Uri.parse("$baseUrl/attendance/show/$rollNo/$subject/");
    try {
      final response = await http.get(url);

      print("SUBJECT ATT STATUS: ${response.statusCode}");
      print("SUBJECT ATT RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'present': int.tryParse(data['present'].toString()) ?? 0,
          'absent': int.tryParse(data['absent'].toString()) ?? 0,
        };
      } else {
        print("Failed to fetch subject attendance: ${response.statusCode}");
        return {'present': 0, 'absent': 0};
      }
    } catch (e) {
      print("Error fetching subject attendance: $e");
      return {'present': 0, 'absent': 0};
    }
  }

  /// 🔹 Future-ready: fetch attendance for multiple students (OPTIMIZED SAFE)
  Future<Map<String, Map<String, int>>> getAttendanceForMultipleStudents(
    List<String> rollNos, {
    String? subject,
  }) async {
    final result = <String, Map<String, int>>{};

    for (var roll in rollNos) {
      try {
        if (subject == null || subject == "All") {
          final data = await showAttendance([roll]);

          if (data != null && data.isNotEmpty) {
            final student = data.first;

            result[roll] = {
              'present':
                  int.tryParse(student['present']?.toString() ?? '0') ?? 0,
              'absent': int.tryParse(student['absent']?.toString() ?? '0') ?? 0,
            };
          } else {
            result[roll] = {'present': 0, 'absent': 0};
          }
        } else {
          final data = await getAttendanceForSubject(roll, subject);
          result[roll] = data;
        }
      } catch (e) {
        print("Error processing roll $roll: $e");
        result[roll] = {'present': 0, 'absent': 0};
      }
    }

    return result;
  }
}
