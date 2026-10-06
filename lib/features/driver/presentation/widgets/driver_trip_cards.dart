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
import 'driver_schedule_card.dart';

/// Maps the backend status onto the old card's four looks.
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
/// [homeStyle] = the light DriverScheduleCard (Home, Schedule, History);
/// otherwise the original dark ScheduleCard for any older screen.
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

    if (homeStyle) return DriverScheduleCard(item: item, onTap: open);

    return ScheduleCard(
      name: trip.requester.fullName,
      plateNumber: trip.vehiclePlate,
      vehicleType: trip.vehicleModel,
      status: scheduleStatusFor(trip.status),
      date: '${_cardDate.format(trip.date)} · ${trip.destinationLabel}',
      time: driverTripTimeLabel(item),
      isUrgent: trip.isUrgent,
      onTap: open,
    );
  }
}

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
                color: homeStyle
                    ? const Color(0xFF6B7385)
                    : AppColors.textSecondary,
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