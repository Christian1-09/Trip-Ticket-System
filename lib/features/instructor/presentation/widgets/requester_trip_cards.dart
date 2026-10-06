// features/instructor/presentation/widgets/requester_trip_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/instructor/presentation/widgets/schedule.dart';

import '../../data/requester_trip_models.dart';
import '../screens/requester_trip_detail_screen.dart';
import 'home_trip_card.dart';

final DateFormat _cardDate = DateFormat('EEE MMM d');
final DateFormat _myTripsDate = DateFormat('EEE, MMM d');

/// Light palette for the My Trips card (kept local so it doesn't depend on
/// colors that may not exist in AppColors yet).
class _MyTripsColors {
  static const navy = Color(0xFF0B1B3F);
  static const blue = Color(0xFF1E6FE8);
  static const textMuted = Color(0xFF5B6478);
  static const divider = Color(0xFFE6EAF2);
  static const chevronBg = Color(0xFFE8F0FD);
}

/// Which look a [RequesterTripCard] uses.
enum RequesterCardStyle {
  /// Original dark ScheduleCard (other screens).
  schedule,

  /// Light card from the home design.
  home,

  /// White card from the My Trips design.
  myTrips,
}

/// One of the requester's trips. Tapping opens the detail screen with its
/// status, rating and print button.
class RequesterTripCard extends StatelessWidget {
  final RequesterTrip item;
  final RequesterCardStyle style;

  const RequesterTripCard({
    super.key,
    required this.item,
    this.style = RequesterCardStyle.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    void open() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequesterTripDetailScreen(tripId: trip.id),
      ),
    );

    switch (style) {
      case RequesterCardStyle.home:
        return HomeTripCard(
          date: trip.date,
          destination: trip.destinationLabel,
          origin: null,
          passengerCount: null,
          time: trip.timeRangeLabel,
          driverName: trip.driver.fullName,
          vehicleLabel: '${trip.vehiclePlate} ${trip.vehicleModel}',
          status: item.cardStatus,
          isUrgent: trip.isUrgent,
          onTap: open,
        );

      case RequesterCardStyle.myTrips:
        return _MyTripCard(item: item, onTap: open);

      case RequesterCardStyle.schedule:
        return ScheduleCard(
          name: trip.driver.fullName,
          plateNumber: trip.vehiclePlate,
          vehicleType: trip.vehicleModel,
          status: item.cardStatus,
          date: '${_cardDate.format(trip.date)} · ${trip.destinationLabel}',
          time: trip.timeRangeLabel,
          isUrgent: trip.isUrgent,
          onTap: open,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Trips card
// ─────────────────────────────────────────────────────────────────────────────

class _StatusLook {
  final String header;
  final IconData headerIcon;
  final Color headerColor;
  final String pill;
  final IconData pillIcon;
  final Color pillBg;
  final Color pillFg;

  const _StatusLook({
    required this.header,
    required this.headerIcon,
    required this.headerColor,
    required this.pill,
    required this.pillIcon,
    required this.pillBg,
    required this.pillFg,
  });
}

/// Maps the trip status to the header label + pill. Uses the enum's `.name`
/// so it works with whatever values AdminTripStatus has.
_StatusLook _lookFor(RequesterTrip item) {
  final name = item.status.name.toLowerCase();

  if (name.contains('reject') || name.contains('declin') || name.contains('cancel')) {
    return const _StatusLook(
      header: 'Not Approved',
      headerIcon: Icons.close_rounded,
      headerColor: Color(0xFFE5394A),
      pill: 'REJECTED',
      pillIcon: Icons.cancel,
      pillBg: Color(0xFFFDE2E4),
      pillFg: Color(0xFFC62835),
    );
  }
  if (name.contains('complet') || name.contains('done') || name.contains('finish')) {
    return const _StatusLook(
      header: 'Schedule Trip',
      headerIcon: Icons.check_rounded,
      headerColor: _MyTripsColors.blue,
      pill: 'COMPLETED',
      pillIcon: Icons.check_circle,
      pillBg: Color(0xFFDDF3E6),
      pillFg: Color(0xFF1B7A43),
    );
  }
  if (name.contains('pend') || name.contains('wait') || name.contains('submit')) {
    return const _StatusLook(
      header: 'Schedule Trip',
      headerIcon: Icons.send_rounded,
      headerColor: _MyTripsColors.blue,
      pill: 'PENDING',
      pillIcon: Icons.schedule,
      pillBg: Color(0xFFFCD34D),
      pillFg: Color(0xFF3B2A00),
    );
  }
  // approved / confirmed / assigned / ongoing, etc.
  return const _StatusLook(
    header: 'Schedule Trip',
    headerIcon: Icons.check_rounded,
    headerColor: _MyTripsColors.blue,
    pill: 'CONFIRMED',
    pillIcon: Icons.check_circle,
    pillBg: Color(0xFFDDF3E6),
    pillFg: Color(0xFF1B7A43),
  );
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

class _MyTripCard extends StatelessWidget {
  final RequesterTrip item;
  final VoidCallback onTap;

  const _MyTripCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final look = _lookFor(item);
    final name = trip.driver.fullName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B1B3F).withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: type + status pill ──
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: look.headerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(look.headerIcon, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        look.header,
                        style: const TextStyle(
                          color: _MyTripsColors.navy,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _StatusPill(look: look),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Body: avatar, name, route, chevron ──
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _MyTripsColors.navy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _initials(name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _MyTripsColors.navy,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: _MyTripsColors.textMuted),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  trip.destinationLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _MyTripsColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.arrow_forward,
                                    size: 12, color: _MyTripsColors.textMuted),
                              ),
                              Flexible(
                                child: Text(
                                  '${trip.vehiclePlate} ${trip.vehicleModel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _MyTripsColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: _MyTripsColors.chevronBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right,
                          size: 20, color: _MyTripsColors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _MyTripsColors.divider),
                const SizedBox(height: 10),

                // ── Footer: date | time | vehicle ──
                Row(
                  children: [
                    _InfoItem(
                      icon: Icons.calendar_month_outlined,
                      text: _myTripsDate.format(trip.date),
                    ),
                    const _VDivider(),
                    _InfoItem(
                      icon: Icons.access_time,
                      text: trip.timeRangeLabel,
                      flex: 5,
                    ),
                    const _VDivider(),
                    _InfoItem(
                      icon: Icons.airport_shuttle_outlined,
                      text: trip.vehicleModel,
                      flex: 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _StatusLook look;
  const _StatusPill({required this.look});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: look.pillBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(look.pillIcon, size: 13, color: look.pillFg),
          const SizedBox(width: 5),
          Text(
            look.pill,
            style: TextStyle(
              color: look.pillFg,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final int flex;

  const _InfoItem({required this.icon, required this.text, this.flex = 4});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Icon(icon, size: 15, color: _MyTripsColors.navy),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _MyTripsColors.navy,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _MyTripsColors.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List builder
// ─────────────────────────────────────────────────────────────────────────────

/// Loading / error / empty / cards, ready to spread into a ListView or Column.
///
/// [homeStyle] is kept for existing callers; [style] wins when both are set.
List<Widget> buildRequesterTripCards(
    AsyncValue<List<RequesterTrip>> async, {
      required String emptyText,
      required VoidCallback onRetry,
      List<RequesterTrip>? override,
      int? limit,
      bool homeStyle = false,
      RequesterCardStyle? style,
    }) {
  final resolved =
      style ?? (homeStyle ? RequesterCardStyle.home : RequesterCardStyle.schedule);

  return async.when(
    loading: () => const [
      Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    ],
    error: (err, _) => [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              err is ApiException ? err.message : 'Could not load your trips.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    ],
    data: (loaded) {
      final items = override ?? loaded;
      if (items.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              emptyText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.homeTextMuted, fontSize: 13),
            ),
          ),
        ];
      }
      final shown = limit == null ? items : items.take(limit).toList();
      return shown
          .map((item) => RequesterTripCard(item: item, style: resolved))
          .toList();
    },
  );
}