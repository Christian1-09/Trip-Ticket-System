// features/head_driver/presentation/head_driver_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/reject_trip_dialog.dart';

import '../data/head_driver_models.dart';
import 'providers/head_driver_providers.dart';

/// Approve / reject / reassign, shared by the list and the detail screen so
/// both behave exactly the same. Each returns true when the action succeeded.
class HeadDriverActions {
  HeadDriverActions._();

  static void _message(BuildContext context, String text, {bool error = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  static Future<bool> _run(
      BuildContext context,
      WidgetRef ref,
      Future<void> Function() action,
      String success,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await action();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      ref.invalidate(hdPendingTripsProvider);
      ref.invalidate(hdDeclinedTripsProvider);
      _message(context, success);
      return true;
    } on ApiException catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      _message(context, e.message, error: true);
    } catch (_) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      _message(context, 'Something went wrong. Please try again.', error: true);
    }
    return false;
  }

  static Future<bool> approve(BuildContext context, WidgetRef ref, HeadDriverTrip item) async {
    final trip = item.trip;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDeepBlue,
        title: const Text('Approve this trip?', style: TextStyle(color: Colors.white)),
        content: Text(
          '${trip.ticketNumber} will be sent to ${trip.driver.fullName} to accept, '
              'using ${trip.vehicleModel} (${trip.vehiclePlate}) on ${trip.dateLabel}.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Approve', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    return _run(
      context,
      ref,
          () => ref.read(headDriverRepositoryProvider).approveTrip(trip.id),
      '${trip.ticketNumber} approved and sent to the driver.',
    );
  }

  static Future<bool> reject(BuildContext context, WidgetRef ref, HeadDriverTrip item) async {
    final trip = item.trip;
    String? reason;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RejectTripDialog(
        ticketNumber: trip.ticketNumber,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: (value) {
          reason = value;
          Navigator.of(dialogContext).pop();
        },
      ),
    );
    if (reason == null || !context.mounted) return false;

    return _run(
      context,
      ref,
          () => ref.read(headDriverRepositoryProvider).rejectTrip(trip.id, reason!),
      '${trip.ticketNumber} rejected. The requester and admin were notified.',
    );
  }

  static Future<bool> assignDriver(
      BuildContext context, WidgetRef ref, HeadDriverTrip item) async {
    final trip = item.trip;

    final picked = await showModalBottomSheet<ReplacementDriver>(
      context: context,
      backgroundColor: AppColors.cardDeepBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => _ReplacementDriverSheet(tripId: trip.id),
    );
    if (picked == null || !context.mounted) return false;

    return _run(
      context,
      ref,
          () => ref.read(headDriverRepositoryProvider).reassignDriver(trip.id, picked.id),
      '${picked.fullName} assigned to ${trip.ticketNumber}.',
    );
  }
}

class _ReplacementDriverSheet extends ConsumerWidget {
  final String tripId;
  const _ReplacementDriverSheet({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(hdReplacementDriversProvider(tripId));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assign a new driver',
                style: TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'Only drivers free at this time are shown. Drivers who declined '
                  'this trip are hidden.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: driversAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        err is ApiException ? err.message : 'Could not load drivers.',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(hdReplacementDriversProvider(tripId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (drivers) => drivers.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No driver is free for this trip\'s schedule.',
                    style: TextStyle(color: AppColors.accentYellow),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  itemCount: drivers.length,
                  separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (_, index) {
                    final driver = drivers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.statusBlue.withOpacity(0.3),
                        child: Text(
                          driver.fullName.isNotEmpty ? driver.fullName[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(driver.label,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(driver.phone ?? 'No contact number',
                          style: const TextStyle(color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => Navigator.of(context).pop(driver),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}