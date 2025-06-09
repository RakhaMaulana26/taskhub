class TaskPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTasks;
  final int onTimePercentage;
  final int latePercentage;
  final int overduePercentage;
  final int notCompletedPercentage;

  TaskPeriod({
    required this.startDate,
    required this.endDate,
    required this.totalTasks,
    required this.onTimePercentage,
    required this.latePercentage,
    required this.overduePercentage,
    required this.notCompletedPercentage,
  });
}