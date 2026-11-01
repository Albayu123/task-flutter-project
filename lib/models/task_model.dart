import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String detail;
  final bool isCompleted;
  final String priority; // 'low', 'medium', 'high'
  final String category; // 'Umum', 'Kerja', 'Pribadi', 'Belajar'
  final DateTime? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.detail,
    this.isCompleted = false,
    this.priority = 'medium',
    this.category = 'Umum',
    this.createdAt,
  });

  factory Task.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime? created;
    if (data['createdAt'] is Timestamp) {
      created = (data['createdAt'] as Timestamp).toDate();
    }

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      detail: data['detail'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 'medium',
      category: data['category'] ?? 'Umum',
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'detail': detail,
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? detail,
    bool? isCompleted,
    String? priority,
    String? category,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
