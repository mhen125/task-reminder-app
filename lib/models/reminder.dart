class Reminder {
  final String id;
  final String title;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // When you later use Firestore, these will be handy:

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}