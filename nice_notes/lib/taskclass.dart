// Task class which holds task properties
class Task {
  String taskId;
  String taskName;
  String taskInfo;
  bool completed;
  DateTime timestamp;
  String uid;

  Task(
      {required this.taskId,
      required this.taskName,
      required this.taskInfo,
      this.completed = false,
      required this.timestamp,
      required this.uid});
}
