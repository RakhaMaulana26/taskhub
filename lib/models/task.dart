import 'task_status.dart';

class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final TaskStatus status;
  final int progress;
  final String category;
  final bool isImportant;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    this.progress = 0,
    this.category = '',
    this.isImportant = false,
  });
}
