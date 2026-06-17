import 'package:flutter/material.dart';
import 'package:ghec/screens/login.dart';
import '../screens/makePost.dart';
import 'viewStudents.dart';
import 'viewFaculty.dart';

class AfterPrincipallogin extends StatefulWidget {
  final String teacherId;
  final String image;
  final String username;

  const AfterPrincipallogin({
    super.key,
    required this.teacherId,
    required this.image,
    required this.username,
  });

  @override
  State<AfterPrincipallogin> createState() => _AfterPrincipalloginState();
}

class _AfterPrincipalloginState extends State<AfterPrincipallogin> {
  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  String getFirstName(String name) {
    if (name.trim().isEmpty) return "Teacher";
    return name.trim().split(" ").first;
  }

  int getCrossAxisCount(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  double getCardRatio(double width) {
    if (width >= 900) return 1.18;
    if (width >= 600) return 1.02;
    if (width < 380) return 0.86;
    return 0.9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final isSmall = width < 380;
          final horizontalPadding = width < 420 ? 16.0 : 22.0;
          final maxContentWidth = width >= 900 ? 850.0 : 620.0;
          final headerHeight = height < 650 ? 240.0 : 285.0;

          return Stack(
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
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: isSmall ? 14 : 20),
                            _buildHeader(width, isSmall),
                            SizedBox(height: isSmall ? 20 : 28),
                            _buildDashboardCard(width),
                            const SizedBox(height: 20),
                            _buildSecureInfo(),
                            const SizedBox(height: 24),
                            const Text(
                              "Green Hills Engineering College",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xff4b5563),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(double width, bool isSmall) {
    final avatarRadius = isSmall ? 28.0 : 34.0;

    return Row(
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
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white,
            backgroundImage:
                widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
            child: widget.image.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    color: Colors.green.shade700,
                    size: isSmall ? 28 : 34,
                  )
                : null,
          ),
        ),
        SizedBox(width: isSmall ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${getFirstName(widget.username)}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 20 : 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "Teacher ID: ${widget.teacherId}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  color: Colors.white.withOpacity(.92),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: logout,
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
                Icons.logout_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(double width) {
    final isSmall = width < 380;

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
          Text(
            "Principal Dashboard",
            style: TextStyle(
              fontSize: isSmall ? 24 : 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xff111827),
            ),
          ),
         
          const SizedBox(height: 22),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: getCrossAxisCount(width),
            crossAxisSpacing: width < 380 ? 10 : 14,
            mainAxisSpacing: width < 380 ? 10 : 14,
            childAspectRatio: getCardRatio(width),
            children: [
             
              _dashboardCard(
                icon: Icons.person_add_alt_1_rounded,
                title: "View Students",
                subtitle: "View student",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Viewstudents(),
                    ),
                  );
                },
              ),
             
              _dashboardCard(
                icon: Icons.app_registration_rounded,
                title: "View Faculty",
                subtitle: "Manage accounts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewFaculty(),
                    ),
                  );
                },
              ),
           
              _dashboardCard(
                icon: Icons.add_photo_alternate_rounded,
                title: "Make Post",
                subtitle: "Share college update",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakePost(
                        Tid: widget.teacherId,
                        Tname: widget.username,
                        image: widget.image,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final smallCard = constraints.maxWidth < 150;
        final iconSize = smallCard ? 42.0 : 50.0;
        final iconRadius = smallCard ? 15.0 : 17.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.green.withOpacity(.12),
            highlightColor: Colors.green.withOpacity(.08),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.all(smallCard ? 12 : 14),
              decoration: BoxDecoration(
                color: const Color(0xfff7fbf8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.green.withOpacity(.22),
                  width: 1.25,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: iconSize,
                    width: iconSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff047857),
                          Color(0xff10b981),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(iconRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(.22),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: smallCard ? 23 : 26,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: smallCard ? 13 : 15,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xff111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: smallCard ? 11 : 12,
                      height: 1.25,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecureInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Secure faculty dashboard for academic management.",
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
    );
  }
}