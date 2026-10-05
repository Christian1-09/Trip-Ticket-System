// features/driver/presentation/NavigateRoutePage/All_Trip_Request.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

import '../providers/driver_trip_providers.dart';
import '../widgets/driver_trip_cards.dart';

/// Every active trip: awaiting an answer, accepted, or on the road.
class AllTripRequest extends ConsumerWidget {
  const AllTripRequest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(driverActiveTripsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assigned Trips',
          style: TextStyle(
              color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: buildDriverTripCards(
              activeAsync,
              emptyText: 'No trips assigned to you right now.',
              onRetry: () => ref.invalidate(driverActiveTripsProvider),
            ),
          ),
        ),
      ),
    );
  }
}