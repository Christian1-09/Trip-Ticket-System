// features/admin/presentation/screens/trip_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/admin/presentation/screens/review_trip_screen.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/approve_trip_dialog.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/reject_trip_dialog.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/theme/admin_colors.dart';
import '../providers/trip_request_provider.dart';
import '../widgets/trip_request_data_source.dart';

class TripRequestScreen extends ConsumerStatefulWidget {
  const TripRequestScreen({super.key});

  @override
  ConsumerState<TripRequestScreen> createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends ConsumerState<TripRequestScreen> {
  String? _reviewingTripId;
  bool _busy = false;

  // ------------------------------------------------------
  // Actions (unchanged)
  // ------------------------------------------------------

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  Future<void> _approve(AdminTripModel trip) async {
    setState(() => _busy = true);
    try {
      await ref.read(adminTripRepositoryProvider).approveTrip(trip.id);
      ref.invalidate(pendingTripsProvider);
      _showMessage('${trip.ticketNumber} approved.');
      if (_reviewingTripId == trip.id) {
        setState(() => _reviewingTripId = null);
      }
    } on ApiException catch (e) {
      // A 409 here means the driver or vehicle was taken by another trip
      // that got approved first — the message names the clashing ticket.
      _showMessage(e.message, error: true);
    } catch (_) {
      _showMessage('Could not approve this trip. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(AdminTripModel trip, String reason) async {
    setState(() => _busy = true);
    try {
      await ref.read(adminTripRepositoryProvider).rejectTrip(trip.id, reason);
      ref.invalidate(pendingTripsProvider);
      _showMessage('${trip.ticketNumber} rejected.');
      if (_reviewingTripId == trip.id) {
        setState(() => _reviewingTripId = null);
      }
    } on ApiException catch (e) {
      _showMessage(e.message, error: true);
    } catch (_) {
      _showMessage('Could not reject this trip. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openApproveDialog(AdminTripModel trip) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ApproveTripDialog(
        trip: trip,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: () {
          Navigator.of(dialogContext).pop();
          _approve(trip);
        },
      ),
    );
  }

  void _openRejectDialog(AdminTripModel trip) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RejectTripDialog(
        ticketNumber: trip.ticketNumber,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: (reason) {
          Navigator.of(dialogContext).pop();
          _reject(trip, reason);
        },
      ),
    );
  }

  // ------------------------------------------------------
  // Build
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_reviewingTripId != null) {
      return ReviewTripScreen(
        tripId: _reviewingTripId!,
        busy: _busy,
        onBack: () => setState(() => _reviewingTripId = null),
        onApprove: _openApproveDialog,
        onReject: _openRejectDialog,
      );
    }

    final tripsAsync = ref.watch(pendingTripsProvider);
    final filtered = ref.watch(filteredPendingTripsProvider);
    final departmentOptions = ref.watch(tripRequestDepartmentOptionsProvider);
    final departmentFilter = ref.watch(tripRequestDepartmentFilterProvider);

    return ColoredBox(
      color: AdminColors.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Trip Request',
                              style: TextStyle(
                                  color: AdminColors.navy,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            tripsAsync.when(
                              data: (trips) => trips.isEmpty
                                  ? 'No pending requests'
                                  : '${trips.length} pending approval',
                              loading: () => 'Loading...',
                              error: (_, __) => 'Could not load requests',
                            ),
                            style: const TextStyle(
                                color: AdminColors.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () => ref.invalidate(pendingTripsProvider),
                      icon: const Icon(Icons.refresh, color: AdminColors.navy, size: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Filters ──────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextField(
                          style: const TextStyle(color: AdminColors.navy, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search ticket, requester, driver, destination...',
                            hintStyle: const TextStyle(
                                color: AdminColors.textMuted, fontSize: 14),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 14, right: 8),
                              child: Icon(Icons.search,
                                  color: AdminColors.navy, size: 22),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: _fieldBorder(AdminColors.border),
                            focusedBorder: _fieldBorder(AdminColors.blue),
                          ),
                          onChanged: (val) =>
                          ref.read(tripRequestSearchProvider.notifier).state = val,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _filterDropdown(
                      value: ref.watch(tripRequestUrgencyFilterProvider),
                      items: const ['All', 'Urgent', 'Normal'],
                      onChanged: (val) => ref
                          .read(tripRequestUrgencyFilterProvider.notifier)
                          .state = val!,
                    ),
                    const SizedBox(width: 16),
                    _filterDropdown(
                      // The selected department can disappear when the list
                      // refreshes, so fall back to "All Department".
                      value: departmentOptions.contains(departmentFilter)
                          ? departmentFilter
                          : 'All Department',
                      items: departmentOptions,
                      onChanged: (val) => ref
                          .read(tripRequestDepartmentFilterProvider.notifier)
                          .state = val!,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Table card (only as tall as its rows) ────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AdminColors.cardShadow,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: tripsAsync.when(
                        loading: () => const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => _errorView(err),
                        data: (_) => filtered.isEmpty ? _emptyView() : _table(filtered),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _table(List<AdminTripModel> trips) {
    return SfDataGridTheme(
      data: const SfDataGridThemeData(
        headerColor: Colors.white,
        gridLineColor: AdminColors.border,
        gridLineStrokeWidth: 1,
        rowHoverColor: Color(0xFFF7F9FD),
      ),
      child: SfDataGrid(
        source: TripRequestDataSource(
          requests: trips,
          busy: _busy,
          onReviewTap: (model) => setState(() => _reviewingTripId = model.id),
          onApprove: _openApproveDialog,
          onReject: _openRejectDialog,
        ),
        shrinkWrapRows: true,
        verticalScrollPhysics: const NeverScrollableScrollPhysics(),
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
        columnWidthMode: ColumnWidthMode.fill,
        headerRowHeight: 56,
        rowHeight: 70,
        columns: [
          _column('id', 'Ticket', width: 150),
          _column('requesting', 'Requesting'),
          _column('department', 'Dept', width: 100),
          _column('driver', 'Driver'),
          _column('status', 'Status', alignment: Alignment.center, width: 200),
          _column('review', 'Review', alignment: Alignment.center, width: 150),
          _column('action', 'Action', alignment: Alignment.center, width: 210),
        ],
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );

  Widget _emptyView() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'No pending trip requests right now.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
      ),
    );
  }

  Widget _errorView(Object error) {
    final message =
    error is ApiException ? error.message : 'Could not load trip requests.';
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(pendingTripsProvider),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AdminColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  GridColumn _column(String name, String label,
      {double? width, AlignmentGeometry alignment = Alignment.centerLeft}) {
    return GridColumn(
      columnName: name,
      width: width ?? double.nan,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: alignment,
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF5B6582), fontSize: 13.5, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
              color: AdminColors.navy, fontSize: 14, fontWeight: FontWeight.w500),
          icon: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.keyboard_arrow_down, color: AdminColors.navy, size: 20),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}