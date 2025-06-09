import 'package:flutter/material.dart';
// import '../widgets/task_progress_chart.dart';
// import '../widgets/period_filter.dart';
// import '../models/task_period.dart';
// import '../models/task_status.dart';
// import 'detail_statistics_screen.dart';
import 'package:taskhub/features/navbar/bottom_navbar.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/features/taskpage/widgets/period_filter.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();

}

class _TaskScreenState extends State<TaskScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.all;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Tugas',
          style: TextStyle(
            color: Colors.white
          ),
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
                    setState(() {
                      _selectedPeriod = filter;
                    });
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
                  // Functionality
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  hintStyle: MaterialStateProperty.all(
                    TextStyle(color: Colors.grey.shade500),
                  ),
                  onChanged: (value) {
                    // Add real-time search logic here if needed
                  },
                  onSubmitted: (query) {
                    debugPrint('Search submitted: $query');
                    // Add search execution logic
                  },
              ),
            )
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
            // TODO: Aksi untuk tombol lingkaran tengah
          },
        ),
      )
    );
  }
}