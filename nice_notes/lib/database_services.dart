import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'taskclass.dart';

class DatabaseServices {
  static const String baseUrl =
      'https://us-central1-planar-beach-404723.cloudfunctions.net';

// Function to add a new task
  static Future<void> addTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/taskfunction/tasksApi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Task_ID': task.taskId,
          'Task_Name': task.taskName,
          'Task_Info': task.taskInfo,
          'Completed': task.completed,
          'Unique_User_ID': task.uid,
        }),
      );
      print('Response: ${response.statusCode}');
      if (response.statusCode == 201) {
        // Use the correct status code
        print('Task added successfully');
      } else {
        print('Failed to add task. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to add task');
      }
    } catch (error) {
      print('Error adding task: $error');
    }
  }

// Function to fetch tasks for a specific user
  static Future<List<Task>> getTasks(String uid) async {
    bool convertIntToBool(int value) {
      if (value == 0) {
        return false;
      } else {
        return true;
      }
    }

    try {
      final response = await http.get(
          //Testing
          Uri.parse('$baseUrl/taskfunction/tasksApi/?Unique_User_ID=$uid'),
          headers: {'Content-Type': 'application/json'});
      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        final List<dynamic> taskList = json.decode(response.body);
        return taskList
            .map((taskData) => Task(
                  taskId: taskData['Task_ID'] ?? '',
                  taskName: taskData['Task_Name'] ?? '',
                  taskInfo: taskData['Task_Info'] ?? '',
                  completed: convertIntToBool(taskData['Completed'] ?? 0),
                  timestamp: DateTime.parse(
                      taskData['timestamp'] ?? DateTime.now().toString()),
                  uid: taskData['Unique_User_ID'],
                ))
            .toList();
      } else {
        print('Failed to fetch tasks. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch tasks');
      }
    } catch (error) {
      print('Error fetching tasks: $error');
      rethrow;
    }
  }

  // Function to update an existing task
  static Future<void> updateTask(
      String taskId, String taskName, bool completed, String taskInfo) async {
    try {
      final response = await http.put(
        //Uri.parse('$baseUrl/tasksApi/$taskId'),
        Uri.parse('$baseUrl/taskfunction/tasksApi/?Task_ID=$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Task_Name': taskName,
          'Task_Info': taskInfo,
          'Completed': completed,
          'Task_ID': taskId,
        }),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        print('Update successful!');
        print(taskId);
        print('name below');
        print(taskName);
      }

      if (response.statusCode != 200) {
        print('Failed to update task. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update task');
      }
    } catch (error) {
      print('Error updating task: $error');
      rethrow;
    }
  }

  // Function to delete a task
  static Future<void> deleteTask(String taskId) async {
    try {
      print('testing2: ${taskId}');
      final response = await http.delete(
        Uri.parse('$baseUrl/taskfunction/tasksApi/?Task_ID=$taskId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Delete successful! Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('${response.statusCode}');
      }
    } catch (error) {
      print('Failed to delete task. Status code: $error');
      rethrow;
    }
  }
}
