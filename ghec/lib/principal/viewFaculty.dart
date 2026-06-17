import 'package:flutter/material.dart';
import '../api/addTeacherApi.dart';

class ViewFaculty extends StatefulWidget {
  const ViewFaculty({super.key});

  @override
  State<ViewFaculty> createState() => _ViewFacultyState();
}

class _ViewFacultyState extends State<ViewFaculty> {
  final TeacherApi teacherApi = TeacherApi(
    baseURL: "http://192.168.43.148:8000/api",
  );

  List<Map<String, String>> teachers = [];
  bool isLoading = false;
  int total = 0;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    setState(() {
      isLoading = true;
    });

    final fetchedTeachers = await teacherApi.fetchTeachers();

    if (!mounted) return;

    setState(() {
      teachers = fetchedTeachers["teachers"] != null
          ? List<Map<String, String>>.from(fetchedTeachers["teachers"])
          : [];

      total = fetchedTeachers["total"] ?? teachers.length;
      isLoading = false;
    });
  }

  Future<void> deleteTeacher(String teacherId, int index) async {
    final success = await teacherApi.deleteTeacher(teacherId);

    if (!mounted) return;

    if (success) {
      setState(() {
        teachers.removeAt(index);
        total = teachers.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Faculty"),
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
              const SizedBox(height: 10),

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
                  "Fetched Teachers = $total",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (isLoading) const CircularProgressIndicator(),

              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: teachers.isEmpty && !isLoading
                      ? const Center(
                          child: Text(
                            "No teachers found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = teachers[index];

                            final teacherId =
                                teacher["Tid"]?.toString() ?? "";
                            final fullName =
                                teacher["FullName"]?.toString() ?? "";
                            final phone =
                                teacher["Tphone"]?.toString() ?? "";
                            final dept = teacher["dept"]?.toString() ?? "";
                            final role = teacher["role"]?.toString() ?? "";

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 6),
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
                                  "ID: $teacherId\nPhone: $phone\nDept: $dept\nRole: $role",
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text("Confirm Deletion"),
                                        content: Text(
                                          "Are you sure you want to delete $fullName?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(dialogContext);
                                              await deleteTeacher(
                                                teacherId,
                                                index,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text("Delete"),
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
}