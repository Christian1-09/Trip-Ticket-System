// features/head_driver/presentation/screens/head_driver_all_trips_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../providers/head_driver_providers.dart';
import '../widgets/hd_trip_cards.dart';

/// Full list behind "View All". Watches the same provider, so approving,
/// rejecting or reassigning here updates both screens.
class HeadDriverAllTripsScreen extends ConsumerStatefulWidget {
  final String title;
  final bool declined;
  final String initialQuery;
  final bool urgentOnly;

  const HeadDriverAllTripsScreen({
    super.key,
    required this.title,
    required this.declined,
    this.initialQuery = '',
    this.urgentOnly = false,
  });

  @override
  ConsumerState<HeadDriverAllTripsScreen> createState() =>
      _HeadDriverAllTripsScreenState();
}

class _HeadDriverAllTripsScreenState extends ConsumerState<HeadDriverAllTripsScreen> {
  late final TextEditingController _searchController =
  TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;
  late bool _urgentOnly = widget.urgentOnly;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.declined ? hdDeclinedTripsProvider : hdPendingTripsProvider;
    final async = ref.watch(provider);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.homeNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Urgent trips only',
            onPressed: () => setState(() => _urgentOnly = !_urgentOnly),
            icon: Icon(
              Icons.tune_rounded,
              color: _urgentOnly ? AppColors.accentYellow : Colors.white,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.homeTextDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: AppColors.homeTextDark, fontSize: 14),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Search requester, destination, ticket…',
                        hintStyle:
                        TextStyle(color: AppColors.homeTextMuted, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(provider);
          await ref.read(provider.future);
        },
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                err is ApiException ? err.message : 'Could not load trips.',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
          data: (all) {
            final items = filterHdTrips(all, query: _query, urgentOnly: _urgentOnly);
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(32),
                children: [
                  Text(
                    all.isEmpty ? 'Nothing here right now.' : 'No trips match your search.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.homeTextMuted),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: items.length,
              itemBuilder: (_, i) =>
                  buildHdTripCard(context, ref, items[i], declined: widget.declined),
            );
          },
        ),
      ),
    );
  }
}