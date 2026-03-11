import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // 👈 ye required for inputFormatters
import '../api/addStuAPI.dart';

class Addstu extends StatefulWidget {
  const Addstu({super.key});

  @override
  State<Addstu> createState() => _Addstu();
}

class _Addstu extends State<Addstu> {
  final TextEditingController rollController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController admissionController = TextEditingController();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentPhoneController = TextEditingController();
  final TextEditingController studentPhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedBranch;
  String? selectedGender;
  DateTime? dob;

  File? studentImage;
  final ImagePicker picker = ImagePicker();

  final List<String> branches = ["cse", "Mechanical", "Civil", "Electrical"];
  final List<String> genders = ["Male", "Female", "Other"];

  final StudentApi apiService = StudentApi(
    baseUrl: "http://192.168.43.46:8000/api",
  );

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => dob = picked);
  }

  Future<void> pickFromCamera() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) setState(() => studentImage = File(photo.path));
  }

  Future<void> pickFromGallery() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) setState(() => studentImage = File(photo.path));
  }

  // 🔹 Updated inputField to accept keyboardType & inputFormatters
  Widget inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 140,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitStudent() async {
    if (rollController.text.isEmpty ||
        nameController.text.isEmpty ||
        selectedBranch == null ||
        selectedGender == null ||
        dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    Map<String, dynamic> studentData = {
      "roll": rollController.text,
      "name": nameController.text,
      "branch": selectedBranch,
      "semester": semesterController.text,
      "admission_year": admissionController.text,
      "parent_name": parentNameController.text,
      "parent_phone": parentPhoneController.text,
      "student_phone": studentPhoneController.text,
      "email": emailController.text,
      "gender": selectedGender,
      "dob":
          "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
      "address": addressController.text,
      if (studentImage != null)
        "image":
            "data:image/${studentImage!.path.split('.').last};base64,${base64Encode(studentImage!.readAsBytesSync())}",
    };

    bool success = await apiService.addStudent(studentData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student Saved Successfully")),
      );
      rollController.clear();
      nameController.clear();
      semesterController.clear();
      admissionController.clear();
      parentNameController.clear();
      parentPhoneController.clear();
      studentPhoneController.clear();
      emailController.clear();
      addressController.clear();
      setState(() {
        selectedBranch = null;
        selectedGender = null;
        dob = null;
        studentImage = null;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save student")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff11998e), Color(0xff38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Add Student",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Roll Number (number only)
                      inputField(
                        "Roll Number",
                        rollController,
                        Icons.badge,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      inputField("Full Name", nameController, Icons.person),

                      DropdownButtonFormField<String>(
                        value: selectedBranch,
                        decoration: InputDecoration(
                          labelText: "Branch",
                          prefixIcon: const Icon(Icons.account_tree),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: branches
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedBranch = val),
                      ),

                      const SizedBox(height: 14),

                      // 🔹 Semester (number only)
                      inputField(
                        "Semester",
                        semesterController,
                        Icons.school,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      inputField(
                        "Admission Year",
                        admissionController,
                        Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      inputField(
                        "Parent Name",
                        parentNameController,
                        Icons.person_outline,
                      ),

                      inputField(
                        "Parent Phone",
                        parentPhoneController,
                        Icons.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      inputField(
                        "Student Phone",
                        studentPhoneController,
                        Icons.phone_android,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      inputField("Email", emailController, Icons.email),

                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: "Gender",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: genders
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedGender = val),
                      ),

                      const SizedBox(height: 14),

                      InkWell(
                        onTap: pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 10),
                              Text(
                                dob == null
                                    ? "Select Date of Birth"
                                    : "${dob!.day}-${dob!.month}-${dob!.year}",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      inputField("Address", addressController, Icons.home),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: showImageOptions,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: studentImage != null
                              ? FileImage(studentImage!)
                              : null,
                          child: studentImage == null
                              ? const Icon(Icons.camera_alt, size: 40)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: submitStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
