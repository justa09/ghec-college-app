import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PostService {
  static const String baseUrl = "http://192.168.43.148:8000/api/posts/";

  static Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse("${baseUrl}get-posts/"));

    if (response.statusCode == 200) {
     
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load posts");
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String teacherId,
    required String description,
    required List<XFile> images,
  }) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${baseUrl}create-post/"),
    );
    request.fields["teacher_id"] = teacherId;
    request.fields["description"] = description;

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "images",
          File(image.path).path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}