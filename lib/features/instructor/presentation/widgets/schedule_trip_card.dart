// features/instructor/presentation/widgets/schedule_trip_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

import '../../data/requester_trip_models.dart';
import '../screens/requester_trip_detail_screen.dart';
import 'schedule.dart' show TripStatus;

const _ink = AppColors.homeNavy;
const _muted = Color(0xFF8A93A8);

final DateFormat _weekday = DateFormat('EEE');
final DateFormat _month = DateFormat('MMM');

/// The light trip card used on the Schedule tab:
/// status edge │ date block │ badge, route, time, driver │ vehicle + pill │ arrow
class ScheduleTripCard extends StatelessWidget {
  final RequesterTrip item;

  /// Where the trip starts (base location). Shown as "origin → destination".
  final String origin;

  /// Photo of the assigned vehicle, already resolved to a full URL.
  final String? vehicleImageUrl;

  const ScheduleTripCard({
    super.key,
    required this.item,
    required this.origin,
    this.vehicleImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final style = TripStatusStyle.of(item.cardStatus);
    final driverName = trip.driver.fullName.trim();
    final vehicleLine = '${trip.vehiclePlate} ${trip.vehicleModel}'.trim();

    void open() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequesterTripDetailScreen(tripId: trip.id),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE3F1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeNavy.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: open,
            child: Stack(
              children: [
                // Soft diagonal stripes behind the vehicle
                const Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: 170,
                  child: CustomPaint(painter: _StripesPainter()),
                ),

                // Status-coloured left edge
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: style.accent),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Row(
                    children: [
                      _DateBlock(date: trip.date),
                      const SizedBox(width: 10),

                      // ── Details ────────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TopBadge(item: item),
                            const SizedBox(height: 6),
                            _InfoLine(
                              icon: Icons.north_east_rounded,
                              child: _RouteText(
                                from: origin,
                                to: trip.destinationLabel,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _InfoLine(
                              icon: Icons.schedule_rounded,
                              child: Text(
                                '${trip.departureLabel} - ${trip.endTimeLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                const TextStyle(color: _ink, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _InfoLine(
                              icon: Icons.person_rounded,
                              child: Text(
                                driverName.isEmpty
                                    ? 'Driver not assigned'
                                    : driverName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: driverName.isEmpty ? _muted : _ink,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (vehicleLine.isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 18, top: 1),
                                child: Text(
                                  vehicleLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: _muted, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // ── Vehicle + status ───────────────────────────
                      SizedBox(
                        width: 92,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _VehicleImage(imageUrl: vehicleImageUrl),
                            const SizedBox(height: 6),
                            _StatusPill(style: style),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // ── Arrow ──────────────────────────────────────
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFCFD8EA)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.homeNavy.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            size: 16, color: _ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────── style

/// Colours and labels for each status, shared by the edge and the pill.
class TripStatusStyle {
  final String label;
  final IconData icon;
  final Color accent; // left edge
  final Color fg; // pill text
  final Color bg; // pill fill

  const TripStatusStyle(this.label, this.icon, this.accent, this.fg, this.bg);

  static TripStatusStyle of(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return const TripStatusStyle('PENDING', Icons.schedule_rounded,
            AppColors.accentYellow, Color(0xFF8A6200), Color(0xFFFFE9A8));
      case TripStatus.confirmed:
        return const TripStatusStyle('CONFIRMED', Icons.check_circle_rounded,
            AppColors.homeNavy, Color(0xFF2F6FE0), Color(0xFFE2ECFF));
      case TripStatus.ongoing:
        return const TripStatusStyle('ON TRIP', Icons.route_rounded,
            Color(0xFF6A3FD6), Color(0xFF6A3FD6), Color(0xFFEDE6FF));
      case TripStatus.completed:
        return const TripStatusStyle('COMPLETED', Icons.flag_rounded,
            Color(0xFF1FA463), Color(0xFF1FA463), Color(0xFFE3F6EC));
      case TripStatus.rejected:
        return const TripStatusStyle('REJECTED', Icons.cancel_rounded,
            Color(0xFFE53935), Color(0xFFE53935), Color(0xFFFDE7E7));
    }
  }
}

// ─────────────────────────────────────────────────────────────── pieces

class _DateBlock extends StatelessWidget {
  final DateTime date;
  const _DateBlock({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.homeNavy, AppColors.homeNavyDark],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeNavyDark.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _weekday.format(date).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            '${date.day}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          Text(
            _month.format(date),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Red "NOT APPROVED" beats yellow "URGENT", which beats yellow "PENDING".
class _TopBadge extends StatelessWidget {
  final RequesterTrip item;
  const _TopBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final String text;
    final IconData icon;
    final Color bg;
    final Color fg;

    if (item.isRejected) {
      text = 'NOT APPROVED';
      icon = Icons.error_rounded;
      bg = const Color(0xFFE53935);
      fg = Colors.white;
    } else if (item.trip.isUrgent) {
      text = 'URGENT';
      icon = Icons.error_rounded;
      bg = AppColors.accentYellow;
      fg = _ink;
    } else if (item.cardStatus == TripStatus.pending) {
      text = 'PENDING';
      icon = Icons.schedule_rounded;
      bg = AppColors.accentYellow;
      fg = _ink;
    } else {
      return const SizedBox(height: 4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _InfoLine({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _ink),
        const SizedBox(width: 5),
        Expanded(child: child),
      ],
    );
  }
}

class _RouteText extends StatelessWidget {
  final String from;
  final String to;
  const _RouteText({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: _ink,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: from),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.arrow_forward_rounded, size: 11, color: _ink),
            ),
          ),
          TextSpan(text: to),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// The vehicle sits straight on the striped background — no box.
class _VehicleImage extends StatelessWidget {
  final String? imageUrl;
  const _VehicleImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(
      Icons.airport_shuttle_rounded,
      size: 34,
      color: Color(0xFFB4BED3),
    );
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: imageUrl == null
          ? placeholder
          : Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final TripStatusStyle style;
  const _StatusPill({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.fg.withOpacity(0.3)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 10, color: style.fg),
            const SizedBox(width: 3),
            Text(
              style.label,
              style: TextStyle(
                color: style.fg,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Faint diagonal bands on the right of the card, behind the vehicle.
class _StripesPainter extends CustomPainter {
  const _StripesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fade the whole area in from the left so the edge isn't visible.
    final fade = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00EEF3FC), Color(0xFFEEF3FC)],
        stops: [0.0, 0.35],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, fade);

    final band = Paint()..color = Colors.white.withOpacity(0.75);
    for (final x in [0.35, 0.62, 0.88]) {
      final path = Path()
        ..moveTo(w * x, 0)
        ..lineTo(w * x + 18, 0)
        ..lineTo(w * x - 30, h)
        ..lineTo(w * x - 48, h)
        ..close();
      canvas.drawPath(path, band);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}