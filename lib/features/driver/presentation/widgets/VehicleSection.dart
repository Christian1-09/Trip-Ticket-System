import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../widgets/common.dart';

class VehicleSection extends StatelessWidget {
  const VehicleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.directions_car_filled_outlined,
            iconColor: AppColors.accentYellow,
            title: 'Assigned Vehicle',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardDeepBlue),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.textSecondary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SJJ 963 INNOVA',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '48 km covered',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 8),
                    const StatusBadge(text: 'Available', color: AppColors.statusBlue, withDot: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: StatItem(
                  value: '12:2 L',
                  label: 'FUEL USED',
                  color: AppColors.accentYellow,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: StatItem(
                  value: '23,231',
                  label: 'ODOMETER',
                  color: AppColors.accentYellow,
                ),
              ),
              Expanded(
                child: StatItem(
                  value: '48 kM',
                  label: 'DISTANCE',
                  color: AppColors.textPrimary,
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}