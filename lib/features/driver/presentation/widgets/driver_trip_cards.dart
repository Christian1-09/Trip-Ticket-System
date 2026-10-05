// features/driver/presentation/widgets/driver_trip_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/TripInformation.dart';
import 'package:jtrips_app/features/instructor/presentation/widgets/schedule.dart';

import '../../data/driver_models.dart';

/// Maps the backend status onto the card's four looks.
TripStatus scheduleStatusFor(AdminTripStatus status) {
  switch (status) {
    case AdminTripStatus.driverAccepted:
      return TripStatus.confirmed;
    case AdminTripStatus.ongoing:
      return TripStatus.ongoing;
    case AdminTripStatus.completed:
      return TripStatus.completed;
    default:
      return TripStatus.pending;
  }
}

final DateFormat _cardDate = DateFormat('EEE MMM d');

/// One trip. Tapping opens the trip's details.
///
/// [homeStyle] = the light card from the driver home design; otherwise the
/// original dark ScheduleCard (still used by the other driver screens).
class DriverTripCard extends StatelessWidget {
  final DriverTrip item;
  final bool homeStyle;

  const DriverTripCard({super.key, required this.item, this.homeStyle = false});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    void open() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripInformation(tripId: trip.id)),
    );

    if (homeStyle) return _DriverHomeTripCard(trip: trip, onTap: open);

    return ScheduleCard(
      name: trip.requester.fullName,
      plateNumber: trip.vehiclePlate,
      vehicleType: trip.vehicleModel,
      status: scheduleStatusFor(trip.status),
      date: '${_cardDate.format(trip.date)} · ${trip.destinationLabel}',
      time: '${trip.departureLabel} - ${trip.endTimeLabel}',
      isUrgent: trip.isUrgent,
      onTap: open,
    );
  }
}

// ─────────────────────────────────────────────────────────── home card

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _yellow = Color(0xFFFFC928);

class _StatusLook {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  const _StatusLook(this.label, this.icon, this.bg, this.fg);
}

_StatusLook _lookFor(TripStatus s) {
  switch (s) {
    case TripStatus.confirmed:
      return const _StatusLook('CONFIRMED', Icons.check_circle, Color(0xFFFFF1C2), Color(0xFF8A6500));
    case TripStatus.ongoing:
      return const _StatusLook('ONGOING', Icons.directions_car_filled, Color(0xFFDCE9FD), _blue);
    case TripStatus.completed:
      return const _StatusLook('COMPLETED', Icons.verified, Color(0xFFDDF3E6), Color(0xFF1B7A43));
    default:
      return const _StatusLook('PENDING', Icons.schedule, Color(0xFFEDEFF4), _muted);
  }
}

String? _originOf(AdminTripModel trip) {
  for (final s in trip.stops) {
    if (s.type == 'ORIGIN') return s.address;
  }
  return null;
}

class _DriverHomeTripCard extends StatelessWidget {
  final AdminTripModel trip;
  final VoidCallback onTap;

  const _DriverHomeTripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final look = _lookFor(scheduleStatusFor(trip.status));
    final origin = _originOf(trip);
    final accent = trip.isUrgent ? _yellow : _blue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accent, width: 4)),
            ),
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Row(
              children: [
                // ── Date block ──
                Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1B3A9E), Color(0xFF0A1F66)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEE').format(trip.date).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d').format(trip.date).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (trip.isUrgent) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _yellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Line(
                        icon: Icons.north_east_rounded,
                        text: origin == null
                            ? trip.destinationLabel
                            : '$origin  →  ${trip.destinationLabel}',
                        bold: true,
                      ),
                      const SizedBox(height: 5),
                      _Line(
                        icon: Icons.schedule,
                        text: '${trip.departureLabel} - ${trip.endTimeLabel}',
                      ),
                      const SizedBox(height: 5),
                      _Line(
                        icon: Icons.person,
                        text: trip.requester.fullName,
                        bold: true,
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Text(
                          '${trip.vehiclePlate} ${trip.vehicleModel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // ── Status + vehicle + chevron ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: look.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(look.icon, size: 11, color: look.fg),
                          const SizedBox(width: 3),
                          Text(
                            look.label,
                            style: TextStyle(
                              color: look.fg,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.airport_shuttle_rounded,
                              color: Color(0xFFA9B3C4), size: 30),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F0FD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right, size: 18, color: _blue),
                        ),
                      ],
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

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _Line({required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _navy),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _navy,
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────── list builder

/// Loading / error / empty / cards for a list of trips, ready to spread into
/// a ListView's children. [limit] shows only the first few (home screen).
List<Widget> buildDriverTripCards(
    AsyncValue<List<DriverTrip>> async, {
      required String emptyText,
      required VoidCallback onRetry,
      int? limit,
      bool homeStyle = false,
    }) {
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
              err is ApiException ? err.message : 'Could not load trips.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    ],
    data: (items) {
      if (items.isEmpty) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              emptyText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: homeStyle ? _muted : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ];
      }
      final shown = limit == null ? items : items.take(limit).toList();
      return shown
          .map((item) => DriverTripCard(item: item, homeStyle: homeStyle))
          .toList();
    },
  );
}