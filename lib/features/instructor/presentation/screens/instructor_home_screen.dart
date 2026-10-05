// features/instructor/presentation/screens/instructor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/notifications/presentation/notifications_screen.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';

import '../../trip_ticket/data/fleet_models.dart';
import '../providers/fleet_providers.dart';
import '../providers/requester_tab_provider.dart';
import '../providers/requester_trip_providers.dart';
import '../providers/trip_ticket_provider.dart';
import '../widgets/HeaderSection.dart';
import '../widgets/home_section_card.dart';
import '../widgets/home_stats_card.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/requester_trip_cards.dart';
import '../widgets/requester_vehicle_card.dart';
import '../widgets/urgent_travel_sheet.dart';
import 'my_trips_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState is AuthAuthenticated
        ? authState.user.fullName.split(' ').first
        : '';

    final tripsAsync = ref.watch(myTripsProvider);
    final stats = ref.watch(myTripStatsProvider);
    final active = ref.watch(myActiveTripsProvider);

    final vehiclesAsync = ref.watch(vehicleDirectoryProvider);
    final recommended = ref.watch(recommendedVehiclesProvider);

    void openAllTrips() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyTripsScreen()),
    );

    /// Switches the bottom-nav tab instead of pushing a route.
    void goToTab(int index) =>
        ref.read(requesterTabProvider.notifier).state = index;

    Future<void> handleUrgentTravel() async {
      final reason = await showUrgentTravelSheet(context);
      if (reason == null) return;
      ref.read(tripTicketProvider.notifier).startUrgentTrip(reason: reason);
      goToTab(RequesterTabs.book);
    }

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      // top: false so the header photo runs under the status bar.
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ── Header (photo banner) ────────────────────────────────────
            HeaderSection(
              userName: userName,
              onSearchTap: () => goToTab(RequesterTabs.schedule),
              onUrgentTravelTap: handleUrgentTravel,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              // onProfileTap: () => goToTab(RequesterTabs.profile),
            ),

            // ── Stats: its own card, small gap below the header ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: HomeStatsCard(
                total: stats.total,
                pending: stats.pending,
                onTrip: stats.onTrip,
              ),
            ),
            const SizedBox(height: 10),

            // ── Scrollable sections ─────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshMyTrips(ref);
                  ref.invalidate(vehicleDirectoryProvider);
                  await Future.wait([
                    ref.read(myTripsProvider.future),
                    ref.read(vehicleDirectoryProvider.future),
                  ]);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                  children: [
                    QuickActions(actions: [
                      QuickAction(
                        label: 'Book Trip',
                        subtitle: 'Plan your next trip',
                        icon: Icons.add_box_rounded,
                        highlighted: true,
                        onTap: () => goToTab(RequesterTabs.book),
                      ),
                      QuickAction(
                        label: 'My Trips',
                        subtitle: 'View your bookings',
                        icon: Icons.work_rounded,
                        valueColor: AppColors.homeNavy,
                        onTap: openAllTrips,
                      ),
                      QuickAction(
                        label: 'Schedule',
                        subtitle: 'Manage your schedule',
                        icon: Icons.calendar_month_rounded,
                        valueColor: AppColors.accentYellow,
                        onTap: () => goToTab(RequesterTabs.schedule),
                      ),
                    ]),

                    const SizedBox(height: 14),

                    HomeSectionCard(
                      title: 'Recommended Vehicles',
                      actionLabel: 'See All',
                      onAction: () => goToTab(RequesterTabs.vehicles),
                      child: _RecommendedVehicles(
                        vehiclesAsync: vehiclesAsync,
                        recommended: recommended,
                        onSeeAll: () => goToTab(RequesterTabs.vehicles),
                        onRetry: () =>
                            ref.invalidate(vehicleDirectoryProvider),
                      ),
                    ),

                    const SizedBox(height: 14),

                    HomeSectionCard(
                      icon: Icons.calendar_month_outlined,
                      title: active.isEmpty ? 'My Trips' : 'Upcoming Trips',
                      actionLabel: 'View All',
                      onAction: openAllTrips,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: buildRequesterTripCards(
                          tripsAsync,
                          override: active,
                          limit: 4,
                          homeStyle: true,
                          emptyText: 'No trips in progress.\n'
                              'Tap the + button to book one.',
                          onRetry: () => ref.invalidate(myTripsProvider),
                        ),
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The carousel, with its own loading and error states so a failed fleet
/// request doesn't take the rest of the home screen down with it.
class _RecommendedVehicles extends StatelessWidget {
  final AsyncValue<List<VehicleDirectoryModel>> vehiclesAsync;
  final List<VehicleDirectoryModel> recommended;
  final VoidCallback onSeeAll;
  final VoidCallback onRetry;

  const _RecommendedVehicles({
    required this.vehiclesAsync,
    required this.recommended,
    required this.onSeeAll,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _InfoBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 26),
              const SizedBox(height: 6),
              const Text(
                'Could not load vehicles',
                style:
                TextStyle(color: AppColors.homeTextDark, fontSize: 13),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
        data: (_) {
          if (recommended.isEmpty) {
            return const _InfoBox(
              child: Text(
                'No vehicles have been added yet.',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: AppColors.homeTextMuted, fontSize: 12),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommended.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => RequesterVehicleCard(
              vehicle: recommended[index],
              width: 165,
              onTap: onSeeAll,
            ),
          );
        },
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Widget child;

  const _InfoBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.homeTileBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}