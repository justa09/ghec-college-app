import 'dart:io';
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
    File? imageFile,
  }) async {
    try {
      final URL = Uri.parse('$baseURL/addTeacher/');

      var request = http.MultipartRequest('POST', URL);

      // 🔐 Headers
      request.headers.addAll({'Authorization': 'Bearer ghec_secret_123'});

      // 📄 Form fields
      request.fields['teacher_id'] = teacherId;
      request.fields['password'] = password;
      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['department'] = department;
      request.fields['joining_date'] = joiningDate;

      // 🖼 Image upload
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      // 📡 Send request
      var response = await request.send();

      // Convert response
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Teacher Added Successfully");
        return true;
      } else {
        print("Error: ${response.statusCode}");
        print(responseData.body);
        return false;
      }
    } catch (e) {
      print("Exception in addTeacher: $e");
      return false;
    }
  }
}
