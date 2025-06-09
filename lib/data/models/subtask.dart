class Subtask {
  final int? id;
  final int todoId;  // foreign key ke todo
  final String title;
  final bool isDone;

  Subtask({
    this.id,
    required this.todoId,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoId': todoId,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'],
      todoId: map['todoId'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }

  Subtask copyWith({
    int? id,
    int? todoId,
    String? title,
    bool? isDone,
  }) {
    return Subtask(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
