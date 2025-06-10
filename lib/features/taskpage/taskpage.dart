import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import '../widgets/task_progress_chart.dart';
// import '../widgets/period_filter.dart';
// import '../models/task_period.dart';
// import '../models/task_status.dart';
// import 'detail_statistics_screen.dart';
import 'package:taskhub/features/navbar/bottom_navbar.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/features/taskpage/widgets/period_filter.dart';
import 'package:taskhub/data/models/todo.dart';

import '../../data/db/todo_database.dart';

class TaskScreen extends StatefulWidget {
  // final List<Todo> todos;

  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.all;
  final TextEditingController _searchController = TextEditingController();
  List<Todo> _todayTodos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodosBasedOnFilter(_selectedPeriod);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDeadline(DateTime deadline) {
    return '${deadline.day}/${deadline.month}/${deadline.year}';
  }

  Future<void> _fetchTodosBasedOnFilter(PeriodFilter filter) async {
    setState(() => _isLoading = true);
    final allTodos = await TodoDatabase.instance.readAllTodos();
    final now = DateTime.now();

    List<Todo> filteredTodos = allTodos.where((todo) {
      switch (filter) {
        case PeriodFilter.all:
          return true;
        case PeriodFilter.notDone:
          return !todo.isDone;
        case PeriodFilter.done:
          return todo.isDone;
        case PeriodFilter.late:
          if (todo.isDone) return false;
          if (todo.deadline == null) return false;
          return todo.deadline!.isBefore(now);
      }
    }).toList();

    setState(() {
      _todayTodos = filteredTodos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Tugas',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PeriodFilterWidget(
                  selectedFilter: _selectedPeriod,
                  onFilterChanged: (filter) {
                    setState(() => _selectedPeriod = filter);
                    _fetchTodosBasedOnFilter(filter);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(1.0),
                shadowColor: MaterialStateProperty.all(Colors.transparent),
                surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                controller: _searchController,
                hintText: 'Cari...',
                leading: const Icon(Icons.search, color: Colors.grey),
                trailing: [
                ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: value.text.isNotEmpty
                        ? IconButton(
                      key: const ValueKey('clear'),
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  );
                },
              ),
                ],
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                hintStyle: MaterialStateProperty.all(
                  TextStyle(color: Colors.grey.shade500),
                ),
                onChanged: (value) {
                  // Implement search functionality if needed
                },
                onSubmitted: (query) {
                  debugPrint('Search submitted: $query');
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _todayTodos.isEmpty
                  ? Center(
                child: Text(
                  'Tidak ada tugas',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _todayTodos.length,
                itemBuilder: (context, index) {
                  final todo = _todayTodos[index];
                  return FutureBuilder(
                    future: TodoDatabase.instance.readNotificationsByTodoId(todo.id!),
                    builder: (context, snapshot) {
                      final hasNotif = snapshot.hasData && (snapshot.data as List).isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _TaskCard(
                          todo: todo,
                          theme: theme,
                          hasNotif: hasNotif,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavBar(
          currentIndex: 2,
          onTap: (idx) {
            navigateToNavBarPage(context, idx);
          },
          onCenterButtonTap: () {
            navigateToAddTaskPage(context);
          },
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Todo todo;
  final ThemeData theme;
  final bool hasNotif;

  const _TaskCard({
    required this.todo,
    required this.theme,
    required this.hasNotif,
  });

  String _formatDeadline(DateTime deadline) {
    return '${deadline.day}/${deadline.month}/${deadline.year}';
  }

  @override
  Widget build(BuildContext context) {
    final progress =  0.0; // Nilai default jika progress null

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.widget,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  // Handle toggle
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: todo.isDone ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: todo.isDone ? AppColors.primary : AppColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: todo.isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Deadline
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        todo.deadline != null
                            ? '${todo.deadline!.hour}:${todo.deadline!.minute.toString().padLeft(2, '0')}, ${_formatDeadline(todo.deadline!)}'
                            : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (hasNotif)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}