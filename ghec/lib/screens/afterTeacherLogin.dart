import 'package:flutter/material.dart';
import 'package:ghec/screens/login.dart';
import 'package:ghec/screens/markAttenddance.dart';
import 'addStu.dart';

class Afterteacherlogin extends StatefulWidget {
  final String teacherId;
  final String image;

  const Afterteacherlogin({
    super.key,
    required this.teacherId,
    required this.image,
  });

  @override
  State<Afterteacherlogin> createState() => _AfterteacherloginState();
}

class _AfterteacherloginState extends State<Afterteacherlogin> {
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
            /// 🔹 Header
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
                        /// Teacher Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: widget.image.isNotEmpty
                                  ? NetworkImage(widget.image)
                                  : null,
                              child: widget.image.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.teacherId,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        /// Logout Button
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

            /// 🔹 Dashboard Area
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
                            "Teacher Dashboard",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// Mark Attendance
                          _buildMenuButton(
                            icon: Icons.check_circle_outline,
                            title: "Mark Attendance ->",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Markattendance(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          /// Add Student
                          _buildMenuButton(
                            icon: Icons.person_add,
                            title: "Add Student ->",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Addstu(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          /// Add Result
                          _buildMenuButton(
                            icon: Icons.assignment,
                            title: "Add Result ->",
                            onTap: () {},
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

  /// 🔹 Dashboard Buttons
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
