import 'package:flutter/material.dart';
import '../widgets/task_progress_chart.dart';
import '../widgets/period_filter.dart';
import '../models/task_period.dart';
import '../models/task_status.dart';
import 'detail_statistics_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.weekly;

  final List<TaskPeriod> _periods = [
    TaskPeriod(
      startDate: DateTime(2025, 4, 1),
      endDate: DateTime(2025, 4, 30),
      totalTasks: 50,
      onTimePercentage: 50,
      latePercentage: 25,
      notCompletedPercentage: 25,
    ),
    TaskPeriod(
      startDate: DateTime(2025, 3, 1),
      endDate: DateTime(2025, 3, 31),
      totalTasks: 50,
      onTimePercentage: 50,
      latePercentage: 25,
      notCompletedPercentage: 25,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back),
                  const SizedBox(width: 16),
                  const Text(
                    'Statistik',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PeriodFilterWidget(
                selectedFilter: _selectedPeriod,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedPeriod = filter;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _periods.length,
                itemBuilder: (context, index) {
                  final period = _periods[index];
                  return _buildPeriodStatistics(context, period);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodStatistics(BuildContext context, TaskPeriod period) {
    final dateFormat = "${period.startDate.day} ${_getMonthName(period.startDate.month)} - ${period.endDate.day} ${_getMonthName(period.endDate.month)} ${period.endDate.year}";
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                        builder: (context) => DetailStatisticsScreen(period: period),
                      ),
                    );
                  },
                  child: const Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.blue,
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
                color: Colors.grey[400],
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
                        'Diselesaikan tepat waktu',
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusIndicator(
                        '${period.latePercentage}%',
                        'Diselesaikan terlambat',
                        Colors.cyan,
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

  Widget _buildStatusIndicator(String percentage, String label, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              percentage,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
