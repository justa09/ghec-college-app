import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../api/addStuAPI.dart';

class Addstu extends StatefulWidget {
  const Addstu({super.key});

  @override
  State<Addstu> createState() => _Addstu();
}

class _Addstu extends State<Addstu> {
  final TextEditingController rollController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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

  bool obscurePassword = true;
  bool isLoading = false;

  final List<String> branches = ["cse", "Mechanical", "Civil", "Electrical"];
  final List<String> genders = ["Male", "Female", "Other"];

  final StudentApi apiService = StudentApi(
    baseUrl: "http://192.168.43.148:8000/api",
  );

  @override
  void dispose() {
    rollController.dispose();
    passwordController.dispose();
    nameController.dispose();
    semesterController.dispose();
    admissionController.dispose();
    parentNameController.dispose();
    parentPhoneController.dispose();
    studentPhoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
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
      setState(() => dob = picked);
    }
  }

  Future<void> pickFromCamera() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => studentImage = File(photo.path));
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() => studentImage = File(photo.path));
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                  leading: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.green.shade700,
                    ),
                  ),
                  title: const Text(
                    "Camera",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_rounded,
                      color: Colors.green.shade700,
                    ),
                  ),
                  title: const Text(
                    "Gallery",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickFromGallery();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitStudent() async {
    if (isLoading) return;

    if (rollController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty ||
        selectedBranch == null ||
        semesterController.text.isEmpty ||
        parentNameController.text.isEmpty ||
        parentPhoneController.text.isEmpty ||
        selectedGender == null ||
        dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill all required fields"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> studentData = {
      "username": rollController.text,
      "password": passwordController.text,
      "role": "student",
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

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Student Saved Successfully"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff059669),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      rollController.clear();
      passwordController.clear();
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
        obscurePassword = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save student"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    bool isRequired = false,
  }) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ]
              : [],
        ),
      ),
      prefixIcon: Icon(icon, color: Colors.green.shade700),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xfff7fbf8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.green.shade600, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    bool isRequired = false,
  }) {
    return TextField(
      enabled: !isLoading,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: inputDecoration(
        label: label,
        icon: icon,
        suffixIcon: suffixIcon,
        isRequired: isRequired,
      ),
    );
  }

  Widget fieldBox({
    required double width,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget dateField(double width) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : pickDate,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xfff7fbf8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: dob == null
                        ? "Select Date of Birth"
                        : "${dob!.day}-${dob!.month}-${dob!.year}",
                    style: TextStyle(
                      color: dob == null
                          ? Colors.grey.shade700
                          : const Color(0xff111827),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    children: dob == null
                        ? const [
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imagePickerBox() {
    return GestureDetector(
      onTap: isLoading ? null : showImageOptions,
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
          radius: 58,
          backgroundColor: Colors.white,
          backgroundImage: studentImage != null ? FileImage(studentImage!) : null,
          child: studentImage == null
              ? Icon(
                  Icons.camera_alt_rounded,
                  size: 38,
                  color: Colors.green.shade700,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isTablet = width >= 760;
          final double maxContentWidth = isTablet ? 900 : 620;
          final double horizontalPadding = width < 420 ? 16 : 22;
          final double cardPadding = width < 420 ? 18 : 24;
          final double fieldWidth = isTablet
              ? (maxContentWidth - (horizontalPadding * 2) - 14) / 2
              : double.infinity;

          return Stack(
            children: [
              Container(
                height: 220,
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
                          vertical: 18,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => Navigator.pop(context),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(.18),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Add Student",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                  imagePickerBox(),
                                  const SizedBox(height: 24),
                                  Wrap(
                                    spacing: 14,
                                    runSpacing: 14,
                                    children: [
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Roll Number",
                                          rollController,
                                          Icons.badge_outlined,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          isRequired: true,
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Password",
                                          passwordController,
                                          Icons.lock_outline_rounded,
                                          obscureText: obscurePassword,
                                          isRequired: true,
                                          suffixIcon: IconButton(
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    setState(() {
                                                      obscurePassword =
                                                          !obscurePassword;
                                                    });
                                                  },
                                            icon: Icon(
                                              obscurePassword
                                                  ? Icons
                                                      .visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Full Name",
                                          nameController,
                                          Icons.person_outline_rounded,
                                          isRequired: true,
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: DropdownButtonFormField<String>(
                                          initialValue: selectedBranch,
                                          decoration: inputDecoration(
                                            label: "Branch",
                                            icon: Icons.account_tree_rounded,
                                            isRequired: true,
                                          ),
                                          dropdownColor: Colors.white,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.green.shade700,
                                          ),
                                          items: branches
                                              .map(
                                                (b) => DropdownMenuItem(
                                                  value: b,
                                                  child: Text(b),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: isLoading
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    selectedBranch = val;
                                                  });
                                                },
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Semester",
                                          semesterController,
                                          Icons.school_outlined,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          isRequired: true,
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Admission Year",
                                          admissionController,
                                          Icons.calendar_month_rounded,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Parent Name",
                                          parentNameController,
                                          Icons.person_outline,
                                          isRequired: true,
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Parent Phone",
                                          parentPhoneController,
                                          Icons.phone_rounded,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          isRequired: true,
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Student Phone",
                                          studentPhoneController,
                                          Icons.phone_android_rounded,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: inputField(
                                          "Email",
                                          emailController,
                                          Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                      ),
                                      fieldBox(
                                        width: fieldWidth,
                                        child: DropdownButtonFormField<String>(
                                          initialValue: selectedGender,
                                          decoration: inputDecoration(
                                            label: "Gender",
                                            icon: Icons.person_rounded,
                                            isRequired: true,
                                          ),
                                          dropdownColor: Colors.white,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.green.shade700,
                                          ),
                                          items: genders
                                              .map(
                                                (g) => DropdownMenuItem(
                                                  value: g,
                                                  child: Text(g),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: isLoading
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    selectedGender = val;
                                                  });
                                                },
                                        ),
                                      ),
                                      dateField(fieldWidth),
                                      fieldBox(
                                        width: double.infinity,
                                        child: inputField(
                                          "Address",
                                          addressController,
                                          Icons.home_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed:
                                          isLoading ? null : submitStudent,
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor:
                                            const Color(0xff059669),
                                        disabledBackgroundColor:
                                            Colors.green.shade300,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              "Save",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: .3,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}