import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ghec/screens/afterTeacherLogin.dart';
import 'package:ghec/screens/register.dart';
import 'about.dart';
import 'afterStuLogin.dart';
import 'package:http/http.dart' as http;
import 'package:ghec/api/apiServices.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? usertype;

  final TextEditingController rollNo = TextEditingController();
  final TextEditingController passw = TextEditingController();

  @override
  void dispose() {
    rollNo.dispose();
    passw.dispose();
    super.dispose();
  }

  void login() async {
    if (rollNo.text.isEmpty || passw.text.isEmpty || usertype == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Warning..!"),
          content: const Text("Please fill all fields and select user type..!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final result = await ApiService.login(rollNo.text, passw.text, usertype!);

      if (result["status"] == "success") {
        if (usertype == "teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Afterteacherlogin(
                teacherId: result["username"],
                image: result['image'],
              ),
            ),
          );
        }

        if (usertype == "student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Afterlogin(
                rollNo: result["username"],
                image: result['image'],
              ),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Failed"),
            content: Text(result["message"] ?? "Invalid credentials"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _directLogin() {
    if (rollNo.text.isEmpty || passw.text.isEmpty || usertype == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Warning..!"),
          content: const Text("Please fill all fields and select user type..!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (usertype == "teacher") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Afterteacherlogin(teacherId: rollNo.text, image: ""),
        ),
      );
      return;
    }

    if (usertype == "student") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Afterlogin(rollNo: rollNo.text, image: ""),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
          child: Column(
            children: [
              SizedBox(height: screenHeight * .08),

              /// Simple Header (Logo + GHEC)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/images/logo.jpg"),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      "GHEC",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * .05),

              /// Login Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      const Text(
                        "Login Here",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// Roll Number
                      SizedBox(
                        width: screenWidth * .85,
                        child: TextFormField(
                          controller: rollNo,
                          decoration: InputDecoration(
                            labelText: "Teacher Id / Roll No ",
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Password
                      SizedBox(
                        width: screenWidth * .85,
                        child: TextFormField(
                          controller: passw,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// User Type
                      Container(
                        width: screenWidth * .85,
                        padding: const EdgeInsets.symmetric(vertical: 10),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: "teacher",
                                  groupValue: usertype,
                                  activeColor: Colors.green,
                                  onChanged: (val) {
                                    setState(() {
                                      usertype = val;
                                    });
                                  },
                                ),
                                const Text("Teacher"),
                              ],
                            ),

                            Row(
                              children: [
                                Radio<String>(
                                  value: "student",
                                  groupValue: usertype,
                                  activeColor: Colors.green,
                                  onChanged: (val) {
                                    setState(() {
                                      usertype = val;
                                    });
                                  },
                                ),
                                const Text("Student"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Login Button
                      SizedBox(
                        width: screenWidth * .85,
                        height: 55,

                        child: ElevatedButton(
                          onPressed: login,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Register Here"),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutPage(),
                            ),
                          );
                        },
                        child: const Text("About College"),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
