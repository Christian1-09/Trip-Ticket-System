// features/driver/presentation/NavigateRoutePage/All_Trip_Request.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/driver_trip_providers.dart';
import '../widgets/driver_trip_cards.dart';

/// Every active trip: awaiting an answer, accepted, or on the road.
class AllTripRequest extends ConsumerWidget {
  const AllTripRequest({super.key});

  // Light page to match the Home / Schedule screens.
  static const _pageBg = Color(0xFFF2F5FB);
  static const _titleColor = Color(0xFF111827);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(driverActiveTripsProvider);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _titleColor),
        title: const Text(
          'Assigned Trips',
          style: TextStyle(
              color: _titleColor, fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            refreshDriverData(ref);
            await ref.read(driverActiveTripsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: buildDriverTripCards(
              activeAsync,
              emptyText: 'No trips assigned to you right now.',
              onRetry: () => ref.invalidate(driverActiveTripsProvider),
              homeStyle: true, // ← use the light DriverScheduleCard
            ),
          ),
        ),
      ),
    );
  }
}