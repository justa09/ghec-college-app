import 'package:flutter/material.dart';
import '../api/fetchStudentApi.dart';
import '../api/fetchSubjectApi.dart';
import '../api/attendanceApi.dart';

class Markattendance extends StatefulWidget {
  const Markattendance({super.key});

  @override
  State<Markattendance> createState() => _MarkattendanceState();
}

class _MarkattendanceState extends State<Markattendance> {
  String? selectedBranch;
  String? selectedSemester;
  Map<String, dynamic>? selectedSubject;

  final List<String> branches = ["cse", "Mechanical", "civil", "Electrical"];
  final List<String> semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];

  List<Map<String, dynamic>> subjects = [];
  List<Map<String, String>> students = [];
  Map<String, String> attendanceStatus = {};
  bool isLoading = false;

  Future<void> fetchSubjects() async {
    if (selectedBranch == null || selectedSemester == null) return;
    setState(() => isLoading = true);

    final fetchedSubjects = await FetchSubjectApi().fetchSubjects(
      branch: selectedBranch!,
      semester: int.parse(selectedSemester!),
    );

    setState(() {
      subjects = fetchedSubjects;
      selectedSubject = null;
      isLoading = false;
    });
  }

  Future<void> fetchStudents() async {
    if (selectedBranch == null || selectedSemester == null) return;
    setState(() => isLoading = true);

    final fetchedStudents = await FetchStudentApi().fetchStudents(
      branches: [selectedBranch!],
      semesters: [int.parse(selectedSemester!)],
    );

    setState(() {
      students = fetchedStudents;
      attendanceStatus = {};
      isLoading = false;
    });
  }

  Future<void> submitAttendance() async {
    if (selectedSubject == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a subject first")));
      return;
    }

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No students to mark attendance")),
      );
      return;
    }

    final today = DateTime.now().toString().split(" ")[0];
    int lectureNo = 1;

    List<Map<String, dynamic>> payload = students.map((student) {
      final rollNum = student["roll_num"]!;
      final status = attendanceStatus[rollNum] ?? "A";

      return {
        "roll_num": rollNum,
        "subject_id": selectedSubject!["subject_id"],
        "status": status,
        "lecture_no": lectureNo,
        "date": today,
      };
    }).toList();

    bool success = await AttendanceApi().submitAttendance(payload);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance submitted successfully")),
      );
      setState(() => attendanceStatus = {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit attendance")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        centerTitle: true,
        elevation: 6,
        backgroundColor: const Color(0xff11998e),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff11998e), Color(0xff38ef7d)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              /// Dropdown Section
              _buildDropdownCard(),

              const SizedBox(height: 12),

              /// Fetch Button
              ElevatedButton.icon(
                onPressed: fetchStudents,
                icon: const Icon(Icons.people),
                label: const Text("Fetch Students"),
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (isLoading) const CircularProgressIndicator(),

              const SizedBox(height: 10),

              /// Student List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final rollNum = student["roll_num"]!;
                      final status = attendanceStatus[rollNum];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          title: Text(
                            student["full_name"]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("Roll No: $rollNum"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _statusButton("P", rollNum, status),

                              const SizedBox(width: 6),

                              _statusButton("A", rollNum, status),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// Submit Button
              ElevatedButton.icon(
                onPressed: submitAttendance,
                icon: const Icon(Icons.save),
                label: const Text("Submit Attendance"),
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusButton(String value, String rollNum, String? status) {
    final isSelected = status == value;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          attendanceStatus[rollNum] = value;
        });
      },
      style: ElevatedButton.styleFrom(
        elevation: 3,
        backgroundColor: isSelected
            ? (value == "P" ? Colors.green : Colors.red)
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(value),
    );
  }

  Widget _buildDropdownCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedBranch,
              decoration: const InputDecoration(
                labelText: "Select Branch",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_tree),
              ),
              items: branches
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedBranch = val;
                  selectedSubject = null;
                  subjects = [];
                });

                if (selectedBranch != null && selectedSemester != null) {
                  fetchSubjects();
                }
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: const InputDecoration(
                labelText: "Select Semester",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: semesters
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSemester = val;
                  selectedSubject = null;
                  subjects = [];
                });

                if (selectedBranch != null && selectedSemester != null) {
                  fetchSubjects();
                }
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: "Select Subject",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
              ),
              items: subjects
                  .map(
                    (sub) => DropdownMenuItem(
                      value: sub,
                      child: Text(sub["name"], overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: subjects.isEmpty
                  ? null
                  : (val) => setState(() => selectedSubject = val),
            ),
          ],
        ),
      ),
    );
  }
}
