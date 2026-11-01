import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository;

  TaskViewModel({TaskRepository? repository})
      : _repository = repository ?? TaskRepository();

  // Filter & Search State
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'pending', 'completed'
  String _priorityFilter = 'all'; // 'all', 'high', 'medium', 'low'
  String _categoryFilter = 'all'; // 'all', 'Umum', 'Kerja', 'Pribadi', 'Belajar'

  // Theme Mode State
  ThemeMode _themeMode = ThemeMode.system;

  // Last deleted task for undo
  Task? _lastDeletedTask;

  // Getters
  Stream<List<Task>> get tasksStream => _repository.getTasksStream();
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get categoryFilter => _categoryFilter;
  ThemeMode get themeMode => _themeMode;
  Task? get lastDeletedTask => _lastDeletedTask;

  // Filter Setters
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setPriorityFilter(String filter) {
    _priorityFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(String filter) {
    _categoryFilter = filter;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _statusFilter = 'all';
    _priorityFilter = 'all';
    _categoryFilter = 'all';
    notifyListeners();
  }

  void toggleThemeMode() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  // Filter Tasks list based on current filters
  List<Task> filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDetail = task.detail.toLowerCase().contains(query);
        if (!matchTitle && !matchDetail) return false;
      }

      // 2. Status Filter
      if (_statusFilter == 'pending' && task.isCompleted) return false;
      if (_statusFilter == 'completed' && !task.isCompleted) return false;

      // 3. Priority Filter
      if (_priorityFilter != 'all' && task.priority != _priorityFilter) {
        return false;
      }

      // 4. Category Filter
      if (_categoryFilter != 'all' && task.category != _categoryFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  // Task Actions
  Future<void> addTask({
    required String title,
    required String detail,
    String priority = 'medium',
    String category = 'Umum',
  }) async {
    try {
      await _repository.addTask(
        title: title,
        detail: detail,
        priority: priority,
        category: category,
      );
    } catch (e) {
      debugPrint("Error adding task: $e");
    }
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String detail,
    String? priority,
    String? category,
    bool? isCompleted,
  }) async {
    try {
      await _repository.updateTask(
        id: id,
        title: title,
        detail: detail,
        priority: priority,
        category: category,
        isCompleted: isCompleted,
      );
    } catch (e) {
      debugPrint("Error updating task: $e");
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      await _repository.toggleTaskCompletion(task.id, task.isCompleted);
    } catch (e) {
      debugPrint("Error toggling task completion: $e");
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      _lastDeletedTask = task;
      await _repository.deleteTask(task.id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTask == null) return;
    try {
      final taskToRestore = _lastDeletedTask!;
      _lastDeletedTask = null;
      await _repository.restoreTask(taskToRestore);
      notifyListeners();
    } catch (e) {
      debugPrint("Error restoring task: $e");
    }
  }
}
