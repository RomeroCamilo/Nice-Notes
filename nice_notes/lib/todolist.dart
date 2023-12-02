import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nice_notes/main.dart';
import 'taskdetails.dart';
import 'taskclass.dart';
import 'newtask.dart';
import 'database_services.dart';
import 'loginPage.dart';

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  // Arraylist of tasks
  List<Task> tasks = [];
  late String userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _fetchTasks();
  }

  // Retrieve the signed-in user's userId
  void _getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
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
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await GoogleSignIn().signOut(); // Google Sign Out
              FirebaseAuth.instance.signOut(); // Email/PW Sign Out
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Logged Out')));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      // List of tasks using ListView
      body: ListView.builder(
        padding: EdgeInsets.only(top: 16.0),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          // Replacing gesture detector, swipe right to delete
          return Dismissible(
            key: Key(tasks[index].taskId),
            onDismissed: (direction) {
              // Handle the task deletion
              _deleteTask(tasks[index]);
            },
            background: Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3.5),
                borderRadius: BorderRadius.circular(11.0),
              ),
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                tileColor: Color.fromARGB(255, 90, 170, 250),
                contentPadding: EdgeInsets.all(16.0),
                leading: Checkbox(
                  value: tasks[index].completed,
                  onChanged: (bool? value) {
                    _toggleTaskCompletion(index, value);
                  },
                ),
                title: Text(
                  tasks[index].taskName,
                  style: TextStyle(fontSize: 22),
                ),
                subtitle: Text(
                  'Created on: ${tasks[index].timestamp.toLocal()}',
                  style: TextStyle(fontSize: 9),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_left, color: Colors.red),
                    SizedBox(width: 4.0),
                    Icon(Icons.delete, color: Colors.red),
                  ],
                ),
                onTap: () {
                  _navigateToTaskDetails(tasks[index]);
                },
              ),
            ),
          );
        },
      ),

      // Add task button which navigates user to the new task page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNewTaskPage();
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

// Fetch tasks for the current user
  void _fetchTasks() async {
    try {
      List<Task> userTasks = await DatabaseServices.getTasks(userId);
      setState(() {
        tasks = userTasks;
      });
    } catch (e) {
      print('Failed to fetch tasks: $e');
    }
  }

  // Update task method
  void _updateTask(Task updatedTask) {
    int index = tasks.indexWhere((task) => task == updatedTask);
    if (index != -1) {
      setState(() {
        tasks[index] = updatedTask;
      });

      DatabaseServices.updateTask(updatedTask.taskId, updatedTask.taskName,
          updatedTask.completed, updatedTask.taskInfo);
    }
  }

  // Complete task method
  void _toggleTaskCompletion(int index, bool? value) {
    if (value != null) {
      Task updatedTask = tasks[index];
      updatedTask.completed = value;
      _updateTask(updatedTask);
    }
  }

  // Redirects user to a task's task details page
  void _navigateToTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: task,
          onUpdate: (Task updatedTask) {
            _updateTask(updatedTask);
          },
          onDelete: (Task deletedTask) {
            _deleteTask(deletedTask);
          },
        ),
      ),
    );
  }

  // Redirects user to a new task page
  void _navigateToNewTaskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTask(
          onSave: (Task newTask) {
            _addTask(newTask);
          },
        ),
      ),
    );
  }

  // Add task method
  void _addTask(Task newTask) {
    print('Adding task: ${newTask.taskName}');
    setState(() {
      tasks.add(newTask);
    });
  }

  // Delete task method
  void _deleteTask(Task task) async {
    setState(() {
      tasks.remove(task);
    });
    await DatabaseServices.deleteTask(task.taskId);
  }

  // Sign-out method
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
