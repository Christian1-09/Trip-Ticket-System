// features/head_driver/presentation/screens/head_driver_approvals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/VehicleRequestSchedule.dart';
import '../../data/head_driver_models.dart';

import '../head_driver_actions.dart';
import '../providers/head_driver_providers.dart';
import 'head_driver_trip_detail_screen.dart';

/// The Head Driver's extra tab: trips waiting for his approval, and trips
/// whose driver declined and that need a replacement.
class HeadDriverApprovalsScreen extends ConsumerWidget {
  const HeadDriverApprovalsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(hdPendingTripsProvider);
    ref.invalidate(hdDeclinedTripsProvider);
    await Future.wait([
      ref.read(hdPendingTripsProvider.future),
      ref.read(hdDeclinedTripsProvider.future),
    ]);
  }

  void _openDetail(BuildContext context, HeadDriverTrip item, {required bool declined}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HeadDriverTripDetailScreen(item: item, isDeclined: declined),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(hdPendingTripsProvider);
    final declinedAsync = ref.watch(hdDeclinedTripsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const Text('Approvals',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              const Text('Pull down to refresh',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),

              // ---------- Needs a new driver ----------
              ..._section(
                context: context,
                ref: ref,
                title: 'Needs a new driver',
                emptyText: null, // hidden entirely when there is nothing
                async: declinedAsync,
                cardBuilder: (item) => VehicleRequestSchedule(
                  headerLabel: 'Driver Declined',
                  requesterName: item.trip.requester.fullName,
                  department: item.trip.departmentName,
                  date: item.trip.dateLabel,
                  time: '${item.trip.departureLabel} - ${item.trip.endTimeLabel}',
                  destination: item.trip.destinationLabel,
                  vehicleLabel: '${item.trip.vehicleModel} (${item.trip.vehiclePlate})',
                  driverName: item.declines.isEmpty
                      ? 'Declined'
                      : 'Declined by ${item.declines.first.driverName}',
                  isUrgent: item.trip.isUrgent,
                  onTap: () => _openDetail(context, item, declined: true),
                  extraActionLabel: 'Assign Driver',
                  onExtraAction: () => HeadDriverActions.assignDriver(context, ref, item),
                ),
              ),

              // ---------- Needs your approval ----------
              ..._section(
                context: context,
                ref: ref,
                title: 'Needs your approval',
                emptyText: 'Nothing waiting for your approval right now.',
                async: pendingAsync,
                cardBuilder: (item) => VehicleRequestSchedule(
                  requesterName: item.trip.requester.fullName,
                  department: item.trip.departmentName,
                  date: item.trip.dateLabel,
                  time: '${item.trip.departureLabel} - ${item.trip.endTimeLabel}',
                  destination: item.trip.destinationLabel,
                  vehicleLabel: '${item.trip.vehicleModel} (${item.trip.vehiclePlate})',
                  driverName: item.trip.driver.fullName,
                  isUrgent: item.trip.isUrgent,
                  onTap: () => _openDetail(context, item, declined: false),
                  onReject: () => HeadDriverActions.reject(context, ref, item),
                  onApprove: () => HeadDriverActions.approve(context, ref, item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _section({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String? emptyText,
    required AsyncValue<List<HeadDriverTrip>> async,
    required Widget Function(HeadDriverTrip) cardBuilder,
  }) {
    return async.when(
      loading: () => [
        const SizedBox(height: 24),
        const Center(child: CircularProgressIndicator()),
      ],
      error: (err, _) => [
        const SizedBox(height: 20),
        Text(
          err is ApiException ? err.message : 'Could not load "$title".',
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
      ],
      data: (items) {
        if (items.isEmpty && emptyText == null) return <Widget>[];
        return [
          const SizedBox(height: 20),
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusBlue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${items.length}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(emptyText!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            )
          else
            ...items.map(cardBuilder),
        ];
      },
    );
  }
}