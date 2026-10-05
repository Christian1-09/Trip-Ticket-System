// features/instructor/presentation/widgets/home_stats_card.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// Standalone navy card with Total / Pending / On Trip, placed just below
/// the header with a small gap.
class HomeStatsCard extends StatelessWidget {
  final int total;
  final int pending;
  final int onTrip;

  static const double height = 96;

  const HomeStatsCard({
    super.key,
    required this.total,
    required this.pending,
    required this.onTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E2A8C), AppColors.homeNavyDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeNavyDark.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              icon: Icons.flight_rounded,
              iconColors: const [Color(0xFF5AA9FF), AppColors.homeIconBlue],
              label: 'TOTAL TRIPS',
              value: '$total',
              subtitle: 'All time',
              subtitleColor: Colors.white70,
            ),
          ),
          const _Divider(),
          Expanded(
            child: _StatCell(
              icon: Icons.schedule_rounded,
              iconColors: const [Color(0xFFFFD95A), Color(0xFFF5A623)],
              label: 'PENDING',
              value: '$pending',
              subtitle:
              pending > 0 ? 'Requires your action' : 'Nothing waiting',
              subtitleColor: Colors.white70,
            ),
          ),
          const _Divider(),
          Expanded(
            child: _StatCell(
              icon: Icons.check_rounded,
              iconColors: const [Color(0xFF4ADE80), Color(0xFF16A34A)],
              label: 'ON TRIP',
              value: '$onTrip',
              subtitle: onTrip > 0 ? 'On the road now' : 'All caught up!',
              subtitleColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final List<Color> iconColors;
  final String label;
  final String value;
  final String subtitle;
  final Color subtitleColor;

  const _StatCell({
    required this.icon,
    required this.iconColors,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconColors,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColors.last.withOpacity(0.45),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 9,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.18),
    );
  }
}