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
  // Actions
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

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trip Request',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Text(
                          tripsAsync.when(
                            data: (trips) => trips.isEmpty
                                ? 'No pending requests'
                                : '${trips.length} pending approval',
                            loading: () => 'Loading...',
                            error: (_, __) => 'Could not load requests',
                          ),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidate(pendingTripsProvider),
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filters row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search ticket, requester, driver, destination...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.white38, size: 18),
                        filled: true,
                        fillColor: const Color(0xFF141B4D),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                      ),
                      onChanged: (val) =>
                      ref.read(tripRequestSearchProvider.notifier).state = val,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _filterDropdown(
                    value: ref.watch(tripRequestUrgencyFilterProvider),
                    items: const ['All', 'Urgent', 'Normal'],
                    onChanged: (val) => ref
                        .read(tripRequestUrgencyFilterProvider.notifier)
                        .state = val!,
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141B4D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: tripsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _errorView(err),
                    data: (_) => filtered.isEmpty
                        ? _emptyView()
                        : SfDataGridTheme(
                      data: SfDataGridThemeData(
                        headerColor: const Color(0xFF1E2761),
                        gridLineColor: Colors.white12,
                        gridLineStrokeWidth: 0.5,
                      ),
                      child: SfDataGrid(
                        source: TripRequestDataSource(
                          requests: filtered,
                          busy: _busy,
                          onReviewTap: (model) =>
                              setState(() => _reviewingTripId = model.id),
                          onApprove: _openApproveDialog,
                          onReject: _openRejectDialog,
                        ),
                        columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: 46,
                        rowHeight: 56,
                        columns: [
                          _column('id', 'Ticket', width: 130),
                          _column('requesting', 'Requesting'),
                          _column('department', 'Dept', width: 90),
                          _column('driver', 'Driver'),
                          _column('status', 'Status',
                              alignment: Alignment.center, width: 190),
                          _column('review', 'Review',
                              alignment: Alignment.center, width: 120),
                          _column('action', 'Action',
                              alignment: Alignment.center, width: 200),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_busy)
          Container(
            color: Colors.black38,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No pending trip requests right now.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }

  Widget _errorView(Object error) {
    final message = error is ApiException
        ? error.message
        : 'Could not load trip requests.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(pendingTripsProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B4EDB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: alignment,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF141B4D),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}