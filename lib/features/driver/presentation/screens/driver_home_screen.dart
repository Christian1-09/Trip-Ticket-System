// features/driver/presentation/screens/driver_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/All_Trip_Request.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/Notifications.dart';

import '../providers/driver_trip_providers.dart';
import '../widgets/driver_home_widgets.dart';
import '../widgets/driver_trip_cards.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(driverProfileProvider);
    final activeAsync = ref.watch(driverActiveTripsProvider);

    final profile = profileAsync.valueOrNull;
    final active = activeAsync.valueOrNull ?? [];
    final now = DateTime.now();
    final todayCount = active
        .where((t) =>
    t.trip.date.year == now.year &&
        t.trip.date.month == now.month &&
        t.trip.date.day == now.day)
        .length;

    void openAll() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllTripRequest()),
    );

    final awaiting = profile?.awaitingCount ?? 0;
    final upcoming = profile?.upcomingCount ?? 0;
    final completed = profile?.completedCount ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kDhPageBg,
        body: Column(
          children: [
            DriverHomeHeader(
              userName: profile?.fullName ?? '...',
              driverId: profile?.driverCode ?? '',
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Notifications()),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -26),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DriverSearchBar(onFilterTap: () {}),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -14),
                child: RefreshIndicator(
                  color: kDhBlue,
                  onRefresh: () async {
                    refreshDriverData(ref);
                    await ref.read(driverActiveTripsProvider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      DriverStatsRow(items: [
                        DriverStat(
                          icon: Icons.calendar_month_rounded,
                          color: kDhBlue,
                          label: 'NEW',
                          value: '$awaiting',
                          caption: 'Pending trips',
                          onTap: openAll,
                        ),
                        DriverStat(
                          icon: Icons.schedule_rounded,
                          color: kDhYellow,
                          label: 'UPCOMING',
                          value: '$upcoming',
                          caption: 'Upcoming trips',
                          onTap: openAll,
                        ),
                        DriverStat(
                          icon: Icons.check_circle_outline_rounded,
                          color: kDhGreen,
                          label: 'COMPLETED',
                          value: '$completed',
                          caption: 'Completed trips',
                          onTap: openAll,
                        ),
                      ]),
                      const SizedBox(height: 14),
                      GridView.count(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.55,
                        children: [
                          DriverActionTile(
                            icon: Icons.calendar_month_rounded,
                            iconBg: kDhYellow,
                            iconColor: kDhNavy,
                            watermark: Icons.event_note_rounded,
                            title: 'New Bookings',
                            subtitle: '$awaiting awaiting you',
                            onTap: openAll,
                          ),
                          DriverActionTile(
                            icon: Icons.event_available_rounded,
                            iconBg: kDhBlue,
                            iconColor: Colors.white,
                            watermark: Icons.calendar_month_rounded,
                            title: 'Today',
                            subtitle:
                            '$todayCount trip${todayCount == 1 ? '' : 's'} today',
                            onTap: openAll,
                          ),
                          DriverActionTile(
                            icon: Icons.location_on_rounded,
                            iconBg: kDhBlue,
                            iconColor: Colors.white,
                            watermark: Icons.map_rounded,
                            title: 'Navigation',
                            subtitle: 'Open map',
                            onTap: () {}, // GPS feature, later
                          ),
                          DriverActionTile(
                            icon: Icons.star_rounded,
                            iconBg: kDhBlue,
                            iconColor: Colors.white,
                            watermark: Icons.star_rounded,
                            title: 'My Performance',
                            subtitle: profile?.ratingLabel ?? '—',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DriverSectionHeader(
                        title: 'Assigned Trips',
                        count: active.length,
                        onViewAll: openAll,
                      ),
                      const SizedBox(height: 12),
                      ...buildDriverTripCards(
                        activeAsync,
                        limit: 3,
                        homeStyle: true,
                        emptyText: 'No trips assigned to you right now.',
                        onRetry: () => ref.invalidate(driverActiveTripsProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}