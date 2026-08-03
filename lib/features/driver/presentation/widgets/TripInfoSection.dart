import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../widgets/common.dart';

class TripInfoSection extends StatelessWidget {
  const TripInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.description_outlined,
            iconColor: AppColors.statusCard,
            title: 'Trip Information',
            trailing: StatusBadge(text: 'COMPLETE', color: AppColors.statusGreen, withDot: true),
          ),
          const SizedBox(height: 18),
          const _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'DATE OF TRAVEL',
            value: 'Monday, September 23, 2025',
          ),
          const SizedBox(height: 16),
          const _InfoRow(
            icon: Icons.access_time,
            label: 'TRIP TIME',
            value: '1:00 PM - 3:30 PM',
            subValue: 'Departure from Garage: 12:30 PM',
          ),
          const SizedBox(height: 16),
          const _InfoRow(
            icon: Icons.edit_note,
            label: 'PURPOSE',
            value: 'Official Business Meeting',
            subValue: 'Q3 Budget Review & Planning Session',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _InfoRow(
                  icon: Icons.event_note_outlined,
                  label: 'TRIP TYPE',
                  value: 'Scheduled Trip',
                ),
              ),
              const StatusBadge(text: 'Official', color: AppColors.statusBlue),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.statusBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subValue!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}