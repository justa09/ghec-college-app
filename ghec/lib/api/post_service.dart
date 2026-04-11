import 'dart:convert';
import 'package:http/http.dart' as http;

class PostService {
  static const String baseUrl = "http://192.168.43.46:8000/api/posts/";

  static Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse("${baseUrl}get-posts/"));

    if (response.statusCode == 200) {
      print(response);
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load posts");
    }
  }
}
