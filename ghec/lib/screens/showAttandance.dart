import 'package:flutter/material.dart';
import 'package:ghec/api/attendanceApi.dart';

class AttendancePage extends StatefulWidget {
  final String rollNo;
  final List<String> subjects;
  const AttendancePage({
    super.key,
    required this.rollNo,
    required this.subjects,
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
    setState(() => isLoading = true);

    ShowAttendanceApi api = ShowAttendanceApi();
    final response = await api.showAttendance([widget.rollNo]);

    if (response != null && response.isNotEmpty) {
      final studentData = response.first;
      final List subjectsData = studentData['subjects'] ?? [];

      Map<String, Map<String, int>> fetchedData = {};
      List<String> subjList = [];

      for (var subj in subjectsData) {
        String name = subj['subject'] ?? "Unknown";
        int present = subj['present'] ?? 0;
        int total = subj['total'] ?? 0;
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
          presentDays += data['present'] ?? 0;
          absentDays += (data['total'] ?? 0) - (data['present'] ?? 0);
        });
      } else {
        final data = attendanceData[selectedSubject];
        if (data != null) {
          presentDays = data['present'] ?? 0;
          absentDays = (data['total'] ?? 0) - (data['present'] ?? 0);
        }
      }
    }

    int totalDays = presentDays + absentDays;
    double percentage = totalDays == 0 ? 0 : (presentDays / totalDays) * 100;

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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Attendance Overview",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  DropdownButtonFormField<String>(
                                    value: selectedSubject,
                                    decoration: InputDecoration(
                                      labelText: "Select Subject",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    items: ["All", ...subjects].map((sub) {
                                      return DropdownMenuItem(
                                        value: sub,
                                        child: Text(sub),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSubject = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 30),
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.green.shade600,
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Attendance Summary",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _statItem(
                                                "Present",
                                                presentDays,
                                                Colors.white,
                                              ),
                                              _statItem(
                                                "Absent",
                                                absentDays,
                                                Colors.red,
                                              ),
                                              _statItem(
                                                "Total",
                                                totalDays,
                                                Colors.white,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            "Percentage: ${percentage.toStringAsFixed(1)}%",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          if (percentage < 75) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              "Warning: You are currently detained in $selectedSubject subject",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Note: This is a read-only view. Attendance is managed by admin.",
                                    style: TextStyle(color: Colors.black54),
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
    );
  }

  Widget _statItem(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: TextStyle(color: color)),
      ],
    );
  }
}
