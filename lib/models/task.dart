class Task {
  final int id;
  final int user;
  final String title;
  final String? description;
  final String category;
  final DateTime dueAt;
  final String priority;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastEscalatedAt;

  Task({
    required this.id,
    required this.user,
    required this.title,
    this.description,
    required this.category,
    required this.dueAt,
    required this.priority,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.lastEscalatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      user: json['user'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: (json['category'] as String?) ?? 'General',
      dueAt: DateTime.parse(json['due_at'] as String),
      priority: json['priority'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastEscalatedAt: json['last_escalated_at'] != null
          ? DateTime.parse(json['last_escalated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'due_at': dueAt.toIso8601String(),
      'priority': priority,
      'completed': completed,
    };
  }

  Task copyWith({
    int? id,
    int? user,
    String? title,
    String? description,
    String? category,
    DateTime? dueAt,
    String? priority,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastEscalatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      user: user ?? this.user,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueAt: dueAt ?? this.dueAt,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastEscalatedAt: lastEscalatedAt ?? this.lastEscalatedAt,
    );
  }
}