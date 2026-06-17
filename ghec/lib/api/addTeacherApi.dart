import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TeacherApi {
  final String baseURL;

  TeacherApi({required this.baseURL});

  Future<bool> addTeacher({
    required String teacherId,
    required String password,
    required String name,
    required String phone,
    required String address,
    required String department,
    required String joiningDate,
    required String role,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseURL/addTeacher/');

      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer ghec_secret_123',
      });

      request.fields['Tid'] = teacherId;
      request.fields['password'] = password;
      request.fields['FullName'] = name;
      request.fields['Tphone'] = phone;
      request.fields['address'] = address;
      request.fields['dept'] = department;
      request.fields['joiningDate'] = joiningDate;
      request.fields['role'] = role;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Teacher Added Successfully");
        return true;
      } else {
        debugPrint("Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception in addTeacher: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchTeachers() async {
    try {
      final url = Uri.parse('$baseURL/fetch_teachers/');

      final response = await http.get(url);

      debugPrint("Fetch Teachers Status: ${response.statusCode}");
      debugPrint("Fetch Teachers Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> data = decoded is List
            ? decoded
            : decoded["teachers"] ?? decoded["data"] ?? [];

        final teachers = data
            .map<Map<String, String>>(
              (e) => {
                "Tid": e["Tid"]?.toString() ?? e["tid"]?.toString() ?? "",
                "FullName": e["FullName"]?.toString() ??
                    e["full_name"]?.toString() ??
                    e["name"]?.toString() ??
                    "",
                "Tphone": e["Tphone"]?.toString() ??
                    e["phone"]?.toString() ??
                    "",
                "address": e["address"]?.toString() ?? "",
                "dept": e["dept"]?.toString() ??
                    e["department"]?.toString() ??
                    "",
                "joiningDate": e["joiningDate"]?.toString() ??
                    e["joining_date"]?.toString() ??
                    "",
                "role": e["role"]?.toString() ?? "",
                "image": e["image"]?.toString() ?? "",
              },
            )
            .toList();

        return {
          "total": teachers.length,
          "teachers": teachers,
        };
      } else {
        debugPrint(
          "Failed to fetch teachers: ${response.statusCode}, body: ${response.body}",
        );

        return {
          "total": 0,
          "teachers": <Map<String, String>>[],
        };
      }
    } catch (e) {
      debugPrint("Exception in fetchTeachers: $e");

      return {
        "total": 0,
        "teachers": <Map<String, String>>[],
      };
    }
  }

  Future<bool> deleteTeacher(String teacherId) async {
  try {
    final url = Uri.parse('$baseURL/delete_teacher/$teacherId/');

    final response = await http.delete(url);

    debugPrint("Delete Status Code: ${response.statusCode}");
    debugPrint("Delete Response Body: ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    debugPrint("Exception in deleteTeacher: $e");
    return false;
  }
}}