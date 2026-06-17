import 'package:flutter/material.dart';
import 'package:ghec/screens/afterTeacherLogin.dart';
import 'content.dart';
import 'afterStuLogin.dart';
import 'package:ghec/api/apiServices.dart';
import 'package:ghec/screens/hod/hodLogin.dart';
import 'managementLogin.dart';
import '../principal/principalLogin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController rollNo = TextEditingController();
  final TextEditingController passw = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    rollNo.dispose();
    passw.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_isLoading) return;

    if (rollNo.text.trim().isEmpty || passw.text.isEmpty) {
      showMessage("Missing Details", "Please enter your ID and password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.login(rollNo.text.trim(), passw.text);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result["status"] == "success") {
        if (result["role"] == "teacher" || result["role"] == "Lect") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Afterteacherlogin(
                teacherId: result["id"] ?? rollNo.text.trim(),
                username: result["name"] ?? "",
                image: result["image"] ?? "",
              ),
            ),
          );
        } else if (result["role"] == "student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Afterlogin(
                rollNo: result["id"] ?? rollNo.text.trim(),
                username: result["name"] ?? "",
                image: result["image"] ?? "",
              ),
            ),
          );
    
        }
        else if (result["role"] == "HOD"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AfterHodlogin()));
      
        } else if (result["role"] == "Management"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AfterManagementlogin(
              teacherId: result["id"] ?? rollNo.text.trim(),
                username: result["name"] ?? "",
                image: result["image"] ?? "",
          )));
      } else if (result["role"] == "Principal"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AfterPrincipallogin(
              teacherId: result["id"] ?? rollNo.text.trim(),
                username: result["name"] ?? "",
                image: result["image"] ?? "",
          )));
                }else {
          showMessage("Login Failed", "Invalid user role..!${result["role"]}");
        }
      } else {
        showMessage(
          "Login Failed",
          result["message"] ?? "Invalid credentials.",
        );
      }
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      showMessage("Connection Error", "Unable to login. Please try again.");
    }
  }

  void showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void forgotPassword() {
    // Yaha baad me forgot password screen ka navigation add karenge
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
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
        borderSide: BorderSide(color: Colors.green.shade600, width: 1.7),
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fieldWidth = screenWidth > 500 ? 420 : screenWidth * .86;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: Stack(
        children: [
          Container(
            height: 310,
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
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.18),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(.35),
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 34,
                                backgroundImage:
                                    AssetImage("assets/images/logo.jpg"),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "GHEC",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Smart Academics Portal",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 34),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: 38,
                                  color: Colors.green.shade700,
                                ),
                              ),

                              const SizedBox(height: 18),


                              SizedBox(
                                width: fieldWidth,
                                child: TextFormField(
                                  enabled: !_isLoading,
                                  keyboardType: TextInputType.text,
                                  maxLength: 20,
                                  controller: rollNo,
                                  decoration: inputDecoration(
                                    label: "Teacher ID / Roll No",
                                    icon: Icons.badge_outlined,
                                  ).copyWith(counterText: ""),
                                ),
                              ),

                              const SizedBox(height: 18),

                              SizedBox(
                                width: fieldWidth,
                                child: TextFormField(
                                  enabled: !_isLoading,
                                  controller: passw,
                                  obscureText: _obscureText,
                                  decoration: inputDecoration(
                                    label: "Password",
                                    icon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: Colors.green.shade700,
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              setState(() {
                                                _obscureText = !_obscureText;
                                              });
                                            },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              SizedBox(
                                width: fieldWidth,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed:
                                        _isLoading ? null : forgotPassword,
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              SizedBox(
                                width: fieldWidth,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor:
                                        const Color(0xff059669),
                                    disabledBackgroundColor:
                                        Colors.green.shade300,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Login to Portal",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: .3,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      "college info",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: fieldWidth,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Content(),
                                            ),
                                          );
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Colors.green.shade700,
                                    side: BorderSide(
                                      color: Colors.green.shade100,
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.info_outline_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "About College",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.82),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.green.withOpacity(.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: Colors.green.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Secure login for students and faculty members.",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Green Hills Engineering College",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff4b5563),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

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
}