import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

class CsrfApi {
  static String? token;

  static final http.Client client = BrowserClient()..withCredentials = true;

  static Future<void> fetchCsrfToken() async {
    final response = await client.get(
      Uri.parse('http://localhost:8000/api/auth/csrf/'),
    );

    print("response = ${response.statusCode}");
    print("Headers = ${response.headers}");

    final data = jsonDecode(response.body);

    token = data['csrfToken'];

    print("CSRF Token received = ${token != null}");
  }
}
