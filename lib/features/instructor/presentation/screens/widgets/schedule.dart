import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

enum TripStatus { pending, confirmed }

/// Visual config for each [TripStatus] — icon, header label, pill text, and
/// accent color all live here so the whole card look is driven by one enum.
class _StatusStyle {
  final IconData icon;
  final String headerLabel;
  final String pillLabel;
  final Color color;

  const _StatusStyle({
    required this.icon,
    required this.headerLabel,
    required this.pillLabel,
    required this.color,
  });

  static _StatusStyle of(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return _StatusStyle(
          icon: Icons.send_rounded,
          headerLabel: 'SCHEDULE TRIP',
          pillLabel: 'PENDING',
          color: AppColors.accentYellow,
        );
      case TripStatus.confirmed:
        return _StatusStyle(
          icon: Icons.check_rounded,
          headerLabel: 'SCHEDULE TRIP',
          pillLabel: 'CONFIRMED',
          color: AppColors.statusBlue,
        );
    }
  }
}

class ScheduleCard extends StatelessWidget {
  final String name;
  final String plateNumber;
  final String vehicleType;
  final String? imagePath;
  final TripStatus status;
  final String date;
  final String time;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const ScheduleCard({
    super.key,
    required this.name,
    required this.plateNumber,
    required this.vehicleType,
    required this.status,
    this.imagePath,
    this.date = 'Friday SEP 23',
    this.time = '1:00 - 3:30PM',
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _StatusStyle.of(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          border: Border.all(color: AppColors.statusBlue.withOpacity(0.75)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.statusBlue.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // ClipRRect keeps the bottom gradient bar inside the rounded corners.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(style: style),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.statusBlue.withOpacity(0.25),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ──────────────────────────────────────
                    _Avatar(imagePath: imagePath),
                    const SizedBox(width: 12),

                    // ── Date + Name + Plate ─────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.textSecondary,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$plateNumber $vehicleType',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ── Time + Chevron ───────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ChevronButton(onTap: onMoreTap),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Bottom gradient accent bar ───────────────────────
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      style.color.withOpacity(0.4),
                      style.color,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final _StatusStyle style;

  const _CardHeader({required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: style.color.withOpacity(0.6)),
            ),
            child: Icon(style.icon, color: style.color, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            style.headerLabel,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  style.pillLabel,
                  style: TextStyle(
                    color: style.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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

class _Avatar extends StatelessWidget {
  final String? imagePath;

  const _Avatar({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.cardDark,
        border: Border.all(color: AppColors.statusBlue.withOpacity(0.8), width: 1.5),
        image: imagePath != null
            ? DecorationImage(
          image: AssetImage(imagePath!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: imagePath == null
          ? const Icon(Icons.person_rounded, color: Colors.white38, size: 28)
          : null,
    );
  }
}

class _ChevronButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ChevronButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.statusBlue.withOpacity(0.8)),
        ),
        child: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.statusBlue,
          size: 20,
        ),
      ),
    );
  }
}