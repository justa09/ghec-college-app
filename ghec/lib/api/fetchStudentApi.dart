import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FetchStudentApi {
  final String baseUrl = "http://192.168.43.148:8000/"; // backend URL

  // Function to fetch students for multiple branches & semesters
  Future<Map<String, dynamic>> fetchStudents({
  required List<String> branches,
  required List<String> semesters,
}) async {
  try {
    final branchParam = branches.join(',');
    final semesterParam = semesters.join(',');

    final uri = Uri.parse(
      "$baseUrl/api/fetch_students/?branches=$branchParam&semesters=$semesterParam",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final students = data
          .map<Map<String, String>>(
            (e) => {
              "roll_num": e["roll_num"]?.toString() ?? "",
              "full_name": e["full_name"]?.toString() ?? "",
            },
          )
          .toList();

      return {
        "total": students.length,
        "students": students,
      };
    } else {
      return {
        "total": 0,
        "students": <Map<String, String>>[],
      };
    }
  } catch (e) {
    return {
      "total": 0,
      "students": <Map<String, String>>[],
    };
  }
}
  Future<bool> deleteStudent(String rollNum) async {
    debugPrint("Attempting to delete student with roll number: $rollNum");
    try {
      final uri = Uri.parse("$baseUrl/api/delete_student/?roll_num=$rollNum");
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          "Failed to delete student: ${response.statusCode}, body: ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Error deleting student: $e");
      return false;
    }
  }
}
