// features/head_driver/presentation/widgets/hd_trip_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

import '../../data/head_driver_models.dart';
import '../head_driver_actions.dart';
import '../screen/head_driver_trip_detail_screen.dart';
import 'hd_trip_card.dart';

/// Search by requester, destination or ticket number (+ optional urgent-only).
List<HeadDriverTrip> filterHdTrips(
    List<HeadDriverTrip> items, {
      String query = '',
      bool urgentOnly = false,
    }) {
  final q = query.trim().toLowerCase();
  return items.where((item) {
    final t = item.trip;
    if (urgentOnly && !t.isUrgent) return false;
    if (q.isEmpty) return true;
    return t.requester.fullName.toLowerCase().contains(q) ||
        t.destinationLabel.toLowerCase().contains(q) ||
        t.originLabel.toLowerCase().contains(q) ||
        t.ticketNumber.toLowerCase().contains(q);
  }).toList();
}

/// One card, wired to the same actions as before.
Widget buildHdTripCard(
    BuildContext context,
    WidgetRef ref,
    HeadDriverTrip item, {
      required bool declined,
    }) {
  final t = item.trip;

  final driver = declined
      ? (item.declines.isEmpty
      ? 'Driver declined'
      : 'Declined by ${item.declines.first.driverName}')
      : t.driver.fullName;

  return HdTripCard(
    date: t.date,
    route: '${t.originLabel}  →  ${t.destinationLabel}',
    time: '${t.departureLabel} - ${t.endTimeLabel}',
    requesterName: t.requester.fullName,
    detailLine: '$driver · ${t.vehicleModel} (${t.vehiclePlate})',
    vehicleImageUrl: ApiConfig.mediaUrl(t.vehicleImageUrl),
    isUrgent: t.isUrgent,
    status: declined ? HdCardStatus.declined : HdCardStatus.pending,
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HeadDriverTripDetailScreen(item: item, isDeclined: declined),
      ),
    ),
    onReject: declined ? null : () => HeadDriverActions.reject(context, ref, item),
    onApprove: declined ? null : () => HeadDriverActions.approve(context, ref, item),
    onAssign: declined ? () => HeadDriverActions.assignDriver(context, ref, item) : null,
  );
}