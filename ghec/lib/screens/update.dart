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
  String? selectedField;
  bool isLoading = false;

  final List<Map<String, String>> fields = [
    {"label": "Select Field", "value": ""},
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
    if (selectedField == null || selectedField!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select field")));
      return;
    }

    if (valueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter value")));
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.createUpdateRequest(
      widget.rollNo,
      selectedField!,
      valueController.text.trim(),
    );

    setState(() => isLoading = false);

    if (response.containsKey("error")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["error"])));
    } else {
      valueController.clear();
      setState(() => selectedField = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final bool isSmall = width < 380;
    final double horizontalPadding = width < 420 ? 16 : 22;
    final double maxContentWidth = width >= 760 ? 620 : double.infinity;
    final double headerHeight = height < 650 ? 170 : 200;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: Stack(
        children: [
          Container(
            height: headerHeight,
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
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
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
                      vertical: isSmall ? 14 : 20,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(width, isSmall),
                        SizedBox(height: isSmall ? 26 : 34),
                        _buildRequestCard(width, isSmall),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildHeader(double width, bool isSmall) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              height: isSmall ? 44 : 48,
              width: isSmall ? 44 : 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: isSmall ? 10 : 14),
        Expanded(
          child: Text(
            "Update Profile Request",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 22 : 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(double width, bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 18 : 22),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Select Field", isSmall),
          SizedBox(height: isSmall ? 12 : 14),
          _buildDropdown(),
          SizedBox(height: isSmall ? 22 : 26),
          _buildLabel("Enter New Value", isSmall),
          SizedBox(height: isSmall ? 12 : 14),
          _buildTextField(),
          SizedBox(height: isSmall ? 28 : 32),
          _buildSubmitButton(isSmall),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isSmall) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isSmall ? 16 : 18,
        fontWeight: FontWeight.w900,
        color: const Color(0xff111827),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedField,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.green.shade700,
      ),
      decoration: _inputDecoration(),
      items: fields.map((field) {
        return DropdownMenuItem(
          value: field["value"],
          child: Text(
            field["label"]!,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedField = value);
      },
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: valueController,
      cursorColor: const Color(0xff047857),
      decoration: _inputDecoration(
        hintText: "Enter new value",
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xfff7fbf8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.green.withOpacity(.18),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: Color(0xff10b981),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isSmall) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: Colors.green.withOpacity(.12),
        highlightColor: Colors.green.withOpacity(.08),
        onTap: isLoading ? null : submitRequest,
        child: Ink(
          width: double.infinity,
          height: isSmall ? 56 : 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff047857),
                Color(0xff10b981),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(.24),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.6,
                    ),
                  )
                : Text(
                    "Submit Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: isSmall ? 16 : 18,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}