class Todo {
  final int? id;
  final String title;
  final String category;    // from fixed category dropdown
  final DateTime? deadline; // DateTime
  final DateTime? notification; // DateTime
  final String? description;
  final bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.category,
    this.deadline,
    this.notification,
    this.description,
    this.isDone = false,
  });

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline?.toIso8601String(), // Store as ISO8601 string
      'notification': notification?.millisecondsSinceEpoch, // Store as timestamp
      'description': description,
      'isDone': isDone ? 1 : 0,
    };
  }

  // Create Todo from database map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      notification: map['notification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['notification'])
          : null,
      description: map['description'],
      isDone: map['isDone'] == 1,
    );
  }

  // Create a copy with updated values
  Todo copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? deadline,
    DateTime? notification,
    String? description,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      notification: notification ?? this.notification,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  // Helper method to check if task is overdue
  bool get isOverdue {
    if (deadline == null) return false;
    return !isDone && deadline!.isBefore(DateTime.now());
  }

  // Helper method to get formatted deadline string
  String? get formattedDeadline {
    if (deadline == null) return null;
    return '${deadline!.day}/${deadline!.month}/${deadline!.year}';
  }
}