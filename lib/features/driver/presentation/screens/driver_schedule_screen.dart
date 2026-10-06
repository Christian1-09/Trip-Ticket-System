// features/driver/presentation/screens/driver_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/Notifications.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/TripInformation.dart';
import 'package:jtrips_app/features/driver/presentation/screens/DriverVehicleScreen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_history_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_profile_screen.dart';
import 'package:jtrips_app/features/notifications/presentation/notification_providers.dart';

import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';
import '../widgets/driver_history_widgets.dart' show showHistoryOptions;
import '../widgets/driver_home_widgets.dart' show DriverSearchBar;
import '../widgets/driver_schedule_card.dart';
import '../widgets/driver_schedule_widgets.dart';

const _pageBg = Color(0xFFF2F5FA);
const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);

enum _ScheduleFilter { all, today, awaiting, confirmed, ongoing }

extension on _ScheduleFilter {
  String get label => switch (this) {
    _ScheduleFilter.all => 'All trips',
    _ScheduleFilter.today => 'Today',
    _ScheduleFilter.awaiting => 'Awaiting you',
    _ScheduleFilter.confirmed => 'Confirmed',
    _ScheduleFilter.ongoing => 'On the road',
  };

  bool matches(DriverTrip t) {
    final now = DateTime.now();
    return switch (this) {
      _ScheduleFilter.all => true,
      _ScheduleFilter.today => t.trip.date.year == now.year &&
          t.trip.date.month == now.month &&
          t.trip.date.day == now.day,
      _ScheduleFilter.awaiting =>
      t.status == AdminTripStatus.headDriverApproved,
      _ScheduleFilter.confirmed => t.status == AdminTripStatus.driverAccepted,
      _ScheduleFilter.ongoing => t.status == AdminTripStatus.ongoing,
    };
  }
}

/// Upcoming and ongoing trips, soonest first.
class DriverScheduleScreen extends ConsumerStatefulWidget {
  const DriverScheduleScreen({super.key});

  @override
  ConsumerState<DriverScheduleScreen> createState() =>
      _DriverScheduleScreenState();
}

class _DriverScheduleScreenState extends ConsumerState<DriverScheduleScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _query = '';
  _ScheduleFilter _filter = _ScheduleFilter.all;

  bool _matchesQuery(DriverTrip t) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final trip = t.trip;
    return [
      trip.routeLabel,
      trip.requester.fullName,
      trip.vehicleModel,
      trip.vehiclePlate,
      trip.ticketNumber,
      trip.purpose,
    ].any((field) => field.toLowerCase().contains(q));
  }

  Future<void> _pickFilter() async {
    final picked = await showHistoryOptions<_ScheduleFilter>(
      context,
      title: 'Show trips',
      selected: _filter,
      options: [
        (_ScheduleFilter.all, _ScheduleFilter.all.label, Icons.list_alt_rounded),
        (_ScheduleFilter.today, _ScheduleFilter.today.label, Icons.today_rounded),
        (_ScheduleFilter.awaiting, _ScheduleFilter.awaiting.label,
        Icons.hourglass_top_rounded),
        (_ScheduleFilter.confirmed, _ScheduleFilter.confirmed.label,
        Icons.check_circle_outline),
        (_ScheduleFilter.ongoing, _ScheduleFilter.ongoing.label,
        Icons.directions_car_filled),
      ],
    );
    if (picked != null) setState(() => _filter = picked);
  }

  void _push(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(driverActiveTripsProvider);
    final profile = ref.watch(driverProfileProvider).valueOrNull;
    final unread = ref.watch(unreadNotificationCountProvider);

    final all = activeAsync.valueOrNull ?? const <DriverTrip>[];
    final shown =
    all.where((t) => _matchesQuery(t) && _filter.matches(t)).toList();

    final top = MediaQuery.of(context).padding.top;
    final headerHeight = 220 + top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _pageBg,
        drawer: DriverSideMenu(
          userName: profile?.fullName ?? 'Driver',
          driverCode: profile?.driverCode,
          items: [
            DriverMenuItem(
              icon: Icons.notifications_rounded,
              label: 'Notifications',
              badge: unread,
              onTap: () => _push(const Notifications()),
            ),
            DriverMenuItem(
              icon: Icons.history_rounded,
              label: 'Trip History',
              onTap: () => _push(const DriverHistoryScreen()),
            ),
            DriverMenuItem(
              icon: Icons.airport_shuttle_rounded,
              label: 'My Vehicle',
              onTap: () => _push(const DriverVehicleScreen()),
            ),
            DriverMenuItem(
              icon: Icons.person_rounded,
              label: 'My Profile',
              onTap: () => _push(const DriverProfileScreen()),
            ),
          ],
        ),
        body: Column(
          children: [
            ScheduleHeader(
              height: headerHeight,
              userName: profile?.fullName ?? '...',
              unreadCount: unread,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onBellTap: () => _push(const Notifications()),
            ),
            Transform.translate(
              offset: const Offset(0, -26),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DriverSearchBar(
                  onChanged: (v) => setState(() => _query = v),
                  onFilterTap: _pickFilter,
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: RefreshIndicator(
                  color: _blue,
                  onRefresh: () async {
                    refreshDriverData(ref);
                    await ref.read(driverActiveTripsProvider.future);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      ScheduleSectionHeader(
                        count: shown.length,
                        filterLabel: _filter.label,
                        onFilterTap: _pickFilter,
                      ),
                      const SizedBox(height: 12),
                      ..._buildList(activeAsync, shown),
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

  List<Widget> _buildList(
      AsyncValue<List<DriverTrip>> async, List<DriverTrip> shown) {
    return async.when(
      loading: () => const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator(color: _blue)),
        ),
      ],
      error: (err, _) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFE5394A), size: 34),
              const SizedBox(height: 8),
              Text(
                err is ApiException ? err.message : 'Could not load trips.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _navy, fontSize: 13),
              ),
              TextButton(
                onPressed: () => ref.invalidate(driverActiveTripsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
      data: (_) {
        if (shown.isEmpty) {
          final filtering = _query.isNotEmpty || _filter != _ScheduleFilter.all;
          return [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3ECFC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_available_rounded,
                        size: 38, color: _blue),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    filtering ? 'No trips match.' : 'Nothing scheduled.',
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filtering
                        ? 'Try a different search or filter.'
                        : 'New trips appear here once assigned.',
                    style: const TextStyle(color: _muted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ];
        }
        return [
          for (final t in shown)
            DriverScheduleCard(
              item: t,
              onTap: () => _push(TripInformation(tripId: t.id)),
            ),
        ];
      },
    );
  }
}