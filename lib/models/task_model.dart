import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String detail;

  Task({
    required this.id,
    required this.title,
    required this.detail,
  });

  factory Task.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      detail: data['detail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'detail': detail,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}