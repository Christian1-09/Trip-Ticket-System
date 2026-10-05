// features/driver/presentation/screens/driver_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

import '../providers/driver_trip_providers.dart';
import '../widgets/driver_trip_cards.dart';

/// Completed trips, most recent first.
class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(driverHistoryTripsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(driverHistoryTripsProvider);
            await ref.read(driverHistoryTripsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: buildDriverTripCards(
              historyAsync,
              emptyText: 'No completed trips yet.',
              onRetry: () => ref.invalidate(driverHistoryTripsProvider),
            ),
          ),
        ),
      ),
    );
  }
}