import 'package:flutter/material.dart';
import 'package:ghec/api/attendanceApi.dart';
import 'package:ghec/screens/login.dart';
import 'package:ghec/screens/showAttandance.dart';
import 'package:ghec/screens/update.dart';

class Afterlogin extends StatefulWidget {
  final String rollNo;
  final String image;
  final String username;

  const Afterlogin({
    super.key,
    required this.rollNo,
    required this.image,
    required this.username,
  });

  @override
  State<Afterlogin> createState() => _Afterlogin();
}

class _Afterlogin extends State<Afterlogin> {
  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  String getFirstName(String name) {
    if (name.trim().isEmpty) return "Student";
    return name.trim().split(" ").first;
  }

  int getCrossAxisCount(double width) {
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 2;
  }

  double getCardRatio(double width) {
    if (width >= 900) return 1.2;
    if (width >= 600) return 1.05;
    return 0.95;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final bool isSmall = width < 380;
    final double horizontalPadding = width < 420 ? 16 : 22;
    final double maxContentWidth = width >= 900 ? 850 : 620;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                height: 250,
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
                                CircleAvatar(
                                  radius: isSmall ? 28 : 34,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      widget.image.isNotEmpty
                                          ? NetworkImage(widget.image)
                                          : null,
                                  child: widget.image.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.green.shade700,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getFirstName(widget.username),
                                        style: TextStyle(
                                          fontSize: isSmall ? 22 : 26,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        widget.rollNo,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: logout,
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            Container(
                              padding: const EdgeInsets.all(20),
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
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: getCrossAxisCount(width),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: getCardRatio(width),
                                children: [
                                  _dashboardCard(
                                    icon: Icons.bar_chart,
                                    title: "Result",
                                    onTap: () {
                                      print("Result Clicked");
                                    },
                                  ),
                                  _dashboardCard(
                                    icon: Icons.edit,
                                    title: "Update Profile",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UpdateProfileRequestPage(
                                            rollNo: widget.rollNo,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _dashboardCard(
                                    icon: Icons.check_circle_outline,
                                    title: "Attendance",
                                    onTap: () async {
                                      List<dynamic>? attendanceData =
                                          await ShowAttendanceApi()
                                              .showAttendance([
                                        widget.rollNo,
                                      ]);

                                      if (attendanceData == null ||
                                          attendanceData.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Failed to fetch attendance",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      List<String> subjects = [];

                                      if (attendanceData.first
                                          .containsKey('subjects')) {
                                        for (var subj in attendanceData.first[
                                            'subjects']) {
                                          subjects.add(
                                            subj['subject'].toString(),
                                          );
                                        }
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AttendancePage(
                                            username: widget.username,
                                            rollNo: widget.rollNo,
                                            subjects: subjects,
                                            image: widget.image,
                                          ),
                                        ),
                                      );
                                    },
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

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xfff7fbf8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.green.withOpacity(.2),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff047857), Color(0xff10b981)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}