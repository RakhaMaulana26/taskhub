// lib/schedule_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/features/navbar/bottom_navbar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late PageController _pageController;
  late PageController _monthPageController;
  int _currentPage = 1000;
  int _currentMonthPage = 0;
  late DateTime _currentWeekStart;
  int? _selectedIndex;
  bool _showMonthlyCalendar = false;
  DateTime? _selectedMonthlyDay;
  final DateTime _monthPageReference = DateTime(
    2000,
    1,
    1,
  ); // anchor untuk PageView bulanan
  int _navbarIndex = 1; // Jadwal sebagai default

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _monthPageController = PageController(
      initialPage: 1000,
    ); // perbaiki initialPage ke 1000
    _currentMonthPage = 0;
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    _selectedIndex = _getTodayIndexInWeek(_currentWeekStart);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _monthPageController.dispose();
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
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _goToNextWeek() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // Tambahkan fungsi untuk scroll bulan pada kalender bulanan
  void _goToPreviousMonth() {
    if (_showMonthlyCalendar) {
      _monthPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _goToNextMonth() {
    if (_showMonthlyCalendar) {
      _monthPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  int? _getTodayIndexInWeek(DateTime weekStart) {
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      if (DateUtils.isSameDay(weekStart.add(Duration(days: i)), today)) {
        return i;
      }
    }
    return null;
  }

  void _toggleCalendarView() {
    setState(() {
      if (!_showMonthlyCalendar) {
        DateTime baseDate;
        if (_selectedIndex != null) {
          baseDate = _currentWeekStart.add(Duration(days: _selectedIndex!));
        } else {
          baseDate = DateTime.now();
        }
        int initialMonthPage = 1000;
        int monthDiff =
            (baseDate.year - _monthPageReference.year) * 12 +
            (baseDate.month - _monthPageReference.month);
        _currentMonthPage = monthDiff;
        _monthPageController.jumpToPage(initialMonthPage + monthDiff);
        _selectedMonthlyDay = baseDate;
      }
      _showMonthlyCalendar = !_showMonthlyCalendar;
    });
  }

  // Ubah: _buildMonthlyCalendar hanya tampilkan satu bulan, tanpa PageView
  Widget _buildMonthlyCalendar(DateTime monthDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final firstDayOfGrid = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );
    final lastDayOfGrid = lastDayOfMonth.add(
      Duration(days: 7 - lastDayOfMonth.weekday),
    );
    final days = <DateTime>[];
    for (
      DateTime d = firstDayOfGrid;
      !d.isAfter(lastDayOfGrid);
      d = d.add(Duration(days: 1))
    ) {
      days.add(d);
    }
    final int rowCount = (days.length / 7).ceil();
    final double rowHeight = 6.5.h;
    final double headerHeight = 5.h;
    final double totalHeight = headerHeight + rowCount * rowHeight;
    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        color: AppColors.widget,
        borderRadius: BorderRadius.circular(3.w),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 2.w),
      child: Column(
        children: [
          const MonthlyCalendarHeader(),
          SizedBox(height: 1.h),
          Expanded(
            child: MonthlyCalendarGrid(
              monthDate: monthDate,
              selectedDay: _selectedMonthlyDay,
              onDayTap: (date) {
                setState(() {
                  _selectedMonthlyDay = date;
                  _selectedIndex = date.weekday - 1;
                });
              },
            ),
          ),
        ],
      ),
    );
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Jadwal'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(32),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 2.w,
          right: 2.w, // beri padding bawah agar tidak tertutup navbar
        ),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            // Indikator bulan/tahun hanya satu, gunakan yang di Row ini
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap:
                      _showMonthlyCalendar
                          ? _goToPreviousMonth
                          : _goToPreviousWeek,
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
                  width: 28.w,
                  height: 8.h,
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            DateFormat('MMMM', 'id_ID').format(
                              _showMonthlyCalendar
                                  ? DateTime(
                                    _monthPageReference.year +
                                        ((_currentMonthPage +
                                                _monthPageReference.month -
                                                1) ~/
                                            12),
                                    ((_monthPageReference.month +
                                                _currentMonthPage -
                                                1) %
                                            12) +
                                        1,
                                    1,
                                  )
                                  : _currentWeekStart,
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy').format(
                              _showMonthlyCalendar
                                  ? DateTime(
                                    _monthPageReference.year +
                                        ((_currentMonthPage +
                                                _monthPageReference.month -
                                                1) ~/
                                            12),
                                    ((_monthPageReference.month +
                                                _currentMonthPage -
                                                1) %
                                            12) +
                                        1,
                                    1,
                                  )
                                  : _currentWeekStart,
                            ),
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
                  onTap: _showMonthlyCalendar ? _goToNextMonth : _goToNextWeek,
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
            // Tampilkan hanya satu kalender: mingguan ATAU bulanan
            AnimatedCrossFade(
              duration: Duration(milliseconds: 400),
              crossFadeState:
                  _showMonthlyCalendar
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
              firstChild: SizedBox(
                height: 36.h,
                child: PageView.builder(
                  controller: _monthPageController,
                  onPageChanged: (pageIdx) {
                    setState(() {
                      _currentMonthPage =
                          pageIdx - 1000; // offset dari initialPage
                      final monthDate = DateTime(
                        _monthPageReference.year +
                            (((pageIdx - 1000) +
                                    _monthPageReference.month -
                                    1) ~/
                                12),
                        ((_monthPageReference.month + (pageIdx - 1000) - 1) %
                                12) +
                            1,
                        1,
                      );
                      if (_selectedMonthlyDay != null) {
                        if (_selectedMonthlyDay!.month != monthDate.month ||
                            _selectedMonthlyDay!.year != monthDate.year) {
                          _selectedMonthlyDay = null;
                          _selectedIndex = null;
                        } else {
                          int lastDay =
                              DateTime(
                                monthDate.year,
                                monthDate.month + 1,
                                0,
                              ).day;
                          int day =
                              _selectedMonthlyDay!.day <= lastDay
                                  ? _selectedMonthlyDay!.day
                                  : lastDay;
                          _selectedMonthlyDay = DateTime(
                            monthDate.year,
                            monthDate.month,
                            day,
                          );
                          _selectedIndex = _selectedMonthlyDay!.weekday - 1;
                        }
                      }
                    });
                  },
                  itemBuilder: (context, pageIdx) {
                    final monthOffset = pageIdx - 1000;
                    final monthDate = DateTime(
                      _monthPageReference.year +
                          ((monthOffset + _monthPageReference.month - 1) ~/ 12),
                      ((_monthPageReference.month + monthOffset - 1) % 12) + 1,
                      1,
                    );
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 1.h,
                      ),
                      child: _buildMonthlyCalendar(monthDate),
                    );
                  },
                ),
              ),
              secondChild: SizedBox(
                height: 7.5.h,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                      _currentWeekStart = _getStartOfWeek(
                        DateTime.now(),
                      ).add(Duration(days: 7 * (page - 1000)));
                      _selectedIndex = _getTodayIndexInWeek(_currentWeekStart);
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final weekStart = _getStartOfWeek(
                      DateTime.now(),
                    ).add(Duration(days: 7 * (pageIndex - 1000)));
                    final weekDates = _getWeekDates(weekStart);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(weekDates.length, (index) {
                        final date = weekDates[index];
                        final isToday = DateUtils.isSameDay(
                          date,
                          DateTime.now(),
                        );
                        final isWeekend =
                            date.weekday == DateTime.saturday ||
                            date.weekday == DateTime.sunday;
                        final isSelected =
                            _selectedIndex == index &&
                            _currentPage == pageIndex;
                        return Flexible(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: SizedBox(
                              width: 15.w,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                padding: EdgeInsets.symmetric(vertical: 0.75.h),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : (isToday
                                              ? AppColors.primary.withOpacity(
                                                0.15,
                                              )
                                              : AppColors.widget),
                                  borderRadius: BorderRadius.circular(3.w),
                                  border:
                                      isToday
                                          ? Border.all(
                                            color: AppColors.primary,
                                            width: 1,
                                          )
                                          : (isSelected
                                              ? Border.all(
                                                color: AppColors.primary,
                                                width: 1,
                                              )
                                              : null),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('E', 'id_ID').format(date),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : (isWeekend
                                                    ? Colors.red
                                                    : (isToday
                                                        ? AppColors.primary
                                                        : AppColors
                                                            .textPrimary)),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : (isWeekend
                                                    ? Colors.red
                                                    : (isToday
                                                        ? AppColors.primary
                                                        : AppColors
                                                            .textPrimary)),
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
            ),
            AnimatedRotation(
              turns: _showMonthlyCalendar ? 0.5 : 0.0,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: _toggleCalendarView,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.w),
                    color: Colors.transparent,
                  ),
                  child: SvgPicture.asset(
                    _showMonthlyCalendar
                        ? 'assets/icons/nav-arrow-down.svg'
                        : 'assets/icons/nav-arrow-down.svg',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavBar(
          currentIndex: 1,
          onTap: (idx) {
            navigateToNavBarPage(context, idx);
          },
          onCenterButtonTap: () {
            // TODO: Aksi untuk tombol lingkaran tengah
          },
        ),
      ),
    );
  }
}

// Widget untuk header hari pada kalender bulanan
class MonthlyCalendarHeader extends StatelessWidget {
  const MonthlyCalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final weekdaySymbols =
            DateFormat('E', 'id_ID').dateSymbols.STANDALONEWEEKDAYS;
        final weekday = weekdaySymbols[i == 6 ? 0 : i + 1];
        final isWeekend = (i == 5 || i == 6); // Sabtu/Minggu
        return Expanded(
          child: Center(
            child: Text(
              weekday.substring(0, 3),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
                color: isWeekend ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Widget untuk grid tanggal pada kalender bulanan
class MonthlyCalendarGrid extends StatelessWidget {
  final DateTime monthDate;
  final DateTime? selectedDay;
  final void Function(DateTime) onDayTap;

  const MonthlyCalendarGrid({
    super.key,
    required this.monthDate,
    required this.selectedDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    final firstDayOfGrid = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );
    final lastDayOfGrid = lastDayOfMonth.add(
      Duration(days: 7 - lastDayOfMonth.weekday),
    );
    final days = <DateTime>[];
    for (
      DateTime d = firstDayOfGrid;
      !d.isAfter(lastDayOfGrid);
      d = d.add(Duration(days: 1))
    ) {
      days.add(d);
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final isToday = DateUtils.isSameDay(date, DateTime.now());
        final isCurrentMonth =
            date.month == monthDate.month && date.year == monthDate.year;
        final isSelected =
            isCurrentMonth &&
            selectedDay != null &&
            DateUtils.isSameDay(date, selectedDay);
        final isWeekend =
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        Color textColor;
        if (!isCurrentMonth) {
          textColor = AppColors.textPrimary.withOpacity(0.3);
        } else if (isSelected) {
          textColor = Colors.white;
        } else if (isWeekend) {
          textColor = Colors.red;
        } else {
          textColor = AppColors.textPrimary;
        }
        return GestureDetector(
          onTap: () => onDayTap(date),
          child: Container(
            margin: EdgeInsets.all(0.5.w),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary
                      : isToday
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(2.w),
              border:
                  isToday
                      ? Border.all(color: AppColors.primary, width: 1)
                      : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
