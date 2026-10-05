// features/driver/presentation/screens/driver_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/HeaderText_Schedule.dart';


import '../../../instructor/presentation/widgets/search_bar_widget.dart';
import '../providers/driver_trip_providers.dart';
import '../widgets/driver_trip_cards.dart';

/// Upcoming and ongoing trips, soonest first.
class DriverScheduleScreen extends ConsumerWidget {
  const DriverScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(driverActiveTripsProvider);
    final count = activeAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            refreshDriverData(ref);
            await ref.read(driverActiveTripsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 54),
            children: [
              SearchBarWidget(onFilterTap: () {}),
              const SizedBox(height: 14),
              HeaderTextSchedule(totalDriver: count),
              const SizedBox(height: 24),
              ...buildDriverTripCards(
                activeAsync,
                emptyText: 'Nothing scheduled. New trips appear here once assigned.',
                onRetry: () => ref.invalidate(driverActiveTripsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}