import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchSubjectApi {
  final String baseUrl = "http://192.168.43.46:8000/";

  /// Fetch subjects for branch + semester
  /// Returns List<Map<String,dynamic>> with subject_id and name
  Future<List<Map<String, dynamic>>> fetchSubjects({
    required String branch,
    required int semester,
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/students/get-subjects/?branch=$branch&semester=$semester",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map(
              (e) => {
                "subject_id": e["subject_id"], // backend expects this
                "name": e["sub_name"], // display name in dropdown
              },
            )
            .toList();
      } else {
        throw Exception("Failed to load subjects");
      }
    } catch (e) {
      print("Subject fetch error: $e");
      return [];
    }
  }
}
