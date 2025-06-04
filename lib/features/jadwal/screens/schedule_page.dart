// lib/schedule_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late PageController _pageController;
  int _currentPage = 1000; // page tengah, agar bisa swipe ke kiri/kanan tanpa batas
  late DateTime _currentWeekStart;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _currentWeekStart = _getStartOfWeek(DateTime.now());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Pastikan selalu mulai dari Senin
    int daysToSubtract = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  List<DateTime> _getWeekDates(DateTime startOfWeek) {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _goToPreviousWeek() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _goToNextWeek() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 10.h,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5.w, // Contoh: 5% dari lebar layar
          ).copyWith(
            top:
                3.h, // Contoh: 3% dari tinggi layar (untuk penyesuaian vertikal)
            bottom: 1.h,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment
                      .center, // Pusatkan konten kolom di area yang tersedia
              children: <Widget>[
                Text(
                  'Jadwal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22.sp, // Contoh: font size responsif
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h), // Contoh: 0.5% dari tinggi layar
                Text(
                  formattedDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    fontSize: 12.sp, // Contoh: font size responsif
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(2.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _goToPreviousWeek,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.w),
                      color: AppColors.widget,
                    ),
                    child: SvgPicture.asset('assets/icons/nav-arrow-left.svg'),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 25.w,
                  height: 8.h,
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            DateFormat('MMMM', 'id_ID').format(_currentWeekStart),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy').format(_currentWeekStart),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: _goToNextWeek,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.w),
                      color: AppColors.widget,
                    ),
                    child: SvgPicture.asset('assets/icons/nav-arrow-right.svg'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 7.5.h,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _currentWeekStart = _getStartOfWeek(DateTime.now()).add(Duration(days: 7 * (page - 1000)));
                    _selectedIndex = null; // reset selection saat ganti minggu
                  });
                },
                itemBuilder: (context, pageIndex) {
                  final weekStart = _getStartOfWeek(DateTime.now()).add(Duration(days: 7 * (pageIndex - 1000)));
                  final weekDates = _getWeekDates(weekStart);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(weekDates.length, (index) {
                      final date = weekDates[index];
                      final isToday = DateUtils.isSameDay(date, DateTime.now());
                      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                      final isSelected = _selectedIndex == index && _currentPage == pageIndex;
                      return Flexible(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: SizedBox(
                            width: 15.w, // atur lebar agar tidak overflow
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.w),
                              padding: EdgeInsets.symmetric(vertical: 0.75.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isToday ? AppColors.primary.withOpacity(0.15) : AppColors.widget),
                                borderRadius: BorderRadius.circular(3.w),
                                border: isToday
                                    ? Border.all(color: AppColors.primary, width: 1)
                                    : (isSelected
                                        ? Border.all(color: AppColors.primary, width: 1)
                                        : null),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('E', 'id_ID').format(date),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isWeekend ? Colors.red : (isToday ? AppColors.primary : AppColors.textPrimary)),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isWeekend ? Colors.red : (isToday ? AppColors.primary : AppColors.textPrimary)),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
