// features/driver/presentation/widgets/driver_schedule_card.dart
//
// The trip card used by the driver's Home (Assigned Trips), Schedule and
// History screens, so all three look the same.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

import '../../data/driver_models.dart';

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _yellow = Color(0xFFFFC928);

final DateFormat _time = DateFormat('h:mm a');

/// The best time range we can show for a trip:
/// 1. Finished trips → the real times the driver left and came back.
/// 2. Otherwise → scheduled departure to the planned end (return time, or
///    pick-up time + travel time for drop-and-pick-up trips).
/// 3. No end known → just the departure time (never "1:44 AM - —").
String driverTripTimeLabel(DriverTrip t) {
  final arrival = t.arrival;
  if (arrival != null) {
    final left = t.departure?.departureTime ?? t.trip.departureTime;
    return '${_time.format(left)} - ${_time.format(arrival.arrivalTime)}';
  }
  final end = t.plannedEnd;
  final start = _time.format(t.trip.departureTime);
  return end == null ? start : '$start - ${_time.format(end)}';
}

/// What the badge on the card says, from the driver's point of view.
/// Urgency is shown separately (date block + yellow edge), so the badge
/// always tells the status.
({String label, IconData icon, Color fg, String title}) _lookFor(DriverTrip t) {
  switch (t.status) {
    case AdminTripStatus.headDriverApproved:
      return (
      label: 'AWAITING YOU',
      icon: Icons.hourglass_top_rounded,
      fg: const Color(0xFFB07C00),
      title: 'Schedule Trip',
      );
    case AdminTripStatus.driverAccepted:
      return (
      label: 'CONFIRMED',
      icon: Icons.check_circle,
      fg: _blue,
      title: 'Schedule Trip',
      );
    case AdminTripStatus.ongoing:
      return (
      label: 'ON THE ROAD',
      icon: Icons.directions_car_filled,
      fg: const Color(0xFF1B7A43),
      title: 'Ongoing Trip',
      );
    case AdminTripStatus.completed:
      return (
      label: 'COMPLETED',
      icon: Icons.check_circle,
      fg: const Color(0xFF1B7A43),
      title: 'Completed Trip',
      );
    case AdminTripStatus.rejected:
    case AdminTripStatus.driverDeclined:
      return (
      label: 'CANCELLED',
      icon: Icons.cancel,
      fg: const Color(0xFFC62835),
      title: 'Cancelled Trip',
      );
    default:
      return (
      label: t.status.label.toUpperCase(),
      icon: Icons.schedule,
      fg: _muted,
      title: 'Schedule Trip',
      );
  }
}

class DriverScheduleCard extends StatelessWidget {
  final DriverTrip item;
  final VoidCallback onTap;

  const DriverScheduleCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final look = _lookFor(item);
    final n = trip.passengers.length;
    final cap = trip.vehicleCapacity;
    final seats = cap == null
        ? '$n passenger${n == 1 ? '' : 's'}'
        : '$n/$cap seats';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DateColumn(date: trip.date, urgent: trip.isUrgent),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Strip(
                          title: look.title,
                          label: look.label,
                          icon: look.icon,
                          fg: look.fg,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Line(
                                      icon: Icons.location_on,
                                      iconColor: _blue,
                                      text:
                                      '${trip.originLabel}  →  ${trip.destinationLabel}',
                                      bold: true,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    _Line(
                                      icon: Icons.schedule,
                                      text: driverTripTimeLabel(item),
                                    ),
                                    const SizedBox(height: 5),
                                    _Line(
                                      icon: Icons.person,
                                      text: trip.requester.fullName,
                                      bold: true,
                                    ),
                                    const SizedBox(height: 5),
                                    _Line(
                                      icon: Icons.groups_rounded,
                                      text: '$seats · ${trip.vehicleModel}',
                                      small: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _Photo(url: ApiConfig.mediaUrl(trip.vehicleImageUrl)),
                              const SizedBox(width: 6),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F0FD),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_right,
                                    size: 18, color: _blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final DateTime date;
  final bool urgent;

  const _DateColumn({required this.date, required this.urgent});

  @override
  Widget build(BuildContext context) {
    final showYear = date.year != DateTime.now().year;

    return Container(
      width: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B4FD6), Color(0xFF0A2C8F)],
        ),
        border: urgent
            ? const Border(left: BorderSide(color: _yellow, width: 4))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEE').format(date).toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${date.day}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          if (showYear)
            Text(
              '${date.year}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 10,
              ),
            ),
          if (urgent) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'URGENT',
                style: TextStyle(
                  color: _navy,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  final String title;
  final String label;
  final IconData icon;
  final Color fg;

  const _Strip({
    required this.title,
    required this.label,
    required this.icon,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1B3FB0)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 11, color: fg),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
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

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final bool bold;
  final bool small;
  final int maxLines;

  const _Line({
    required this.icon,
    required this.text,
    this.iconColor = _navy,
    this.bold = false,
    this.small = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: small ? _muted : _navy,
              fontSize: small ? 10.5 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _Photo extends StatelessWidget {
  final String? url;
  const _Photo({required this.url});

  static const _placeholder = Icon(
    Icons.airport_shuttle_rounded,
    color: Color(0xFFA9B3C4),
    size: 30,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 74,
        height: 50,
        color: const Color(0xFFF1F4F9),
        alignment: Alignment.center,
        child: url == null
            ? _placeholder
            : Image.network(
          url!,
          width: 74,
          height: 50,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder,
          errorBuilder: (_, __, ___) => _placeholder,
        ),
      ),
    );
  }
}