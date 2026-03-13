import 'package:flutter/material.dart';
import 'package:ghec/screens/login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../api/addTeacherApi.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

final TeacherApi apiService = TeacherApi(
  baseURL: "http://192.168.43.46:8000/api",
);

class _RegisterPage extends State<RegisterPage> {
  final TextEditingController tIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController deptController = TextEditingController();

  DateTime? joiningDate;

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        joiningDate = picked;
      });
    }
  }

  Future pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 70);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void showImageOption() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitForm() async {
    if (tIdController.text.isEmpty ||
        nameController.text.isEmpty ||
        deptController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        joiningDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    String joining =
        "${joiningDate!.year}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}";

    bool success = await apiService.addTeacher(
      teacherId: tIdController.text,
      password: passwordController.text,
      name: nameController.text,
      phone: phoneController.text,
      address: addressController.text,
      department: deptController.text,
      joiningDate: joining,
      imageFile: imageFile,
    );

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Teacher Registered Successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to register teacher")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff11998e), Color(0xff38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              children: [
                SizedBox(height: screenHeight * .05),

                Container(
                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [
                      const Text(
                        "Register Here",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: showImageOption,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : null,
                          child: imageFile == null
                              ? const Icon(Icons.camera_alt, size: 40)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 30),

                      buildField(tIdController, "Teacher ID", Icons.badge),
                      buildField(
                        passwordController,
                        "Password",
                        Icons.lock,
                        obscure: true,
                      ),
                      buildField(nameController, "Name", Icons.person),
                      buildField(phoneController, "Phone", Icons.phone),
                      buildField(
                        addressController,
                        "Address",
                        Icons.location_on,
                      ),
                      buildField(
                        deptController,
                        "Department",
                        Icons.account_tree,
                      ),

                      const SizedBox(height: 20),

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
                                joiningDate == null
                                    ? "Joining Date"
                                    : "${joiningDate!.day}-${joiningDate!.month}-${joiningDate!.year}",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: screenWidth * .6,
                        height: 55,

                        child: ElevatedButton(
                          onPressed: submitForm,

                          child: const Text(
                            "Submit",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },

                        child: const Text("Login"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: TextFormField(
        controller: controller,
        obscureText: obscure,

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
