class Todo {
  final int? id;
  final String title;       // max 20 char, validasi di UI
  final String category;    // dari dropdown kategori fixed
  final int? deadline;      // timestamp Unix (milliseconds)
  final int? notification;  // timestamp Unix (milliseconds)
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline,
      'notification': notification,
      'description': description,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline: map['deadline'],
      notification: map['notification'],
      description: map['description'],
      isDone: map['isDone'] == 1,
    );
  }

  Todo copyWith({
    int? id,
    String? title,
    String? category,
    int? deadline,
    int? notification,
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
}
