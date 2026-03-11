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

  /// Existing method (unchanged)
  Future<List<dynamic>?> showAttendance(List<String> rollNumbers) async {
    final url = Uri.parse("$baseUrl/attendance/show/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(rollNumbers),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data);
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'present': data['present'] ?? 0, 'absent': data['absent'] ?? 0};
      } else {
        print("Failed to fetch subject attendance: ${response.statusCode}");
        return {'present': 0, 'absent': 0};
      }
    } catch (e) {
      print("Error fetching subject attendance: $e");
      return {'present': 0, 'absent': 0};
    }
  }

  /// 🔹 Future-ready: fetch attendance for multiple students
  Future<Map<String, Map<String, int>>> getAttendanceForMultipleStudents(
    List<String> rollNos, {
    String? subject,
  }) async {
    final result = <String, Map<String, int>>{};
    for (var roll in rollNos) {
      if (subject == null || subject == "All") {
        // Fetch combined attendance
        final data = await showAttendance([roll]);
        if (data != null && data.isNotEmpty) {
          result[roll] = {
            'present': data[0]['present'] ?? 0,
            'absent': data[0]['absent'] ?? 0,
          };
        } else {
          result[roll] = {'present': 0, 'absent': 0};
        }
      } else {
        // Fetch subject-wise attendance
        final data = await getAttendanceForSubject(roll, subject);
        result[roll] = data;
      }
    }
    return result;
  }
}
