import 'package:flutter/material.dart';
import 'package:ghec/api/apiservices.dart';

class UpdateProfileRequestPage extends StatefulWidget {
  final String rollNo;

  const UpdateProfileRequestPage({super.key, required this.rollNo});

  @override
  State<UpdateProfileRequestPage> createState() =>
      _UpdateProfileRequestPageState();
}

class _UpdateProfileRequestPageState extends State<UpdateProfileRequestPage> {
  final TextEditingController valueController = TextEditingController();
  String selectedField = "parent_phone";
  bool isLoading = false;

  final List<Map<String, String>> fields = [
    {"label": "Student Name", "value": "full_name"},
    {"label": "Branch", "value": "branch"},
    {"label": "Parent Name", "value": "parent_name"},
    {"label": "Parent Phone", "value": "parent_phone"},
    {"label": "Student Phone", "value": "student_phone"},
    {"label": "Address", "value": "address"},
    {"label": "Email", "value": "email"},
    {"label": "Gender", "value": "gender"},
    {"label": "Image", "value": "image"},
  ];

  Future<void> submitRequest() async {
    if (valueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter value")));
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.createUpdateRequest(
      widget.rollNo,
      selectedField,
      valueController.text.trim(),
    );

    setState(() => isLoading = false);

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["error"])));
    } else {
      valueController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Column(
            children: [
              /// Header with back button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                  horizontal: size.width * 0.04,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff11998e), Color(0xff0f9b0f)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Update Profile Request",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.1),
                  ],
                ),
              ),

              /// Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Field",
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),

                      /// Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedField,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: fields.map((field) {
                          return DropdownMenuItem(
                            value: field["value"],
                            child: Text(
                              field["label"]!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedField = value);
                        },
                      ),
                      SizedBox(height: size.height * 0.03),

                      Text(
                        "Enter New Value",
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),

                      TextField(
                        controller: valueController,
                        decoration: InputDecoration(
                          hintText: "Enter new value",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),

                      /// Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.06,
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.greenAccent, Colors.green],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: isLoading ? null : submitRequest,
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        "Submit Request",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width * 0.045,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
