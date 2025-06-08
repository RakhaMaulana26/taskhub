import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:taskhub/config/theme/app_theme.dart';

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
          margin: EdgeInsets.only(top: 7.w), // beri ruang di atas agar tombol plus tidak terpotong
          padding: EdgeInsets.only(bottom: 1.h), // tambah padding bawah
          decoration: BoxDecoration(
            color: AppColors.widget, // background widget
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _NavBarItem(
                  svgAsset: 'assets/icons/home-simple.svg',
                  label: 'Home',
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
          top: -1.h, // pastikan tombol plus tidak terpotong di atas
          child: GestureDetector(
            onTap: onCenterButtonTap,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppColors.primary, // warna primary
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
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
    height: 7.w,
    width: 7.w,
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
