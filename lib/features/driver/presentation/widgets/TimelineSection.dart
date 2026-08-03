import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../widgets/common.dart';

class TimelineEvent {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const TimelineEvent({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class TimelineSection extends StatelessWidget {
  const TimelineSection({super.key});

  static const List<TimelineEvent> _events = [
    TimelineEvent(
      time: '12:45 PM',
      title: 'Driver dispatched from garage',
      subtitle: 'SJJ 963 Innova • Odometer: 32,424km',
      icon: Icons.check,
      color: AppColors.statusGreen,
    ),
    TimelineEvent(
      time: '12:45 PM',
      title: 'Passenger picked up',
      subtitle: 'City Hall - Main Building',
      icon: Icons.person_outline,
      color: AppColors.statusBlue,
    ),
    TimelineEvent(
      time: '12:45 PM',
      title: 'Arrived at destination',
      subtitle: 'Regional Government Center',
      icon: Icons.location_on_outlined,
      color: AppColors.accentYellow,
    ),
    TimelineEvent(
      time: '12:45 PM',
      title: 'Trip completed & returned',
      subtitle: 'Back to garage • Odometer: 32,432km',
      icon: Icons.sync,
      color: AppColors.accentYellow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.show_chart,
            iconColor: AppColors.statusBlue,
            title: 'Trip Timeline',
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _events.length; i++)
            _TimelineTile(
              event: _events[i],
              isLast: i == _events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _TimelineTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(event.icon, color: event.color, size: 15),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.cardDeepBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.time,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}