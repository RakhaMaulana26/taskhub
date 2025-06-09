import 'package:flutter/material.dart';
import '../widgets/task_progress_chart.dart';
import '../widgets/period_filter.dart';
import '../models/task_period.dart';
import '../models/task_status.dart';
import 'detail_statistics_screen.dart';
import 'package:taskhub/features/navbar/bottom_navbar.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/data/db/todo_database.dart';
import 'package:taskhub/data/models/todo.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.weekly;
  List<TaskPeriod> _periods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    setState(() { _isLoading = true; });
    final now = DateTime.now();
    List<TaskPeriod> periods = [];
    if (_selectedPeriod == PeriodFilter.weekly) {
      periods = await _getWeeklyPeriods(now.year, now.month);
    } else if (_selectedPeriod == PeriodFilter.monthly) {
      periods = await _getMonthlyPeriods(now.year);
    }
    // Filter hanya yang ada datanya
    periods = periods.where((p) => p.totalTasks > 0).toList();
    // Urutkan dari yang paling baru ke paling lama
    periods.sort((a, b) => b.endDate.compareTo(a.endDate));
    setState(() {
      _periods = periods;
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
        title: const Text('Statistik', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PeriodFilterWidget(
                selectedFilter: _selectedPeriod,
                onFilterChanged: (filter) {
                  setState(() { _selectedPeriod = filter; });
                  _loadPeriods();
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _periods.isEmpty
                      ? const Center(child: Text('Tidak ada data statistik'))
                      : ListView.builder(
                          itemCount: _periods.length,
                          itemBuilder: (context, index) {
                            final period = _periods[index];
                            return _buildPeriodStatistics(context, period, theme);
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavBar(
          currentIndex: 3,
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

  // --- Statistik Periodik ---
  Future<List<TaskPeriod>> _getWeeklyPeriods(int year, int month) async {
    final todos = await TodoDatabase.instance.readAllTodos();
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    List<TaskPeriod> periods = [];
    DateTime weekStart = firstDay.subtract(Duration(days: firstDay.weekday - DateTime.monday));
    while (weekStart.isBefore(lastDay)) {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekTodos = todos.where((t) => t.deadline != null && !t.deadline!.isBefore(weekStart) && !t.deadline!.isAfter(weekEnd)).toList();
      periods.add(_buildTaskPeriod(weekStart, weekEnd, weekTodos));
      weekStart = weekStart.add(const Duration(days: 7));
    }
    return periods;
  }

  Future<List<TaskPeriod>> _getMonthlyPeriods(int year) async {
    final todos = await TodoDatabase.instance.readAllTodos();
    List<TaskPeriod> periods = [];
    for (int m = 1; m <= 12; m++) {
      final firstDay = DateTime(year, m, 1);
      final lastDay = DateTime(year, m + 1, 0);
      final monthTodos = todos.where((t) => t.deadline != null && !t.deadline!.isBefore(firstDay) && !t.deadline!.isAfter(lastDay)).toList();
      periods.add(_buildTaskPeriod(firstDay, lastDay, monthTodos));
    }
    return periods;
  }

  TaskPeriod _buildTaskPeriod(DateTime start, DateTime end, List<Todo> todos) {
    final total = todos.length;
    int onTime = 0, late = 0, overdue = 0, notCompleted = 0;
    final now = DateTime.now();
    for (final t in todos) {
      // Penyesuaian: asumsikan tidak ada completedAt, jadi hanya pakai isDone dan deadline
      if (t.isDone && t.deadline != null && t.deadline!.isAfter(now)) {
        onTime++;
      } else if (t.isDone && t.deadline != null && t.deadline!.isBefore(now)) {
        late++;
      } else if (!t.isDone && t.deadline != null && t.deadline!.isBefore(now)) {
        overdue++;
      } else if (!t.isDone) {
        notCompleted++;
      }
    }
    return TaskPeriod(
      startDate: start,
      endDate: end,
      totalTasks: total,
      onTimePercentage: total == 0 ? 0 : ((onTime / total) * 100).round(),
      latePercentage: total == 0 ? 0 : ((late / total) * 100).round(),
      overduePercentage: total == 0 ? 0 : ((overdue / total) * 100).round(),
      notCompletedPercentage: total == 0 ? 0 : ((notCompleted / total) * 100).round(),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }

  Widget _buildStatusIndicator(String percentage, String label, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              percentage,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodStatistics(
    BuildContext context,
    TaskPeriod period,
    ThemeData theme,
  ) {
    final dateFormat =
        "${period.startDate.day} ${_getMonthName(period.startDate.month)} - ${period.endDate.day} ${_getMonthName(period.endDate.month)} ${period.endDate.year}";
    return Padding(
      padding: const EdgeInsets.only(top: 12, right: 16, left: 16, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.widget,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overview Tugas Selesai',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DetailStatisticsScreen(period: period),
                      ),
                    );
                  },
                  child: Text(
                    'Details',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              dateFormat,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: TaskProgressChart(
                    onTimePercentage: period.onTimePercentage,
                    latePercentage: period.latePercentage,
                    overduePercentage: period.overduePercentage,
                    notCompletedPercentage: period.notCompletedPercentage,
                    totalTasks: period.totalTasks,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusIndicator(
                        '${period.onTimePercentage}%',
                        'Selesai',
                        AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusIndicator(
                        '${period.latePercentage}%',
                        'Selesai Terlambat',
                        Colors.yellow,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusIndicator(
                        '${period.overduePercentage}%',
                        'Terlambat',
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusIndicator(
                        '${period.notCompletedPercentage}%',
                        'Belum Selesai',
                        Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
