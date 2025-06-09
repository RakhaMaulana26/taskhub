import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:taskhub/config/theme/app_theme.dart';
import 'package:taskhub/features/home/screens/home_screen.dart';
import 'package:taskhub/features/jadwal/screens/schedule_page.dart';
import 'package:taskhub/features/statistik/screens/statistics_screen.dart';
import 'package:taskhub/features/crud/add_task.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterButtonTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan warna dari AppColors
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none, // agar tombol plus tidak terpotong
      children: [
        Container(
          height: 9.h,
          margin: EdgeInsets.only(top: 0), // Hapus margin top agar tidak ada area kosong/hitam di atas navbar
          padding: EdgeInsets.only(bottom: 0.h), // tambah padding bawah
          decoration: BoxDecoration(
            color: AppColors.widget, // Ubah dari AppColors.widget ke transparent agar tidak ada kotak hitam
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _NavBarItem(
                  svgAsset: 'assets/icons/home-simple.svg',
                  label: 'Beranda',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavBarItem(
                  svgAsset: 'assets/icons/calendar.svg',
                  label: 'Jadwal',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _NavBarItem(
                  svgAsset: 'assets/icons/notes.svg',
                  label: 'Tugas',
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _NavBarItem(
                  svgAsset: 'assets/icons/stats-up-square.svg',
                  label: 'Statistik',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -4.h, // pastikan tombol plus tidak terpotong di atas
          child: GestureDetector(
            onTap: onCenterButtonTap,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppColors.primary, // warna primary
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 8.w),
            ),
          ),
        ),
      ],
    );
  }
}

// Tambahkan fungsi utilitas untuk SVG icon dengan ColorFilter
Widget _buildSvgIcon(String assetPath, Color color) {
  return SvgPicture.asset(
    assetPath,
    height: 6.w,
    width: 6.w,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

class _NavBarItem extends StatelessWidget {
  final String svgAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.svgAsset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSvgIcon(
            svgAsset,
            selected ? AppColors.primary : Color(0xFFE0E0E0),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : Color(0xFFE0E0E0),
              fontSize: 9.sp,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

void navigateToNavBarPage(BuildContext context, int idx) {
  if (idx == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } else if (idx == 1) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SchedulePage()),
    );
  } else if (idx == 3) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const StatisticsScreen()),
    );
  }
}

void navigateToAddTaskPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TodoFormPage()),
  );
}
