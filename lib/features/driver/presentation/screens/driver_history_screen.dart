// features/driver/presentation/screens/driver_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/TripInformation.dart';

import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';
import '../widgets/driver_history_widgets.dart';
import '../widgets/driver_schedule_card.dart';

/// Past trips, most recent first, with search, filters and stats.
class DriverHistoryScreen extends ConsumerStatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  ConsumerState<DriverHistoryScreen> createState() =>
      _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends ConsumerState<DriverHistoryScreen> {
  String _query = '';
  HistoryTab _tab = HistoryTab.all;
  HistoryPeriod _period = HistoryPeriod.allTime;
  HistorySort _sort = HistorySort.newest;

  bool _matchesQuery(DriverTrip t) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final trip = t.trip;
    return [
      trip.routeLabel,
      trip.requester.fullName,
      trip.driver.fullName,
      trip.vehicleModel,
      trip.vehiclePlate,
      trip.ticketNumber,
      trip.purpose,
    ].any((field) => field.toLowerCase().contains(q));
  }

  bool _matchesTab(DriverTrip t) => switch (_tab) {
    HistoryTab.all => true,
    HistoryTab.completed => isCompletedTrip(t),
    HistoryTab.cancelled => isCancelledTrip(t),
  };

  List<DriverTrip> _sorted(List<DriverTrip> list) {
    final copy = [...list];
    switch (_sort) {
      case HistorySort.newest:
        copy.sort((a, b) => b.trip.departureTime.compareTo(a.trip.departureTime));
      case HistorySort.oldest:
        copy.sort((a, b) => a.trip.departureTime.compareTo(b.trip.departureTime));
      case HistorySort.longestDistance:
        copy.sort((a, b) => (b.arrival?.distanceTraveledKm ?? 0)
            .compareTo(a.arrival?.distanceTraveledKm ?? 0));
    }
    return copy;
  }

  Future<void> _pickPeriod() async {
    final picked = await showHistoryOptions<HistoryPeriod>(
      context,
      title: 'Filter by date',
      selected: _period,
      options: [
        (HistoryPeriod.allTime, HistoryPeriod.allTime.label, Icons.all_inclusive),
        (HistoryPeriod.thisMonth, HistoryPeriod.thisMonth.label, Icons.calendar_today),
        (HistoryPeriod.last30Days, HistoryPeriod.last30Days.label, Icons.date_range),
        (HistoryPeriod.thisYear, HistoryPeriod.thisYear.label, Icons.event_note),
      ],
    );
    if (picked != null) setState(() => _period = picked);
  }

  Future<void> _pickSort() async {
    final picked = await showHistoryOptions<HistorySort>(
      context,
      title: 'Sort trips',
      selected: _sort,
      options: [
        (HistorySort.newest, HistorySort.newest.label, Icons.arrow_downward),
        (HistorySort.oldest, HistorySort.oldest.label, Icons.arrow_upward),
        (HistorySort.longestDistance, HistorySort.longestDistance.label, Icons.route),
      ],
    );
    if (picked != null) setState(() => _sort = picked);
  }

  void _open(DriverTrip t) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TripInformation(tripId: t.id)),
  );

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(driverHistoryTripsProvider);
    final all = historyAsync.valueOrNull ?? const <DriverTrip>[];

    // Stats always use every trip, not the filtered list.
    final now = DateTime.now();
    final completedTrips = all.where(isCompletedTrip).toList();
    final thisMonth = completedTrips
        .where((t) => t.trip.date.year == now.year && t.trip.date.month == now.month)
        .length;
    final totalKm = completedTrips.fold<double>(
        0, (sum, t) => sum + (t.arrival?.distanceTraveledKm ?? 0));

    // Search + date filter first, so the tab counts match what you see.
    final searched = all
        .where((t) => _matchesQuery(t) && _period.includes(t.trip.date))
        .toList();
    final counts = {
      HistoryTab.all: searched.length,
      HistoryTab.completed: searched.where(isCompletedTrip).length,
      HistoryTab.cancelled: searched.where(isCancelledTrip).length,
    };
    final shown = _sorted(searched.where(_matchesTab).toList());

    final top = MediaQuery.of(context).padding.top;
    final headerHeight = 190 + top;
    final canPop = Navigator.of(context).canPop();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kHPageBg,
        body: RefreshIndicator(
          color: kHBlue,
          edgeOffset: top,
          onRefresh: () async {
            ref.invalidate(driverHistoryTripsProvider);
            await ref.read(driverHistoryTripsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              // Header with the stats card overlapping its bottom edge.
              Stack(
                children: [
                  HistoryHeader(
                    height: headerHeight,
                    onBack: canPop ? () => Navigator.of(context).pop() : null,
                  ),
                  Padding(
                    padding:
                    EdgeInsets.fromLTRB(16, headerHeight - 52, 16, 0),
                    child: HistoryStatsCard(
                      completed: completedTrips.length,
                      thisMonth: thisMonth,
                      totalKm: totalKm,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HistorySearchRow(
                      onChanged: (v) => setState(() => _query = v),
                      onFilterTap: _pickPeriod,
                      onSortTap: _pickSort,
                      filterActive: _period != HistoryPeriod.allTime,
                      sortActive: _sort != HistorySort.newest,
                    ),
                    const SizedBox(height: 12),
                    HistoryTabs(
                      selected: _tab,
                      counts: counts,
                      onSelected: (tab) => setState(() => _tab = tab),
                    ),
                    if (_period != HistoryPeriod.allTime) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InputChip(
                          label: Text(_period.label),
                          labelStyle: const TextStyle(
                            color: kHBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: const Color(0xFFE8F0FD),
                          side: BorderSide.none,
                          deleteIconColor: kHBlue,
                          onDeleted: () =>
                              setState(() => _period = HistoryPeriod.allTime),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ..._buildList(historyAsync, shown),
                  ],
                ),
              ),
            ],
          ),
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
          child: Center(child: CircularProgressIndicator(color: kHBlue)),
        ),
      ],
      error: (err, _) => [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: kHRed, size: 34),
              const SizedBox(height: 8),
              Text(
                err is ApiException ? err.message : 'Could not load your trips.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kHNavy, fontSize: 13),
              ),
              TextButton(
                onPressed: () => ref.invalidate(driverHistoryTripsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
      data: (_) {
        if (shown.isEmpty) {
          final filtering = _query.isNotEmpty ||
              _period != HistoryPeriod.allTime ||
              _tab != HistoryTab.all;
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
                    child: const Icon(Icons.history_rounded,
                        size: 38, color: kHBlue),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    filtering ? 'No trips match your search.' : 'No trips yet.',
                    style: const TextStyle(
                      color: kHNavy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filtering
                        ? 'Try a different search or filter.'
                        : 'Trips you finish will show up here.',
                    style: const TextStyle(color: kHMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ];
        }
        return [
          for (final t in shown)
            DriverScheduleCard(item: t, onTap: () => _open(t)),
        ];
      },
    );
  }
}