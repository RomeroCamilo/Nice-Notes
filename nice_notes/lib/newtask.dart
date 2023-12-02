import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nice_notes/main.dart';
import 'taskclass.dart';
import 'database_services.dart';
import 'loginPage.dart';
import 'dart:math';

String generateRandomString(int len) {
  final random = Random();
  final result = String.fromCharCodes(
      List.generate(len, (index) => random.nextInt(33) + 89));
  return result;
}

class NewTask extends StatefulWidget {
  // Makes sure Task is not reassigned after a save by making it final
  final Function(Task) onSave;

  NewTask({required this.onSave});

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  // Controllers for text inputs
  late TextEditingController _taskNameController;
  late TextEditingController _taskInfoController;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _taskInfoController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 50, 100),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 170, 250),
        centerTitle: true,
        title: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                    title: 'Nice Tasks',
                  ),
                ),
              );
            },
            child: const Text(
              'Nice Tasks',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 30),
            )),
        actions: [
          IconButton(
              onPressed: () async {
                await GoogleSignIn().signOut(); // Google Sign Out
                FirebaseAuth.instance.signOut(); // Email/PW Sign Out
                ScaffoldMessenger.of(
                        context) // snackbar notification to let the user know they're signed out
                    .showSnackBar(const SnackBar(content: Text('Logged Out')));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Name:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255)),
            ),
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 90, 170, 250),
                contentPadding: EdgeInsets.all(5.0),
                hintText: 'Enter task name',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Task Info:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255)),
            ),
            TextField(
              controller: _taskInfoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 90, 170, 250),
                contentPadding: EdgeInsets.all(5.0),
                hintText: 'Enter task info',
              ),
            ),
            SizedBox(
              height: 16.0,
              width: 10.0,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveTask();
                },
                child: Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save new task
  void _saveTask() async {
    // Get the task name and task info from the controllers
    String taskName = _taskNameController.text.trim();
    String taskInfo = _taskInfoController.text.trim();

    // Check if either the task name or task info is empty
    if (taskName.isEmpty || taskInfo.isEmpty) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Task name and task info cannot be empty')),
      );
      return;
    }

    try {
      Task newTask = Task(
        taskId: generateRandomString(30),
        taskName: taskName,
        taskInfo: taskInfo,
        completed: false,
        timestamp: DateTime.now(),
        uid: FirebaseAuth.instance.currentUser!.uid,
      );

      // Use the addTask function from DatabaseServices to save the task
      await DatabaseServices.addTask(newTask);

      // Notifies ToDoListPage about the new task
      widget.onSave(newTask);

      // Once the task is created, the user is redirected to the ToDoListPage
      Navigator.pop(context);
    } catch (error) {
      print('Error saving task: $error');
    }
  }
}
