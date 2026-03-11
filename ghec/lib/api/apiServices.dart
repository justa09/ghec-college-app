import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.43.46:8000/api/auth"; // Android emulator ke liye
  // url for laptop
  // static const String baseUrl = "http://127.0.0.1:8000/api/auth";

  static Future<Map<String, dynamic>> login(
    String rollNo,
    String passw,
    String usertype,
  ) async {
    final url = Uri.parse("$baseUrl/login/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": rollNo,
        "password": passw,
        "usertype": usertype,
      }),
    );

    print("Status code: ${response.statusCode}");
    print("Body: ${response.body}");

    return jsonDecode(response.body);
  }
}
