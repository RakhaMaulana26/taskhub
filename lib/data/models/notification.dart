class NotificationModel {
  final int? id;
  final int todoId;          // Foreign key referencing the Todo item
  final DateTime scheduledTime;  // Renamed from timestamp for clarity
  final bool isSent;

  NotificationModel({
    this.id,
    required this.todoId,
    required this.scheduledTime,
    this.isSent = false,
  });

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoId': todoId,
      'timestamp': scheduledTime.millisecondsSinceEpoch, // Store as timestamp
      'isSent': isSent ? 1 : 0,
    };
  }

  // Create from database map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      todoId: map['todoId'],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isSent: map['isSent'] == 1,
    );
  }

  // Create a modified copy
  NotificationModel copyWith({
    int? id,
    int? todoId,
    DateTime? scheduledTime,
    bool? isSent,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isSent: isSent ?? this.isSent,
    );
  }

  // Helper to check if notification should be triggered
  bool shouldTriggerNow() {
    return !isSent && scheduledTime.isBefore(DateTime.now());
  }

  // Formatted time for display
  String get formattedTime {
    return '${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}';
  }

  // Formatted date for display
  String get formattedDate {
    return '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year}';
  }

}