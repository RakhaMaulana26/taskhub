import 'package:flutter/material.dart';
import '../models/task_period.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/data/db/todo_database.dart';
import 'package:taskhub/data/models/todo.dart';

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
  List<Todo> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final allTodos = await TodoDatabase.instance.readAllTodos();
    final tasks = allTodos.where((t) => t.deadline != null && !t.deadline!.isBefore(widget.period.startDate) && !t.deadline!.isAfter(widget.period.endDate)).toList();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const Center(child: Text('Tidak ada tugas pada periode ini'))
                      : ListView.builder(
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

  Widget _buildTaskItem(Todo task) {
    final dayName = _getDayName(task.deadline!.weekday);
    final dateFormat = "${task.deadline!.hour}:${task.deadline!.minute.toString().padLeft(2, '0')}, $dayName, ${task.deadline!.day} ${_getMonthName(task.deadline!.month)} ${task.deadline!.year}";
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
            _buildStatusBadge(task),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Todo task) {
    String text;
    Color backgroundColor;
    if (task.isDone && task.deadline != null && task.deadline!.isAfter(DateTime.now())) {
      text = 'Selesai';
      backgroundColor = AppColors.primary;
    } else if (task.isDone && task.deadline != null && task.deadline!.isBefore(DateTime.now())) {
      text = 'Selesai Terlambat';
      backgroundColor = Colors.yellow;
    } else if (!task.isDone && task.deadline != null && task.deadline!.isBefore(DateTime.now())) {
      text = 'Terlambat';
      backgroundColor = Colors.red;
    } else if (!task.isDone) {
      text = 'Belum Selesai';
      backgroundColor = Colors.transparent;
    } else {
      text = 'Tidak diketahui';
      backgroundColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: text == 'Belum Selesai' ? Border.all(color: Colors.grey) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: text == 'Belum Selesai' ? Colors.grey : Colors.white,
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
