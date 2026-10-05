// features/instructor/presentation/screens/instructor_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../data/requester_trip_models.dart';
import '../providers/fleet_providers.dart';
import '../providers/requester_trip_providers.dart';
import '../widgets/schedule_header.dart';
import '../widgets/schedule_trip_card.dart';

const _pageBg = Color(0xFFF1F4FA);
const _ink = AppColors.homeNavy;
const _muted = Color(0xFF8A93A8);

final DateFormat _dayHeading = DateFormat('MMMM d, yyyy');

/// TODO: replace with the trip's real starting point once the API sends it.
const String kBaseLocation = 'Campus';

String _originOf(RequesterTrip item) => kBaseLocation;

/// The requester's trips grouped by travel date.
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  ScheduleTab _tab = ScheduleTab.all;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Upcoming = today or later and still going to happen.
  /// Past = an earlier day, or already finished / rejected.
  static bool _isUpcoming(RequesterTrip t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !_dayOf(t.trip.date).isBefore(today) &&
        !t.isCompleted &&
        !t.isRejected;
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(myTripsProvider);
    final vehicles =
        ref.watch(vehicleDirectoryProvider).valueOrNull ?? const [];
    final topInset = MediaQuery.of(context).padding.top;

    // Vehicle photos come from the fleet list, matched by plate number.
    final photoByPlate = <String, String>{
      for (final v in vehicles)
        if (ApiConfig.mediaUrl(v.imageUrl) != null)
          v.plateNumber.trim().toUpperCase(): ApiConfig.mediaUrl(v.imageUrl)!,
    };

    final trips = tripsAsync.valueOrNull ?? const <RequesterTrip>[];
    final upcoming = trips.where(_isUpcoming).toList();
    final past = trips.where((t) => !_isUpcoming(t)).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCount = trips.where((t) => _dayOf(t.trip.date) == today).length;

    const headerBody = 170.0;
    const tabsHeight = 50.0;
    final headerHeight = topInset + headerBody;

    return Scaffold(
      backgroundColor: _pageBg,
      body: RefreshIndicator(
        edgeOffset: topInset,
        onRefresh: () async {
          refreshMyTrips(ref);
          await ref.read(myTripsProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            // ---------------- HEADER + TABS ----------------
            SizedBox(
              height: headerHeight + tabsHeight / 2 + 6,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: headerHeight,
                    child: ScheduleHeader(
                      topInset: topInset,
                      backgroundAsset: AppMedia.scheduleHeaderImage,
                      todayCount: todayCount,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 6,
                    height: tabsHeight,
                    child: ScheduleTabBar(
                      selected: _tab,
                      allCount: trips.length,
                      upcomingCount: upcoming.length,
                      pastCount: past.length,
                      onSelect: (t) => setState(() => _tab = t),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- LIST ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: tripsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child:
                    CircularProgressIndicator(color: AppColors.homeNavy),
                  ),
                ),
                error: (err, _) => _ErrorBox(
                  message: err is ApiException
                      ? err.message
                      : 'Could not load your trips.',
                  onRetry: () => ref.invalidate(myTripsProvider),
                ),
                data: (_) {
                  final shown = switch (_tab) {
                    ScheduleTab.all => trips,
                    ScheduleTab.upcoming => upcoming,
                    ScheduleTab.past => past,
                  };
                  if (shown.isEmpty) return _EmptyBox(tab: _tab);

                  final byDate = <DateTime, List<RequesterTrip>>{};
                  for (final t in shown) {
                    byDate.putIfAbsent(_dayOf(t.trip.date), () => []).add(t);
                  }
                  // Upcoming reads forward in time; the others newest first.
                  final days = byDate.keys.toList()
                    ..sort((a, b) => _tab == ScheduleTab.upcoming
                        ? a.compareTo(b)
                        : b.compareTo(a));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final day in days) ...[
                        _DayHeader(date: day, count: byDate[day]!.length),
                        const SizedBox(height: 10),
                        for (final item in byDate[day]!)
                          ScheduleTripCard(
                            item: item,
                            origin: _originOf(item),
                            vehicleImageUrl: photoByPlate[
                            item.trip.vehiclePlate.trim().toUpperCase()],
                          ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- list bits

class _DayHeader extends StatelessWidget {
  final DateTime date;
  final int count;

  const _DayHeader({required this.date, required this.count});

  String? get _relative {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (date.difference(today).inDays) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case -1:
        return 'Yesterday';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rel = _relative;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                size: 11, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: _dayHeading.format(date)),
                  if (rel != null)
                    TextSpan(
                      text: '  ·  $rel',
                      style: const TextStyle(
                        color: AppColors.homeIconBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            count == 1 ? '1 trip' : '$count trips',
            style: const TextStyle(
              color: AppColors.homeIconBlue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final ScheduleTab tab;
  const _EmptyBox({required this.tab});

  @override
  Widget build(BuildContext context) {
    final text = switch (tab) {
      ScheduleTab.all =>
      'You have no trips yet.\nTap the + button to book one.',
      ScheduleTab.upcoming =>
      'No upcoming trips.\nTap the + button to book one.',
      ScheduleTab.past => 'No past trips yet.',
    };
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy_rounded, size: 46, color: _muted),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 26),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _ink, fontSize: 13),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: _ink)),
          ),
        ],
      ),
    );
  }
}