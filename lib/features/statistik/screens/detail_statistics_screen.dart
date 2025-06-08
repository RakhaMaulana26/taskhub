import 'package:flutter/material.dart';
import '../models/task_period.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import 'package:taskhub/config/theme/app_theme.dart';

class DetailStatisticsScreen extends StatefulWidget {
  final TaskPeriod period;

  const DetailStatisticsScreen({
    super.key,
    required this.period,
  });

  @override
  State<DetailStatisticsScreen> createState() => _DetailStatisticsScreenState();
}

class _DetailStatisticsScreenState extends State<DetailStatisticsScreen> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    // In a real app, you would fetch tasks from a database or API
    _tasks = [
      Task(
        id: '1',
        title: 'Tugas Basis Data',
        dueDate: DateTime(2025, 4, 27, 23, 59),
        status: TaskStatus.completed,
      ),
      Task(
        id: '2',
        title: 'Tugas Basis Data',
        dueDate: DateTime(2025, 4, 27, 23, 59),
        status: TaskStatus.completed,
      ),
      Task(
        id: '3',
        title: 'Tugas Basis Data',
        dueDate: DateTime(2025, 4, 27, 23, 59),
        status: TaskStatus.completedLate,
      ),
      Task(
        id: '4',
        title: 'Tugas Basis Data',
        dueDate: DateTime(2025, 4, 27, 23, 59),
        status: TaskStatus.notCompleted,
      ),
      Task(
        id: '5',
        title: 'Tugas Basis Data',
        dueDate: DateTime(2025, 4, 27, 23, 59),
        status: TaskStatus.notCompleted,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = "${widget.period.startDate.day} ${_getMonthName(widget.period.startDate.month)} - ${widget.period.endDate.day} ${_getMonthName(widget.period.endDate.month)} ${widget.period.endDate.year}";

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF),),
                  ),
                  const SizedBox(width: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Tugas Selesai',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return _buildTaskItem(task);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final dayName = _getDayName(task.dueDate.weekday);
    final dateFormat = "${task.dueDate.hour}:${task.dueDate.minute.toString().padLeft(2, '0')}, $dayName, ${task.dueDate.day} ${_getMonthName(task.dueDate.month)} ${task.dueDate.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.widget,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(task.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TaskStatus status) {
    String text;
    Color backgroundColor;

    switch (status) {
      case TaskStatus.completed:
        text = 'Selesai';
        backgroundColor = AppColors.primary;
        break;
      case TaskStatus.completedLate:
        text = 'Selesai Terlambat';
        backgroundColor = AppColors.primary;
        break;
      case TaskStatus.notCompleted:
        text = 'Belum Selesai';
        backgroundColor = Colors.transparent;
        break;
      case TaskStatus.inProgress:
        text = 'Sedang Berlangsung';
        backgroundColor = Colors.orange;
        break;
      case TaskStatus.notStarted:
        text = 'Belum Dimulai';
        backgroundColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: status == TaskStatus.notCompleted
            ? Border.all(color: Colors.grey)
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: status == TaskStatus.notCompleted
              ? Colors.grey
              : Colors.white,
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[weekday - 1];
  }
}
