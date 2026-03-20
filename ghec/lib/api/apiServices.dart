import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// 🔹 CHANGE THIS BASE URL AS PER DEVICE
  /// Emulator → http://10.0.2.2:8000
  /// Real Phone → http://192.168.x.x:8000
  static const String baseUrl = "http://192.168.43.46:8000";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  // ================= 🔐 LOGIN =================
  static Future<Map<String, dynamic>> login(
    String rollNo,
    String password,
    String usertype,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/login/");

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              "username": rollNo,
              "password": password,
              "usertype": usertype,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("LOGIN STATUS: ${response.statusCode}");
      debugPrint("LOGIN BODY: ${response.body}");

      return _handleResponse(response);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ================= 📝 CREATE REQUEST =================
  static Future<Map<String, dynamic>> createUpdateRequest(
    String rollNo,
    String fieldName,
    String newValue,
  ) async {
    final url = Uri.parse("$baseUrl/api/request/create/");

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({
              "roll_no": rollNo,
              "field_name": fieldName,
              "new_value": newValue,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("CREATE REQUEST STATUS: ${response.statusCode}");
      return _handleResponse(response);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ================= 📋 GET ALL REQUESTS =================
  static Future<List<dynamic>> getAllRequests() async {
    final url = Uri.parse("$baseUrl/api/request/all/");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      debugPrint("GET REQUESTS STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ================= ✅ APPROVE / ❌ REJECT =================
  static Future<Map<String, dynamic>> handleRequest(
    int requestId,
    String action, // "approve" or "reject"
  ) async {
    final url = Uri.parse("$baseUrl/api/request/$requestId/");
    print("${requestId} ko ${action} krna hai bawa");
    print(url);
    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode({"action": action}))
          .timeout(const Duration(seconds: 10));

      debugPrint("HANDLE REQUEST STATUS: ${response.statusCode}");
      return _handleResponse(response);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }

  // ================= 🔧 COMMON RESPONSE HANDLER =================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          "error": true,
          "status": response.statusCode,
          "message": data.toString(),
        };
      }
    } catch (e) {
      return {
        "error": true,
        "status": response.statusCode,
        "message": "Invalid JSON response",
      };
    }
  }
}
