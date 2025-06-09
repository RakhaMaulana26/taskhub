import 'package:flutter/material.dart';
import 'package:taskhub/config/theme/app_theme.dart';

enum PeriodFilter {
  all,
  notDone,
  done,
  late,
}

class PeriodFilterWidget extends StatelessWidget {
  final PeriodFilter selectedFilter;
  final Function(PeriodFilter) onFilterChanged;

  const PeriodFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterButton(
          context,
          'Semua',
          PeriodFilter.all,
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          context,
          'Belum Selesai',
          PeriodFilter.notDone,
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          context,
          'Selesai',
          PeriodFilter.done,
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          context,
          'Terlambat',
          PeriodFilter.late,
        ),
      ],
    );
  }

  Widget _buildFilterButton(
      BuildContext context,
      String label,
      PeriodFilter filter,
      ) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
