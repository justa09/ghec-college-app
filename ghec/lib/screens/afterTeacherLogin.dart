import 'package:flutter/material.dart';
import 'package:ghec/screens/login.dart';
import 'package:ghec/screens/markAttenddance.dart';
import 'package:ghec/screens/requests_screen.dart';
import 'addStu.dart';
import 'register.dart';

class Afterteacherlogin extends StatefulWidget {
  final String teacherId;
  final String image;
  final String username;

  const Afterteacherlogin({
    super.key,
    required this.teacherId,
    required this.image,
    required this.username,
  });

  @override
  State<Afterteacherlogin> createState() => _AfterteacherloginState();
}

class _AfterteacherloginState extends State<Afterteacherlogin> {
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
        child: Column(
          children: [
            /// 🔹 HEADER
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff11998e), Color(0xff0f9b0f)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        /// 👤 Profile + Name
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: size.width * 0.06,
                                backgroundImage: widget.image.isNotEmpty
                                    ? NetworkImage(widget.image)
                                    : null,
                                child: widget.image.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),

                              SizedBox(width: size.width * 0.03),

                              /// 🔥 Responsive Name
                              Expanded(
                                child: Tooltip(
                                  message: widget.username,
                                  child: Text(
                                    widget.username,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🚪 Logout
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: size.width * 0.05,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// 🔹 DASHBOARD
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
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
                      padding: EdgeInsets.all(size.width * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Teacher Dashboard",
                            style: TextStyle(
                              fontSize: size.width * 0.065,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: size.height * 0.04),

                          _buildMenuButton(
                            context,
                            icon: Icons.check_circle_outline,
                            title: "Mark Attendance",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Markattendance(),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: size.height * 0.025),

                          _buildMenuButton(
                            context,
                            icon: Icons.person_add,
                            title: "Add Student",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Addstu(),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: size.height * 0.025),

                          _buildMenuButton(
                            context,
                            icon: Icons.remove_from_queue,
                            title: "Requests",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RequestsScreen(),
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

  /// 🔹 Responsive Button
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.025,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: size.width * 0.07),
              SizedBox(width: size.width * 0.05),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
