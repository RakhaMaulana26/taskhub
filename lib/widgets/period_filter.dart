import 'package:flutter/material.dart';

enum PeriodFilter {
  thisWeek,
  weekly,
  monthly,
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
          'Minggu ini',
          PeriodFilter.thisWeek,
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          context,
          'Mingguan',
          PeriodFilter.weekly,
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          context,
          'Bulanan',
          PeriodFilter.monthly,
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
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
