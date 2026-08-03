import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../widgets/common.dart';

class TimeStatsSection extends StatelessWidget {
  const TimeStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: const Row(
        children: [
          Expanded(
            child: StatItem(value: '1:00', label: 'DEPARTURE', color: AppColors.accentYellow),
          ),
          Expanded(
            child: StatItem(value: '3:30', label: 'RETURN', color: AppColors.textPrimary),
          ),
          Expanded(
            child: StatItem(value: '2H 30M', label: 'DURATION', color: AppColors.textPrimary),
          ),
          Expanded(
            child: StatItem(value: '48Km', label: 'DISTANCE', color: AppColors.statusCard),
          ),
        ],
      ),
    );
  }
}