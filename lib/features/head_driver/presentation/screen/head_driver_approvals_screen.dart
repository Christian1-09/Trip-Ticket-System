// features/head_driver/presentation/screens/head_driver_approvals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../data/head_driver_models.dart';
import '../providers/head_driver_providers.dart';
import '../widgets/hd_hero_header.dart';
import '../widgets/hd_trip_cards.dart';
import 'head_driver_all_trips_screen.dart';

/// The Head Driver's extra tab: trips waiting for his approval, and trips
/// whose driver declined and that need a replacement.
class HeadDriverApprovalsScreen extends ConsumerStatefulWidget {
  /// Name shown in "Good Morning, <name>!" — pass the logged-in user's name.
  final String userName;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const HeadDriverApprovalsScreen({
    super.key,
    this.userName = 'Head Driver',
    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  ConsumerState<HeadDriverApprovalsScreen> createState() =>
      _HeadDriverApprovalsScreenState();
}

class _HeadDriverApprovalsScreenState extends ConsumerState<HeadDriverApprovalsScreen> {
  /// How many cards each section shows before "View All".
  static const _previewCount = 3;

  final _searchController = TextEditingController();
  String _query = '';
  bool _urgentOnly = false;

  bool get _isFiltering => _query.trim().isNotEmpty || _urgentOnly;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(hdPendingTripsProvider);
    ref.invalidate(hdDeclinedTripsProvider);
    await Future.wait([
      ref.read(hdPendingTripsProvider.future),
      ref.read(hdDeclinedTripsProvider.future),
    ]);
  }

  void _toggleUrgentOnly() {
    setState(() => _urgentOnly = !_urgentOnly);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(_urgentOnly ? 'Showing urgent trips only' : 'Showing all trips'),
        duration: const Duration(seconds: 1),
      ));
  }

  void _openAll({required String title, required bool declined}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HeadDriverAllTripsScreen(
          title: title,
          declined: declined,
          initialQuery: _query,
          urgentOnly: _urgentOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(hdPendingTripsProvider);
    final declinedAsync = ref.watch(hdDeclinedTripsProvider);
    final waiting = ref.watch(hdWaitingCountProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              HdHeroHeader(
                name: widget.userName,
                subtitle: 'Here are the trips waiting for your approval.',
                notificationCount: waiting,
                searchController: _searchController,
                onSearchChanged: (v) => setState(() => _query = v),
                filterActive: _urgentOnly,
                onFilterTap: _toggleUrgentOnly,
                onMenuTap: widget.onMenuTap,
                onNotificationTap: widget.onNotificationTap,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Needs a new driver (hidden when empty) ----------
                    ..._section(
                      title: 'Needs a New Driver',
                      icon: Icons.person_search_rounded,
                      async: declinedAsync,
                      declined: true,
                      emptyText: null,
                    ),

                    // ---------- Needs your approval ----------
                    ..._section(
                      title: 'Needs Your Approval',
                      icon: Icons.event_note_rounded,
                      async: pendingAsync,
                      declined: false,
                      emptyText: 'Nothing waiting for your approval right now.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _section({
    required String title,
    required IconData icon,
    required AsyncValue<List<HeadDriverTrip>> async,
    required bool declined,
    required String? emptyText,
  }) {
    return async.when(
      loading: () => [
        const SizedBox(height: 20),
        _SectionHeader(title: title, icon: icon),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (err, _) => [
        const SizedBox(height: 20),
        _SectionHeader(title: title, icon: icon),
        const SizedBox(height: 8),
        Text(
          err is ApiException ? err.message : 'Could not load "$title".',
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
      ],
      data: (all) {
        final items = filterHdTrips(all, query: _query, urgentOnly: _urgentOnly);
        if (items.isEmpty && emptyText == null) return <Widget>[];

        final preview = items.take(_previewCount);
        return [
          const SizedBox(height: 20),
          _SectionHeader(
            title: title,
            icon: icon,
            count: items.length,
            onViewAll: items.length > _previewCount
                ? () => _openAll(title: title, declined: declined)
                : null,
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _isFiltering ? 'No trips match your search.' : emptyText!,
                style: const TextStyle(color: AppColors.homeTextMuted, fontSize: 13),
              ),
            )
          else
            ...preview.map((item) => buildHdTripCard(context, ref, item, declined: declined)),
        ];
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.count,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.homeTileBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.homeNavy, size: 20),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.homeTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if ((count ?? 0) > 0) ...[
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.homeIconBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.homeIconBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.homeIconBlue),
                ],
              ),
            ),
          ),
      ],
    );
  }
}