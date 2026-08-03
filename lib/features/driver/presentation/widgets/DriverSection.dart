import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../widgets/common.dart';

class DriverSection extends StatelessWidget {
  const DriverSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          const InitialsAvatar(name: 'Steve Baroro', radius: 28, color: AppColors.statusCard),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ASSIGNED DRIVER',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Steve P. Baroro',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '• ID: DRV-2024-012 • 5 yrs exp.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      4,
                          (i) => const Icon(Icons.star, color: AppColors.accentYellow, size: 15),
                    ),
                    const Icon(Icons.star_border, color: AppColors.accentYellow, size: 15),
                    const SizedBox(width: 6),
                    const Text(
                      '(4.9)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}