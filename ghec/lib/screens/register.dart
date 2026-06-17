import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ghec/screens/login.dart';
import 'package:image_picker/image_picker.dart';

import '../api/addTeacherApi.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

final TeacherApi apiService = TeacherApi(
  baseURL: "http://192.168.43.148:8000/api",
);

class _RegisterPage extends State<RegisterPage> {
  final TextEditingController tIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController deptController = TextEditingController();

  String? designation;

  DateTime? joiningDate;
  File? imageFile;

  final ImagePicker picker = ImagePicker();

  bool isLoading = false;

  final List<String> role = [
    "Principal",
    "HOD",
    "Lect",
    "Management",
  ];

  @override
  void dispose() {
    tIdController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    deptController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff059669),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xff111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        joiningDate = picked;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void showImageOption() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: const Text(
                      "Camera",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: const Text(
                      "Gallery",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
                  ),
                  if (imageFile != null)
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red.shade600,
                        ),
                      ),
                      title: const Text(
                        "Remove Image",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          imageFile = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    if (isLoading) return;

    if (tIdController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        deptController.text.trim().isEmpty ||
        designation == null ||
        joiningDate == null) {
      showMessage("Please fill all fields");
      return;
    }

    final String joining =
        "${joiningDate!.year}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}";

    setState(() {
      isLoading = true;
    });

    final bool success = await apiService.addTeacher(
      teacherId: tIdController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      department: deptController.text.trim(),
      joiningDate: joining,
      imageFile: imageFile,
      role : designation!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Success"),
          content: const Text("Teacher registered successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      showMessage("Failed to register teacher");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final bool isSmall = screenWidth < 380;
    final double horizontalPadding = screenWidth < 420 ? 16 : 22;
    final double maxContentWidth = screenWidth >= 760 ? 620 : double.infinity;
    final double cardPadding = screenWidth < 420 ? 20 : 25;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: Stack(
        children: [
          Container(
            height: screenHeight < 650 ? 220 : 260,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff047857),
                  Color(0xff10b981),
                  Color(0xff34d399),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: screenHeight * .05,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 35,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Register Here",
                            style: TextStyle(
                              fontSize: isSmall ? 28 : 32,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xff111827),
                            ),
                          ),
                          const SizedBox(height: 25),
                          GestureDetector(
                            onTap: showImageOption,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff047857),
                                    Color(0xff10b981),
                                    Color(0xff34d399),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(.18),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: isSmall ? 48 : 54,
                                backgroundColor: Colors.white,
                                backgroundImage: imageFile != null
                                    ? FileImage(imageFile!)
                                    : null,
                                child: imageFile == null
                                    ? Icon(
                                        Icons.camera_alt,
                                        size: isSmall ? 34 : 40,
                                        color: Colors.green.shade700,
                                      )
                                    : null,
                              ),
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

                          // 🔽 DESIGNATION DROPDOWN
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              initialValue: designation,
                              items: role
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  designation = value;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xfff7fbf8),
                                labelText: "Designation",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.green.shade600,
                                    width: 1.8,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.work,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 2),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: pickDate,
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xfff7fbf8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      joiningDate == null
                                          ? "Joining Date"
                                          : "${joiningDate!.day}-${joiningDate!.month}-${joiningDate!.year}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: joiningDate == null
                                            ? Colors.grey.shade700
                                            : const Color(0xff111827),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: screenWidth < 420
                                ? double.infinity
                                : screenWidth * .6,
                            height: isSmall ? 52 : 55,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff047857),
                                    Color(0xff10b981),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : submitForm,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Submit",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
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
        ],
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
        cursorColor: Colors.green.shade700,
        style: const TextStyle(
          color: Color(0xff111827),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xfff7fbf8),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.green.shade600,
              width: 1.8,
            ),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.green.shade700,
          ),
        ),
      ),
    );
  }
}