import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ghec/api/attendanceApi.dart';
import 'package:ghec/screens/login.dart';
import 'package:ghec/screens/showAttandance.dart';

class Afterlogin extends StatefulWidget {
  final String rollNo;
  const Afterlogin({super.key, required this.rollNo});

  @override
  State<Afterlogin> createState() => _Afterlogin();
}

class _Afterlogin extends State<Afterlogin> {
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
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff11998e), Color(0xff0f9b0f)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.rollNo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Material(
                  elevation: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildMenuButton(
                            icon: Icons.bar_chart,
                            title: "Result ->",
                            onTap: () {
                              print("ok");
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildMenuButton(
                            icon: Icons.currency_rupee,
                            title: "Fees ->",
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          _buildMenuButton(
                            icon: Icons.check_circle_outline,
                            title: "Attendance ->",
                            onTap: () async {
                              // 🔹 Fetch attendance data from backend
                              List<dynamic>? attendanceData =
                                  await ShowAttendanceApi().showAttendance([
                                    widget.rollNo,
                                  ]);

                              if (attendanceData == null ||
                                  attendanceData.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to fetch attendance"),
                                  ),
                                );
                                return;
                              }

                              // 🔹 Extract subjects list from backend data
                              List<String> subjects = [];
                              if (attendanceData.first.containsKey(
                                'subjects',
                              )) {
                                for (var subj
                                    in attendanceData.first['subjects']) {
                                  subjects.add(subj['subject'].toString());
                                }
                              }

                              // 🔹 Navigate to AttendancePage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendancePage(
                                    rollNo: widget.rollNo,
                                    subjects: subjects,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
