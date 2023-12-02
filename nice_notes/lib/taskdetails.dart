import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nice_notes/main.dart';
import 'taskclass.dart';
import 'loginPage.dart';

class TaskDetailsPage extends StatefulWidget {
  // Makes sure Task is not reassigned after a save by making it final
  final Task task;
  final Function(Task) onUpdate;
  final Function(Task) onDelete;

  // Constructor
  TaskDetailsPage({
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  // Textbox controllers
  late TextEditingController _taskNameController;
  late TextEditingController _taskInfoController;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.task.taskName);
    _taskInfoController = TextEditingController(text: widget.task.taskInfo);
    _completed = widget.task.completed;
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
        padding: EdgeInsets.all(16.0),
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
              'Task Info',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255)),
            ),
            SizedBox(
                child: TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: _taskInfoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 90, 170, 250),
                contentPadding: EdgeInsets.all(5.0),
                hintText: 'Enter task info',
              ),
            )),

            SizedBox(height: 16.0, width: 10.0),

            // Checkbox for completed/not completed task
            CheckboxListTile(
              tileColor: Color.fromARGB(0, 0, 0, 0),
              title: Text(
                _completed ? 'Completed' : 'Not Completed',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              value: _completed,
              onChanged: (bool? value) {
                setState(() {
                  _completed = value ?? false;
                });
              },
            ),
            SizedBox(height: 16.0),
            // Display timestamp
            Text(
              'Created on: ${widget.task.timestamp}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255)),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Update task button
                ElevatedButton(
                  onPressed: () {
                    _updateTask(); /* updates task info */
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Text('Update Task'),
                ),
                SizedBox(width: 16.0),
                // Delete task button
                ElevatedButton(
                  onPressed: () {
                    _deleteTask();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: Text('Delete Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* update the task */
  void _updateTask() {
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

    // Update the task properties
    widget.task.taskName = taskName;
    widget.task.taskInfo = taskInfo;
    widget.task.completed = _completed;

    // Notifies ToDoListPage about the update
    widget.onUpdate(widget.task);

    // Redirects user back to task details page after updating
    Navigator.pop(context);
  }

  void _deleteTask() {
    // Notifies ToDoListPage about the deletion
    widget.onDelete(widget.task);

    // Redirects user back to task details page after deleting
    Navigator.pop(context);
  }
}
