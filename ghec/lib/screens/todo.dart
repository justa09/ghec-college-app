import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final box = Hive.box('todoBox');

  List tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks(); // 🔥 load from storage
  }

  void loadTasks() {
    final data = box.get('tasks', defaultValue: []);
    setState(() {
      tasks = List.from(data);
    });
  }

  // ➕ ADD TASK
  void addTask(String title) {
    tasks.add({
      "title": title,
      "done": false,
      "date": DateTime.now().toString(),
    });

    box.put('tasks', tasks); // 🔥 save
    setState(() {});
  }

  // ❌ DELETE
  void deleteTask(int index) {
    tasks.removeAt(index);
    box.put('tasks', tasks);
    setState(() {});
  }

  // ✅ TOGGLE
  void toggleTask(int index) {
    tasks[index]["done"] = !tasks[index]["done"];
    box.put('tasks', tasks);
    setState(() {});
  }

  // 📝 ADD TASK POPUP
  void showAddDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter task..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                addTask(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tasks"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),

      body: tasks.isEmpty
          ? const Center(child: Text("No Tasks Yet"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Checkbox(
                      value: task["done"],
                      onChanged: (value) {
                        toggleTask(index);
                      },
                    ),
                    title: Text(
                      task["title"],
                      style: TextStyle(
                        decoration: task["done"]
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(task["date"]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteTask(index);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
