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

  // ============================================================
  // FETCH ATTENDANCE OVERVIEW
  // ============================================================

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

        if (present > total) {
          present = total;
        }

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

  // ============================================================
  // SHOW ATTENDANCE RECORDS
  // ============================================================

  Future<void> showAttendanceRecords(String status) async {
    // ----------------------------------------------------------
    // ALL SUBJECTS SELECTED
    // ----------------------------------------------------------

    if (selectedSubject == "All") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select Subject"),
            content: const Text("Please select a specific subject first."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      return;
    }

    // ----------------------------------------------------------
    // SHOW LOADING DIALOG
    // ----------------------------------------------------------

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      AttendanceRecordsApi api = AttendanceRecordsApi();

      final data = await api.showRecords(
        widget.rollNo,
        selectedSubject,
        status,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      // --------------------------------------------------------
      // API FAILED
      // --------------------------------------------------------

      if (data == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Unable to fetch attendance records."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        return;
      }

      // --------------------------------------------------------
      // GET RECORDS
      // --------------------------------------------------------

      final List records = data['records'] ?? [];

      // --------------------------------------------------------
      // NO RECORDS
      // --------------------------------------------------------

      if (records.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("$status Attendance"),
              content: Text(
                "No $status attendance records found for $selectedSubject.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        return;
      }

      // --------------------------------------------------------
      // SHOW RECORDS
      // --------------------------------------------------------

      showAttendanceRecordsDialog(records, data, status);
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Something went wrong.\n$e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  // ============================================================
  // RECORDS DIALOG
  // ============================================================

  void showAttendanceRecordsDialog(
    List records,
    Map<String, dynamic> data,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Icon(
                status.toLowerCase() == "present"
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: status.toLowerCase() == "present"
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$status Attendance",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: screenWidth > 600 ? 600 : screenWidth * .9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------
                // SUBJECT INFO
                // ------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff7fbf8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 22,
                        color: Color(0xff047857),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedSubject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        "${records.length} Records",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // TABLE HEADER
                // ------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff047857),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Subject",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Date",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ------------------------------------------------
                // RECORD LIST
                // ------------------------------------------------
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 350),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: records.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final record = records[index];

                        final String date = (record['date'] ?? "-").toString();

                        final String recordStatus = (record['status'] ?? status)
                            .toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? const Color(0xfff8faf9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  selectedSubject,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  recordStatus,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color:
                                        recordStatus.toLowerCase() == "present"
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  date,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    int presentDays = 0;
    int absentDays = 0;

    if (!isLoading) {
      if (selectedSubject == "All") {
        attendanceData.forEach((_, data) {
          int p = data['present'] ?? 0;
          int t = data['total'] ?? 0;

          if (p > t) {
            p = t;
          }

          presentDays += p;
          absentDays += (t - p);
        });
      } else {
        final data = attendanceData[selectedSubject];

        if (data != null) {
          int p = data['present'] ?? 0;
          int t = data['total'] ?? 0;

          if (p > t) {
            p = t;
          }

          presentDays = p;
          absentDays = t - p;
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
          // ======================================================
          // TOP GREEN HEADER BACKGROUND
          // ======================================================
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
                // =================================================
                // HEADER
                // =================================================
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmall ? 14 : 20,
                  ),
                  child: _buildHeader(isSmall),
                ),

                // =================================================
                // MAIN CARD
                // =================================================
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
                                      const Text(
                                        "Attendance Overview",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xff111827),
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      // =================================================
                                      // SUBJECT DROPDOWN
                                      // =================================================
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
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade200,
                                              width: 1.2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.green.shade600,
                                              width: 1.8,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
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
                                          if (value == null) {
                                            return;
                                          }

                                          setState(() {
                                            selectedSubject = value;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // =================================================
                                      // ATTENDANCE OVERVIEW CARD
                                      // =================================================
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(
                                          isSmall ? 18 : 22,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff7fbf8),
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.withOpacity(
                                              .14,
                                            ),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                .08,
                                              ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            // ==========================================
                                            // CIRCLE
                                            // ==========================================
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
                                                          value:
                                                              percentage / 100,
                                                          strokeWidth: isSmall
                                                              ? 12
                                                              : 14,
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade200,
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

                                            // ==========================================
                                            // PRESENT / ABSENT / TOTAL
                                            // ==========================================
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showAttendanceRecords(
                                                        "P",
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                    child: _modernStatCard(
                                                      "Present",
                                                      presentDays,
                                                      Icons
                                                          .check_circle_rounded,
                                                      const Color(0xff059669),
                                                      isSmall,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showAttendanceRecords(
                                                        "A",
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                    child: _modernStatCard(
                                                      "Absent",
                                                      absentDays,
                                                      Icons.cancel_rounded,
                                                      const Color(0xffdc2626),
                                                      isSmall,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showAttendanceRecords(
                                                        "T",
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          18,
                                                        ),
                                                    child: _modernStatCard(
                                                      "Total",
                                                      absentDays,
                                                      Icons.all_inbox,
                                                      const Color.fromARGB(
                                                        255,
                                                        7,
                                                        186,
                                                        69,
                                                      ),
                                                      isSmall,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // ==========================================
                                            // WARNING
                                            // ==========================================
                                            if (percentage < 75 &&
                                                selectedSubject != "All") ...[
                                              const SizedBox(height: 18),
                                              Text(
                                                "Warning: You are currently detained in $selectedSubject subject",
                                                style: TextStyle(
                                                  color: const Color(
                                                    0xffdc2626,
                                                  ),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: isSmall ? 14 : 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // =================================================
                                      // NOTE
                                      // =================================================
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff7fbf8),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.withOpacity(
                                              .12,
                                            ),
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(bool isSmall) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.35)),
          ),
          child: CircleAvatar(
            radius: isSmall ? 28 : 34,
            backgroundColor: Colors.white,
            backgroundImage: widget.image.isNotEmpty
                ? NetworkImage(widget.image)
                : null,
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
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

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
        border: Border.all(color: color.withOpacity(.14), width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmall ? 22 : 24),

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
