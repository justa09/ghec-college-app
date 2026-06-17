import 'package:flutter/material.dart';
import '../api/fetchStudentApi.dart';

class Viewstudents extends StatefulWidget {
  const Viewstudents({super.key});

  @override
  State<Viewstudents> createState() => _ViewstudentsState();
}

class _ViewstudentsState extends State<Viewstudents> {
  String? selectedBranch;
  String? selectedSemester;

  final List<String> branches = [
    "all",
    "cse",
    "Mechanical",
    "civil",
    "Electrical",
  ];

  final List<String> semesters = [
    "all",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];

  List<Map<String, String>> students = [];

  bool isLoading = false;

  int total = 0;

  Future<void> fetchStudents() async {
    if (selectedBranch == null || selectedSemester == null) return;

    setState(() {
      isLoading = true;
    });

    final fetchedStudents = await FetchStudentApi().fetchStudents(
      branches: [selectedBranch!],
      semesters: [selectedSemester!],
    );

    setState(() {
      students = fetchedStudents["students"] != null
          ? List<Map<String, String>>.from(
              fetchedStudents["students"],
            )
          : [];

      total = fetchedStudents["total"] ?? 0;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Students"),
        centerTitle: true,
        elevation: 6,
        backgroundColor: const Color(0xff11998e),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff11998e),
              Color(0xff38ef7d),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            children: [
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

              /// Total Students
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Text(
                  "Fatched Students = $total",

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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

                      final rollNum =
                          student["roll_num"]?.toString() ?? "";

                      final fullName =
                          student["full_name"]?.toString() ?? "";

                      return Card(
                        elevation: 4,

                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: ListTile(
                          title: Text(
                            fullName,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            "Roll No: $rollNum",
                          ),

                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,

                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    "Confirm Deletion",
                                  ),

                                  content: Text(
                                    "Are you sure you want to delete $fullName (Roll No: $rollNum)?",
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      child: const Text(
                                        "Cancel",
                                      ),
                                    ),

                                    ElevatedButton(
                                      onPressed: () async {
                                        final success =
                                            await FetchStudentApi()
                                                .deleteStudent(
                                                  rollNum,
                                                );

                                        if (success) {
                                          setState(() {
                                            students.removeAt(index);

                                            total = students.length;
                                          });
                                        }

                                        Navigator.pop(context);
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),

                                      child: const Text(
                                        "Delete",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },

                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Card(
      elevation: 6,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedBranch,

              decoration: const InputDecoration(
                labelText: "Select Branch",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_tree),
              ),

              items: branches
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(b),
                    ),
                  )
                  .toList(),

              onChanged: (val) {
                setState(() {
                  selectedBranch = val;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedSemester,

              decoration: const InputDecoration(
                labelText: "Select Semester",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),

              items: semesters
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s),
                    ),
                  )
                  .toList(),

              onChanged: (val) {
                setState(() {
                  selectedSemester = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}