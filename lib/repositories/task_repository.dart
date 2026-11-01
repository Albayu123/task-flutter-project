import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final CollectionReference? _customCollection;

  TaskRepository({CollectionReference? collection})
      : _customCollection = collection;

  CollectionReference get _tasksCollection =>
      _customCollection ?? FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getTasksStream() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
    });
  }

  Future<void> addTask({
    required String title,
    required String detail,
    String priority = 'medium',
    String category = 'Umum',
  }) async {
    final task = Task(
      id: '',
      title: title,
      detail: detail,
      isCompleted: false,
      priority: priority,
      category: category,
    );
    await _tasksCollection.add(task.toMap());
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String detail,
    String? priority,
    String? category,
    bool? isCompleted,
  }) async {
    final updateData = <String, dynamic>{
      'title': title,
      'detail': detail,
    };
    if (priority != null) updateData['priority'] = priority;
    if (category != null) updateData['category'] = category;
    if (isCompleted != null) updateData['isCompleted'] = isCompleted;

    await _tasksCollection.doc(id).update(updateData);
  }

  Future<void> toggleTaskCompletion(String id, bool currentStatus) async {
    await _tasksCollection.doc(id).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }

  Future<void> restoreTask(Task task) async {
    // If restoring a deleted task, save it back with its previous ID or new doc
    if (task.id.isNotEmpty) {
      await _tasksCollection.doc(task.id).set(task.toMap());
    } else {
      await _tasksCollection.add(task.toMap());
    }
  }
}
