import 'package:flutter/material.dart';
import 'package:ghec/api/attendanceApi.dart';

class AttendancePage extends StatefulWidget {
  final String rollNo;
  final String username;
  final String image;
  final List<String> subjects;

  const AttendancePage({
    super.key,
    required this.rollNo,
    required this.subjects,
    required this.username,
    required this.image,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String selectedSubject = "All";
  List<String> subjects = [];
  Map<String, Map<String, int>> attendanceData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    ShowAttendanceApi api = ShowAttendanceApi();
    final response = await api.showAttendance([widget.rollNo]);

    if (!mounted) return;

    if (response != null && response.isNotEmpty) {
      final studentData = response.first;
      final List subjectsData = studentData['subjects'] ?? [];

      Map<String, Map<String, int>> fetchedData = {};
      List<String> subjList = [];

      for (int i = 0; i < subjectsData.length; i++) {
        final subj = subjectsData[i];

        String name = (subj['subject'] ?? "Unknown").toString();
        int present = (subj['present'] ?? 0) is int
            ? subj['present']
            : int.tryParse(subj['present'].toString()) ?? 0;

        int total = (subj['total'] ?? 0) is int
            ? subj['total']
            : int.tryParse(subj['total'].toString()) ?? 0;

        if (present > total) present = total;

        fetchedData[name] = {"present": present, "total": total};
        subjList.add(name);
      }

      setState(() {
        attendanceData = fetchedData;
        subjects = subjList;
        selectedSubject = "All";
        isLoading = false;
      });
    } else {
      setState(() {
        attendanceData = {};
        subjects = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentDays = 0;
    int absentDays = 0;

    if (!isLoading) {
      if (selectedSubject == "All") {
        attendanceData.forEach((_, data) {
          int p = data['present'] ?? 0;
          int t = data['total'] ?? 0;
          if (p > t) p = t;
          presentDays += p;
          absentDays += (t - p);
        });
      } else {
        final data = attendanceData[selectedSubject];
        if (data != null) {
          int p = data['present'] ?? 0;
          int t = data['total'] ?? 0;
          if (p > t) p = t;
          presentDays = p;
          absentDays = (t - p);
        }
      }
    }

    int totalDays = presentDays + absentDays;
    double percentage = totalDays == 0 ? 0 : (presentDays / totalDays) * 100;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final bool isSmall = width < 380;
    final double horizontalPadding = width < 420 ? 16 : 22;
    final double maxContentWidth = width >= 760 ? 620 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: Stack(
        children: [
          Container(
            height: 245,
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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmall ? 14 : 20,
                  ),
                  child: _buildHeader(isSmall),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          18,
                        ),
                        child: Container(
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
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green.shade700,
                                    strokeWidth: 3,
                                  ),
                                )
                              : SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Attendance Overview",
                                        style: TextStyle(
                                          fontSize: isSmall ? 23 : 26,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xff111827),
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      DropdownButtonFormField<String>(
                                        initialValue: selectedSubject,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        decoration: InputDecoration(
                                          labelText: "Select Subject",
                                          labelStyle: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.menu_book_rounded,
                                            color: Colors.green.shade700,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xfff7fbf8),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade200,
                                              width: 1.2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: Colors.green.shade600,
                                              width: 1.8,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.green.shade700,
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xff111827),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: ["All", ...subjects].map((sub) {
                                          return DropdownMenuItem(
                                            value: sub,
                                            child: Text(
                                              sub,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value == null) return;
                                          setState(() {
                                            selectedSubject = value;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(
                                          isSmall ? 18 : 22,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff7fbf8),
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          border: Border.all(
                                            color:
                                                Colors.green.withOpacity(.14),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(.08),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: isSmall ? 150 : 170,
                                              width: isSmall ? 150 : 170,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: isSmall ? 140 : 158,
                                                    width: isSmall ? 140 : 158,
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: percentage / 100,
                                                      strokeWidth:
                                                          isSmall ? 12 : 14,
                                                      backgroundColor:
                                                          Colors.grey.shade200,
                                                      color: const Color(
                                                        0xff059669,
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "${percentage.toStringAsFixed(1)}%",
                                                        style: TextStyle(
                                                          fontSize: isSmall
                                                              ? 27
                                                              : 32,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: const Color(
                                                            0xff111827,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        "Percentage",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                            0xff4b5563,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 22),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _modernStatCard(
                                                    "Present",
                                                    presentDays,
                                                    Icons.check_circle_rounded,
                                                    const Color(0xff059669),
                                                    isSmall,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _modernStatCard(
                                                    "Absent",
                                                    absentDays,
                                                    Icons.cancel_rounded,
                                                    const Color(0xffdc2626),
                                                    isSmall,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _modernStatCard(
                                                    "Total",
                                                    totalDays,
                                                    Icons.event_note_rounded,
                                                    const Color(0xff047857),
                                                    isSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (percentage < 75 &&
                                                selectedSubject != "All") ...[
                                              const SizedBox(height: 18),
                                              Text(
                                                "Warning: You are currently detained in $selectedSubject subject",
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xffdc2626),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize:
                                                      isSmall ? 14 : 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff7fbf8),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color:
                                                Colors.green.withOpacity(.12),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: const Text(
                                          "Note: This is a read-only view. Attendance is managed by admin.",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
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
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
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
            radius: isSmall ? 28 : 34,
            backgroundColor: Colors.white,
            backgroundImage:
                widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
            child: widget.image.isEmpty
                ? Icon(
                    Icons.person,
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
                widget.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 22 : 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.rollNo,
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
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modernStatCard(
    String title,
    int value,
    IconData icon,
    Color color,
    bool isSmall,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(.14),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isSmall ? 22 : 24,
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 20 : 23,
              fontWeight: FontWeight.w900,
              color: const Color(0xff111827),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xff4b5563),
            ),
          ),
        ],
      ),
    );
  }
}