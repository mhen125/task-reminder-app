import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority {
  low(0, 'Low'),
  medium(1, 'Medium'),
  high(2, 'High'),
  urgent(3, 'Urgent');

  final int value;
  final String label;

  const Priority(this.value, this.label);

  Priority? escalate() {
    if (this == Priority.urgent) return null;
    return Priority.values[value + 1];
  }

  static Priority fromName(String name) {
    return Priority.values.firstWhere(
      (priority) => priority.name == name,
      orElse: () => Priority.medium,
    );
  }
}

enum TaskCategory {
  personal('Personal'),
  work('Work'),
  health('Health'),
  shopping('Shopping'),
  other('Other');

  final String label;

  const TaskCategory(this.label);

  static TaskCategory fromName(String name) {
    return TaskCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => TaskCategory.other,
    );
  }
}

const Object _unset = Object();

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.isDone = false,
    this.completedAt,
  });

  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  bool shouldEscalate(int daysThreshold) {
    if (isDone) return false;
    if (priority == Priority.urgent) return false;
    return daysSinceCreation >= daysThreshold;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    Priority? priority,
    Object? dueDate = _unset,
    bool? isDone,
    Object? completedAt = _unset,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      isDone: isDone ?? this.isDone,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isDone': isDone,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory Task.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    final createdAtValue = data['createdAt'];
    final dueDateValue = data['dueDate'];
    final completedAtValue = data['completedAt'];

    return Task(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      category: TaskCategory.fromName((data['category'] ?? 'other') as String),
      priority: Priority.fromName((data['priority'] ?? 'medium') as String),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      dueDate: dueDateValue is Timestamp ? dueDateValue.toDate() : null,
      isDone: (data['isDone'] ?? false) as bool,
      completedAt:
          completedAtValue is Timestamp ? completedAtValue.toDate() : null,
    );
  }
}