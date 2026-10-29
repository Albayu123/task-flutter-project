import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  Stream<List<Task>> get tasksStream => _repository.getTasksStream();

  Future<void> addTask(String title, String detail) async {
    try {
      await _repository.addTask(title, detail);
    } catch (e) {
      debugPrint("Error adding task: $e");
    }
  }

  Future<void> updateTask(String id, String title, String detail) async {
    try {
      await _repository.updateTask(id, title, detail);
    } catch (e) {
      debugPrint("Error updating task: $e");
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }
}