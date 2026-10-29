import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getTasksStream() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
    });
  }

  Future<void> addTask(String title, String detail) async {
    final task = Task(id: '', title: title, detail: detail);
    await _tasksCollection.add(task.toMap());
  }

  Future<void> updateTask(String id, String title, String detail) async {
    await _tasksCollection.doc(id).update({
      'title': title,
      'detail': detail,
    });
  }

  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }
}