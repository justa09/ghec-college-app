import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchStudentApi {
  final String baseUrl = "http://192.168.43.46:8000/"; // backend URL

  // Function to fetch students for multiple branches & semesters
  Future<List<Map<String, String>>> fetchStudents({
    required List<String> branches,
    required List<int> semesters,
  }) async {
    try {
      // Convert lists to comma-separated strings for query params
      final branchParam = branches.join(',');
      final semesterParam = semesters.join(',');

      final uri = Uri.parse(
        "$baseUrl/api/fetch_students/?branches=$branchParam&semesters=$semesterParam",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Map backend response to List<Map<String, String>>
        return data
            .map(
              (e) => {
                "roll_num": e["roll_num"]?.toString() ?? "",
                "full_name": e["full_name"]?.toString() ?? "",
              },
            )
            .toList();
      } else {
        print(
          "Failed to fetch students: ${response.statusCode}, body: ${response.body}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching students: $e");
      return [];
    }
  }
}
