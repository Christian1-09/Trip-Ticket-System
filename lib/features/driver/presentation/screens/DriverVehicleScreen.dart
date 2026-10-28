// features/driver/presentation/screens/DriverVehicleScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';
import '../widgets/driver_home_widgets.dart';

/// The driver's Vehicle tab.
///
/// Deliberately about the MACHINE, not the journey. The trip screen answers
/// "where am I going and what do I do next"; this answers "which vehicle am
/// I responsible for and what condition is it in". Without that split the
/// two screens become near-duplicates and the driver can't tell which is
/// authoritative.
///
/// Everything here comes from driverActiveTripsProvider — no extra request.
class DriverVehicleScreen extends ConsumerWidget {
  const DriverVehicleScreen({super.key});

  /// The vehicle in his hands right now.
  ///
  /// ONGOING wins outright — he is physically driving it. Otherwise the
  /// nearest commitment, accepted before merely offered, since an accepted
  /// trip is the one he has actually agreed to.
  static DriverTrip? _currentTrip(List<DriverTrip> trips) {
    DriverTrip? firstWhereStatus(AdminTripStatus status) {
      for (final trip in trips) {
        if (trip.status == status) return trip;
      }
      return null;
    }

    return firstWhereStatus(AdminTripStatus.ongoing) ??
        firstWhereStatus(AdminTripStatus.driverAccepted) ??
        firstWhereStatus(AdminTripStatus.headDriverApproved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(driverActiveTripsProvider);

    return Scaffold(
      backgroundColor: kDhPageBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: kDhBlue,
          onRefresh: () async {
            refreshDriverData(ref);
            await ref.read(driverActiveTripsProvider.future);
          },
          child: activeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _ErrorView(
              detail: '$err',
              onRetry: () => ref.invalidate(driverActiveTripsProvider),
            ),
            data: (trips) {
              final current = _currentTrip(trips);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                children: [
                  const Text(
                    'My Vehicle',
                    style: TextStyle(
                      color: kDhNavy,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current == null
                        ? 'Nothing assigned to you at the moment.'
                        : 'Assigned for ${current.trip.ticketNumber}',
                    style: const TextStyle(color: kDhMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  if (current == null)
                    const _EmptyState()
                  else ...[
                    _StatusStrip(trip: current),
                    const SizedBox(height: 14),
                    _VehicleCard(trip: current),
                    const SizedBox(height: 14),
                    _SpecGrid(trip: current),
                    const SizedBox(height: 14),
                    _TripSummary(trip: current),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────── status strip

class _StatusStrip extends StatelessWidget {
  final DriverTrip trip;
  const _StatusStrip({required this.trip});

  static final DateFormat _time = DateFormat('h:mm a');

  ({Color color, IconData icon, String title, String detail}) get _state {
    switch (trip.status) {
      case AdminTripStatus.ongoing:
        final left = trip.departure?.departureTime;
        return (
        color: kDhYellow,
        icon: Icons.local_shipping_rounded,
        title: 'On the road',
        detail: left == null
            ? 'Record your return when you get back.'
            : 'Left base at ${_time.format(left)}. Record your return when you get back.',
        );

      case AdminTripStatus.driverAccepted:
        if (trip.isTooEarlyToDepart) {
          return (
          color: kDhBlue,
          icon: Icons.schedule_rounded,
          title: 'Accepted',
          // The two-hour window is a server rule, so saying when it opens
          // beats letting him tap Depart and be refused.
          detail:
          'Departure can be recorded from ${_time.format(trip.departWindowOpensAt)}.',
          );
        }
        return (
        color: kDhGreen,
        icon: Icons.check_circle_rounded,
        title: 'Ready to depart',
        detail: 'Record your departure from the trip screen.',
        );

      case AdminTripStatus.headDriverApproved:
        return (
        color: kDhYellow,
        icon: Icons.help_outline_rounded,
        title: 'Awaiting your answer',
        detail: 'Accept or decline this trip to confirm the vehicle.',
        );

      default:
        return (
        color: kDhMuted,
        icon: Icons.info_outline_rounded,
        title: trip.driverStatusLabel,
        detail: '',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.color.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: s.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(s.icon, size: 19, color: _readable(s.color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(
                    color: kDhNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (s.detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    s.detail,
                    style: const TextStyle(
                      color: kDhMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Yellow on a pale yellow wash is unreadable, so that one darkens.
  Color _readable(Color color) =>
      color == kDhYellow ? const Color(0xFFB58900) : color;
}

// ─────────────────────────────────────────────────────────── hero card

class _VehicleCard extends StatelessWidget {
  final DriverTrip trip;
  const _VehicleCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.mediaUrl(trip.trip.vehicleImageUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kDhNavy.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              // A broken URL shouldn't blank the card.
              errorBuilder: (_, __, ___) => const _VehiclePlaceholder(),
            )
                : const _VehiclePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.trip.vehicleModel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kDhNavy,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kDhNavy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trip.trip.vehiclePlate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trip.trip.vehicleCapacity != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.event_seat_rounded,
                          size: 18, color: kDhBlue),
                      const SizedBox(height: 2),
                      Text(
                        '${trip.trip.vehicleCapacity}',
                        style: const TextStyle(
                          color: kDhNavy,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'seats',
                        style: TextStyle(color: kDhMuted, fontSize: 10),
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

class _VehiclePlaceholder extends StatelessWidget {
  const _VehiclePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDhBlue.withOpacity(0.08),
      alignment: Alignment.center,
      child: Icon(Icons.directions_car_filled_rounded,
          size: 54, color: kDhBlue.withOpacity(0.45)),
    );
  }
}

// ──────────────────────────────────────────────────────────── spec grid

class _SpecGrid extends StatelessWidget {
  final DriverTrip trip;
  const _SpecGrid({required this.trip});

  @override
  Widget build(BuildContext context) {
    final departure = trip.departure;

    final tiles = <Widget>[
      _SpecTile(
        icon: Icons.speed_rounded,
        label: 'ODOMETER',
        // During a trip the reading taken at departure is the true one;
        // the vehicle record won't catch up until the return is logged.
        value: departure != null
            ? '${departure.odometerStart}'
            : (trip.vehicleOdometer?.toString() ?? '—'),
        unit: 'km',
      ),
      if (departure != null)
        _SpecTile(
          icon: Icons.local_gas_station_rounded,
          label: 'FUEL AT START',
          value: departure.totalAvailableLiters.toStringAsFixed(1),
          unit: 'L',
        ),
    ];

    return Row(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _SpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _SpecTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kDhNavy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kDhBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kDhMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: kDhNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(color: kDhMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────── trip summary

/// One quiet block, not a second trip screen. Enough to know which job the
/// vehicle belongs to; the details live where they already live.
class _TripSummary extends StatelessWidget {
  final DriverTrip trip;
  const _TripSummary({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kDhNavy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  size: 17, color: kDhBlue),
              const SizedBox(width: 8),
              Text(
                trip.trip.ticketNumber,
                style: const TextStyle(
                  color: kDhNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (trip.trip.isUrgent)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE8ECF4)),
          _Line(
            icon: Icons.route_rounded,
            text: trip.trip.routeLabel,
          ),
          const SizedBox(height: 10),
          _Line(
            icon: Icons.schedule_rounded,
            text: '${trip.trip.dateLabel} · ${trip.trip.timeRangeLabel}',
          ),
          const SizedBox(height: 10),
          _Line(
            icon: Icons.person_outline_rounded,
            text: trip.trip.requester.fullName,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: kDhMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: kDhNavy,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────── empty/error

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kDhNavy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: kDhBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car_filled_rounded,
                size: 38, color: kDhBlue.withOpacity(0.55)),
          ),
          const SizedBox(height: 18),
          const Text(
            'No vehicle assigned right now',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kDhNavy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Once you accept a trip, the vehicle for it shows up here with '
                'its plate, odometer and fuel.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kDhMuted, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String detail;
  final VoidCallback onRetry;

  const _ErrorView({required this.detail, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // Scrollable so pull-to-refresh still works on the error screen.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 38),
        const SizedBox(height: 12),
        const Text(
          'Could not load your vehicle',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: kDhNavy, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          detail,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kDhMuted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}