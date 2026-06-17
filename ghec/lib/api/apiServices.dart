import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// Emulator → http://30.0.2.2:8000
  static const String baseUrl = "http://192.168.43.148:8000";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  // ================= 🔐 LOGIN =================
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/login/");

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint("LOGIN STATUS: ${response.statusCode}");
      debugPrint("LOGIN BODY: ${response.body}");

      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "error": true, "message": e.toString()};
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
          .timeout(const Duration(seconds: 30));

      debugPrint("CREATE REQUEST STATUS: ${response.statusCode}");
      debugPrint("CREATE REQUEST BODY: ${response.body}");

      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "error": true, "message": e.toString()};
    }
  }

  // ================= 📋 GET ALL REQUESTS =================
  static Future<List<dynamic>> getAllRequests() async {
    final url = Uri.parse("$baseUrl/api/request/all/");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      debugPrint("GET REQUESTS STATUS: ${response.statusCode}");
      debugPrint("GET REQUESTS BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ================= ✅ APPROVE / ❌ REJECT =================
  static Future<Map<String, dynamic>> handleRequest(
    int requestId,
    String action,
  ) async {
    final url = Uri.parse("$baseUrl/api/request/$requestId/");

    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode({"action": action}))
          .timeout(const Duration(seconds: 30));

      debugPrint("HANDLE REQUEST STATUS: ${response.statusCode}");
      debugPrint("HANDLE REQUEST BODY: ${response.body}");

      return _handleResponse(response);
    } catch (e) {
      return {"status": "error", "error": true, "message": e.toString()};
    }
  }

  // ================= 🔧 COMMON RESPONSE HANDLER =================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {"status": "success", "data": data};
      }

      return {
        "status": "error",
        "error": true,
        "code": response.statusCode,
        "message": data is Map
            ? (data["message"] ?? data["detail"] ?? data.toString())
            : data.toString(),
      };
    } catch (e) {
      return {
        "status": "error",
        "error": true,
        "code": response.statusCode,
        "message": "Invalid server response",
      };
    }
  }
}
