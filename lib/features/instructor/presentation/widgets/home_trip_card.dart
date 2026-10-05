// features/instructor/presentation/widgets/home_trip_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

import 'schedule.dart' show TripStatus;

/// Light "Upcoming Trips" card for the home screen:
///
///  ┌──────┬──────────────────────────────────────────┐
///  │ SEP  │ ✈ Dipolog → Zamboanga        [PENDING]   │
///  │  24  │ ⏰ 3:20 AM - 2:40 PM                   ›  │
///  │ Wed  │ [PA] Pretz Ajo          👥 43            │
///  │      │      2/43 Van                            │
///  └──────┴──────────────────────────────────────────┘
class HomeTripCard extends StatelessWidget {
  final DateTime date;
  final String destination;
  final String? origin;
  final String time;
  final String driverName;
  final String vehicleLabel;
  final TripStatus status;
  final bool isUrgent;
  final int? passengerCount;
  final VoidCallback? onTap;

  const HomeTripCard({
    super.key,
    required this.date,
    required this.destination,
    required this.time,
    required this.driverName,
    required this.vehicleLabel,
    required this.status,
    this.origin,
    this.isUrgent = false,
    this.passengerCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.homeIconBlue.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.homeNavy.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // ── Faint scenery bottom-right (like the design) ───────────
              Positioned(
                right: 0,
                bottom: 0,
                width: 170,
                height: 60,
                child: Opacity(
                  opacity: 0.14,
                  child: Image.asset(
                    AppMedia.vehicleBackGround,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DateBlock(date: date),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                        child: Row(
                          children: [
                            Expanded(child: _Details(card: this)),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _StatusPill(status: status),
                                const SizedBox(height: 10),
                                const _ChevronButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

class _DateBlock extends StatelessWidget {
  final DateTime date;

  const _DateBlock({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E2A8C), AppColors.homeNavyDark],
        ),
        border: Border(
          left: BorderSide(color: AppColors.accentYellow, width: 5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            DateFormat('d').format(date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          Text(
            DateFormat('EEE').format(date),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final HomeTripCard card;

  const _Details({required this.card});

  String get _initials {
    final parts = card.driverName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(color: AppColors.homeTextMuted, fontSize: 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Route
        Row(
          children: [
            const Icon(Icons.flight_rounded,
                size: 14, color: AppColors.homeNavy),
            const SizedBox(width: 6),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    if (card.origin != null) ...[
                      TextSpan(text: card.origin),
                      const TextSpan(
                        text: '  →  ',
                        style: TextStyle(color: AppColors.homeIconBlue),
                      ),
                    ],
                    TextSpan(text: card.destination),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.homeTextDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Time (+ urgent tag)
        Row(
          children: [
            const Icon(Icons.access_time_filled_rounded,
                size: 14, color: AppColors.homeNavy),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                card.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.homeTextDark,
                  fontSize: 11.5,
                ),
              ),
            ),
            if (card.isUrgent) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 10, color: Colors.white),
                    Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Driver
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.homeNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.driverName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.homeTextDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    card.vehicleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ],
              ),
            ),
            if (card.passengerCount != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.groups_rounded,
                  size: 16, color: AppColors.homeNavy),
              const SizedBox(width: 3),
              Text(
                '${card.passengerCount}',
                style: const TextStyle(
                  color: AppColors.homeTextDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Filled pill per status — yellow PENDING, blue CONFIRMED, etc.
class _StatusPill extends StatelessWidget {
  final TripStatus status;

  const _StatusPill({required this.status});

  (String, IconData, Color bg, Color fg) get _style {
    switch (status) {
      case TripStatus.pending:
        return ('PENDING', Icons.schedule_rounded, AppColors.accentYellow,
        AppColors.homeNavy);
      case TripStatus.confirmed:
        return ('CONFIRMED', Icons.check_circle_rounded,
        AppColors.homeIconBlue, Colors.white);
      case TripStatus.ongoing:
        return ('ON TRIP', Icons.directions_car_rounded, AppColors.homeNavy,
        Colors.white);
      case TripStatus.completed:
        return ('COMPLETED', Icons.flag_rounded, AppColors.homeGreen,
        Colors.white);
      case TripStatus.rejected:
        return ('REJECTED', Icons.cancel_rounded, const Color(0xFFE53935),
        Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg) = _style;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.homeTileBlue,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.homeIconBlue.withOpacity(0.2)),
      ),
      child: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.homeNavy,
      ),
    );
  }
}