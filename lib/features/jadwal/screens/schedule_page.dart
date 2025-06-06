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
  late PageController _monthPageController;
  int _currentPage = 1000;
  int _currentMonthPage = 0;
  late DateTime _currentWeekStart;
  int? _selectedIndex;
  bool _showMonthlyCalendar = false;
  DateTime? _selectedMonthlyDay;
  final DateTime _monthPageReference = DateTime(2000, 1, 1); // anchor untuk PageView bulanan

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _monthPageController = PageController(initialPage: 0);
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
        int monthDiff = (baseDate.year - _monthPageReference.year) * 12 + (baseDate.month - _monthPageReference.month);
        _currentMonthPage = monthDiff;
        _monthPageController.jumpToPage(initialMonthPage + monthDiff);
        _selectedMonthlyDay = baseDate;
      }
      _showMonthlyCalendar = !_showMonthlyCalendar;
    });
  }

  // Hapus indikator bulan/tahun di dalam _buildMonthlyCalendar
  Widget _buildMonthlyCalendar(DateTime referenceDate) {
    int initialMonthPage = 1000;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.widget,
        borderRadius: BorderRadius.circular(3.w),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 2.w),
      child: Column(
        children: [
          // Indikator bulan/tahun DIHAPUS agar hanya pakai yang di Row utama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final weekdaySymbols = DateFormat('E', 'id_ID').dateSymbols.STANDALONEWEEKDAYS;
              final weekday = weekdaySymbols[i == 6 ? 0 : i + 1];
              return Expanded(
                child: Center(
                  child: Text(
                    weekday.substring(0, 3), // Ubah ke 3 huruf
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 32.h,
            child: PageView.builder(
              controller: _monthPageController,
              onPageChanged: (pageIdx) {
                setState(() {
                  _currentMonthPage = pageIdx - initialMonthPage;
                  final monthDate = DateTime(
                    _monthPageReference.year + ((pageIdx - initialMonthPage + _monthPageReference.month - 1) ~/ 12),
                    ((_monthPageReference.month + (pageIdx - initialMonthPage) - 1) % 12) + 1,
                    1,
                  );
                  if (_selectedMonthlyDay != null) {
                    if (_selectedMonthlyDay!.month != monthDate.month || _selectedMonthlyDay!.year != monthDate.year) {
                      _selectedMonthlyDay = null;
                      _selectedIndex = null;
                    } else {
                      int lastDay = DateTime(monthDate.year, monthDate.month + 1, 0).day;
                      int day = _selectedMonthlyDay!.day <= lastDay ? _selectedMonthlyDay!.day : lastDay;
                      _selectedMonthlyDay = DateTime(monthDate.year, monthDate.month, day);
                      _selectedIndex = _selectedMonthlyDay!.weekday - 1;
                    }
                  }
                });
              },
              itemBuilder: (context, pageIdx) {
                final monthDate = DateTime(
                  _monthPageReference.year + ((pageIdx - initialMonthPage + _monthPageReference.month - 1) ~/ 12),
                  ((_monthPageReference.month + (pageIdx - initialMonthPage) - 1) % 12) + 1,
                  1,
                );
                final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
                final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
                final firstDayOfGrid = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
                final lastDayOfGrid = lastDayOfMonth.add(Duration(days: 7 - lastDayOfMonth.weekday));
                final days = <DateTime>[];
                for (DateTime d = firstDayOfGrid; !d.isAfter(lastDayOfGrid); d = d.add(Duration(days: 1))) {
                  days.add(d);
                }
                return GridView.builder(
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
                    final isCurrentMonth = date.month == monthDate.month && date.year == monthDate.year;
                    final isSelected = isCurrentMonth && _selectedMonthlyDay != null && DateUtils.isSameDay(date, _selectedMonthlyDay);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonthlyDay = date;
                          _selectedIndex = date.weekday - 1;
                          // Jangan ubah _currentWeekStart di sini agar anchor scroll tetap stabil
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(0.5.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(2.w),
                          border: isToday
                              ? Border.all(color: AppColors.primary, width: 1)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isCurrentMonth ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.3)),
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
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
            // Indikator bulan/tahun hanya satu, gunakan yang di Row ini
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _showMonthlyCalendar ? _goToPreviousMonth : _goToPreviousWeek,
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
                            DateFormat(
                              'MMMM',
                              'id_ID',
                            ).format(_showMonthlyCalendar
                                ? DateTime(
                                    _monthPageReference.year + ((_currentMonthPage + _monthPageReference.month - 1) ~/ 12),
                                    ((_monthPageReference.month + _currentMonthPage - 1) % 12) + 1,
                                    1)
                                : _currentWeekStart),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy').format(_showMonthlyCalendar
                                ? DateTime(
                                    _monthPageReference.year + ((_currentMonthPage + _monthPageReference.month - 1) ~/ 12),
                                    ((_monthPageReference.month + _currentMonthPage - 1) % 12) + 1,
                                    1)
                                : _currentWeekStart),
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
              crossFadeState: _showMonthlyCalendar
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
              firstChild: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeInOut,
                )),
                child: _buildMonthlyCalendar(_currentWeekStart),
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
                      _selectedIndex = _getTodayIndexInWeek(
                        _currentWeekStart,
                      ); // update: default ke hari ini jika ada
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
                              width: 15.w,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                padding: EdgeInsets.symmetric(vertical: 0.75.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isToday
                                          ? AppColors.primary.withOpacity(0.15)
                                          : AppColors.widget),
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
                                            : (isWeekend
                                                ? Colors.red
                                                : (isToday
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary)),
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
                                            : (isWeekend
                                                ? Colors.red
                                                : (isToday
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary)),
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
    );
  }
}
