// features/instructor/presentation/screens/my_trips_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

import '../../../../core/theme/media.dart';
import '../../data/requester_trip_models.dart';
import '../providers/requester_trip_providers.dart';
import '../widgets/requester_trip_cards.dart';

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF5B6478);
const _pageBg = Color(0xFFF2F5FA);
const _chipBg = Color(0xFFE6ECF5);

/// Every trip the requester has submitted, with a filter for the three
/// states they actually care about.
class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  String _filter = 'All';

  static const _filters = ['All', 'In Progress', 'Completed', 'Rejected'];

  List<RequesterTrip> _apply(List<RequesterTrip> trips) {
    switch (_filter) {
      case 'In Progress':
        return trips
            .where((t) =>
        t.status != AdminTripStatus.completed &&
            t.status != AdminTripStatus.rejected)
            .toList();
      case 'Completed':
        return trips.where((t) => t.status == AdminTripStatus.completed).toList();
      case 'Rejected':
        return trips.where((t) => t.status == AdminTripStatus.rejected).toList();
      default:
        return trips;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(myTripsProvider);
    final filtered = _apply(tripsAsync.valueOrNull ?? []);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Column(
          children: [
            const _Header(),
            _FilterBar(
              filters: _filters,
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _blue,
                onRefresh: () async {
                  refreshMyTrips(ref);
                  await ref.read(myTripsProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 24 + MediaQuery.of(context).padding.bottom),
                  children: buildRequesterTripCards(
                    tripsAsync,
                    override: filtered,
                    style: RequesterCardStyle.myTrips,
                    emptyText: _filter == 'All'
                        ? 'You have no trips yet.'
                        : 'No trips under "$_filter".',
                    onRetry: () => ref.invalidate(myTripsProvider),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDE9FA), _pageBg],
        ),
      ),
      child: Stack(
        children: [
          // Illustration on the right
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.70,
            // Fade the image out to the left and at the bottom so it
            // blends into the header instead of showing hard edges.
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Colors.black, Colors.black],
                stops: [0.0, 0.45, 1.0],
              ).createShader(rect),
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 0.75, 1.0],
                ).createShader(rect),
                child: Image.asset(
                  AppMedia.myTripHeader,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, __, ___) => Align(
                    alignment: const Alignment(0.6, 0.3),
                    child: Icon(Icons.airport_shuttle_rounded,
                        size: 90, color: _blue.withOpacity(0.12)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.white.withOpacity(0.9),
                  shape: const CircleBorder(),
                  elevation: 1,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.maybePop(context),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.arrow_back, color: _navy, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'My Trips',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage and track all your trips',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final value = filters[index];
          final isSelected = value == selected;
          return GestureDetector(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _blue : _chipBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: _blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : null,
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: isSelected ? Colors.white : _navy,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}