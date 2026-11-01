import 'package:flutter_test/flutter_test.dart';
import 'package:task_flutter_project/models/task_model.dart';
import 'package:task_flutter_project/repositories/task_repository.dart';
import 'package:task_flutter_project/viewmodels/task_viewmodel.dart';

class FakeTaskRepository extends TaskRepository {
  final List<Task> _tasks = [];

  @override
  Stream<List<Task>> getTasksStream() {
    return Stream.value(_tasks);
  }

  @override
  Future<void> addTask({
    required String title,
    required String detail,
    String priority = 'medium',
    String category = 'Umum',
  }) async {
    _tasks.add(Task(
      id: '${_tasks.length + 1}',
      title: title,
      detail: detail,
      priority: priority,
      category: category,
    ));
  }
}

void main() {
  group('TaskModel and TaskViewModel Tests', () {
    test('Task model defaults work correctly', () {
      final task = Task(id: '1', title: 'Belajar Flutter', detail: 'Desain UI UX');
      expect(task.isCompleted, false);
      expect(task.priority, 'medium');
      expect(task.category, 'Umum');
    });

    test('TaskViewModel filters work correctly', () {
      final fakeRepo = FakeTaskRepository();
      final vm = TaskViewModel(repository: fakeRepo);
      final tasks = [
        Task(
          id: '1',
          title: 'Kerja Proyek',
          detail: 'Selesaikan API',
          category: 'Kerja',
          priority: 'high',
          isCompleted: false,
        ),
        Task(
          id: '2',
          title: 'Beli Kopi',
          detail: 'Ke supermarket',
          category: 'Pribadi',
          priority: 'low',
          isCompleted: true,
        ),
      ];

      // Status filter
      vm.setStatusFilter('completed');
      expect(vm.filterTasks(tasks).length, 1);
      expect(vm.filterTasks(tasks).first.title, 'Beli Kopi');

      vm.setStatusFilter('pending');
      expect(vm.filterTasks(tasks).length, 1);
      expect(vm.filterTasks(tasks).first.title, 'Kerja Proyek');

      // Search query
      vm.setStatusFilter('all');
      vm.setSearchQuery('kopi');
      expect(vm.filterTasks(tasks).length, 1);
      expect(vm.filterTasks(tasks).first.id, '2');

      // Category filter
      vm.setSearchQuery('');
      vm.setCategoryFilter('Kerja');
      expect(vm.filterTasks(tasks).length, 1);
      expect(vm.filterTasks(tasks).first.title, 'Kerja Proyek');
    });
  });
}
