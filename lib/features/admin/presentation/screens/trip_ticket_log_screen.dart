// features/admin/presentation/screens/trip_ticket_log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/core/theme/printing/print_trip_ticket.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../data/models/admin_trip_model.dart';
import '../../data/trip_log_repository.dart';
import '../providers/trip_log_provider.dart';

/// The full history of trip tickets, filterable and printable.
class TripTicketLogScreen extends ConsumerWidget {
  const TripTicketLogScreen({super.key});

  static const _statuses = {
    'All statuses': null,
    'Pending': 'PENDING',
    'With Head Driver': 'ADMIN_APPROVED',
    'With Driver': 'HEAD_DRIVER_APPROVED',
    'Accepted': 'DRIVER_ACCEPTED',
    'Declined': 'DRIVER_DECLINED',
    'Ongoing': 'ONGOING',
    'Completed': 'COMPLETED',
    'Rejected': 'REJECTED',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(tripLogFilterProvider);
    final async = ref.watch(tripLogPageProvider(filter));

    void update(TripLogFilter next) =>
        ref.read(tripLogFilterProvider.notifier).state = next;

    return Padding(
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
                    const Text('Trip Ticket Log',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Text(
                      async.when(
                        data: (page) => page.total == 0
                            ? 'No tickets match this filter'
                            : '${page.total} ticket${page.total == 1 ? '' : 's'} · '
                            'page ${page.page} of ${page.pageCount}',
                        loading: () => 'Loading...',
                        error: (_, __) => 'Could not load the log',
                      ),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () => ref.invalidate(tripLogPageProvider(filter)),
                icon: const Icon(Icons.refresh, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search ticket, requester, driver, plate, purpose...',
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
                  // Searching resets to the first page, or you would land on
                  // an empty page 3 of a much shorter result set.
                  onSubmitted: (val) =>
                      update(filter.copyWith(search: val, offset: 0)),
                ),
              ),
              const SizedBox(width: 12),
              _dropdown<String?>(
                value: filter.status,
                items: _statuses,
                onChanged: (val) => update(val == null
                    ? filter.copyWith(clearStatus: true, offset: 0)
                    : filter.copyWith(status: val, offset: 0)),
              ),
              const SizedBox(width: 12),
              _DateRangeButton(
                from: filter.from,
                to: filter.to,
                onPicked: (range) => update(
                  range == null
                      ? filter.copyWith(clearDates: true, offset: 0)
                      : filter.copyWith(
                      from: range.start, to: range.end, offset: 0),
                ),
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
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          err is ApiException
                              ? err.message
                              : 'Could not load the trip log.',
                          textAlign: TextAlign.center,
                          style:
                          const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(tripLogPageProvider(filter)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B4EDB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Retry',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (page) => page.trips.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No trip tickets match this filter.',
                        style:
                        TextStyle(color: Colors.white54, fontSize: 13)),
                  ),
                )
                    : SfDataGridTheme(
                  data: SfDataGridThemeData(
                    headerColor: const Color(0xFF1E2761),
                    gridLineColor: Colors.white12,
                    gridLineStrokeWidth: 0.5,
                  ),
                  child: SfDataGrid(
                    source: _TripLogDataSource(
                      trips: page.trips,
                      onPrint: (trip) =>
                          printTripTicket(context, ref, trip.id),
                    ),
                    columnWidthMode: ColumnWidthMode.fill,
                    headerRowHeight: 44,
                    rowHeight: 52,
                    columns: [
                      _column('ticket', 'Ticket', width: 130),
                      _column('date', 'Date', width: 110),
                      _column('requester', 'Requester'),
                      _column('department', 'Dept', width: 80),
                      _column('driver', 'Driver'),
                      _column('vehicle', 'Vehicle', width: 120),
                      _column('status', 'Status',
                          alignCenter: true, width: 170),
                      _column('printed', 'Printed',
                          alignCenter: true, width: 110),
                      _column('action', 'Action',
                          alignCenter: true, width: 110),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Paging
          async.maybeWhen(
            data: (page) => page.pageCount <= 1
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: page.offset == 0
                        ? null
                        : () => update(filter.copyWith(
                        offset:
                        (filter.offset - filter.limit).clamp(0, 1 << 30))),
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('Previous'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${page.page} / ${page.pageCount}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: !page.hasMore
                        ? null
                        : () => update(filter.copyWith(
                        offset: filter.offset + filter.limit)),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  GridColumn _column(String name, String label,
      {double? width, bool alignCenter = false}) {
    return GridColumn(
      columnName: name,
      width: width ?? double.nan,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: alignCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required Map<String, T> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF141B4D),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
              .toList(),
          onChanged: (val) => onChanged(val as T),
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTimeRange?> onPicked;

  const _DateRangeButton({
    required this.from,
    required this.to,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final hasRange = from != null && to != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              initialDateRange:
              hasRange ? DateTimeRange(start: from!, end: to!) : null,
            );
            if (range != null) onPicked(range);
          },
          icon: const Icon(Icons.date_range, size: 16, color: Colors.white70),
          label: Text(
            hasRange
                ? '${from!.month}/${from!.day} - ${to!.month}/${to!.day}'
                : 'Any date',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (hasRange)
          IconButton(
            tooltip: 'Clear dates',
            onPressed: () => onPicked(null),
            icon: const Icon(Icons.close, size: 16, color: Colors.white54),
          ),
      ],
    );
  }
}

class _TripLogDataSource extends DataGridSource {
  _TripLogDataSource({
    required List<AdminTripModel> trips,
    required this.onPrint,
  }) {
    _rows = trips
        .map<DataGridRow>((t) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'ticket', value: t.ticketNumber),
      DataGridCell<String>(columnName: 'date', value: t.dateLabel),
      DataGridCell<String>(
          columnName: 'requester', value: t.requester.fullName),
      DataGridCell<String>(columnName: 'department', value: t.departmentCode),
      DataGridCell<String>(columnName: 'driver', value: t.driver.fullName),
      DataGridCell<String>(columnName: 'vehicle', value: t.vehiclePlate),
      DataGridCell<AdminTripModel>(columnName: 'status', value: t),
      DataGridCell<AdminTripModel>(columnName: 'printed', value: t),
      DataGridCell<AdminTripModel>(columnName: 'action', value: t),
    ]))
        .toList();
  }

  final void Function(AdminTripModel) onPrint;
  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'status':
            final trip = cell.value as AdminTripModel;
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trip.isUrgent) ...[
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9A825),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text('!',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: trip.status.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(trip.status.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );

          case 'printed':
            final trip = cell.value as AdminTripModel;
            final printed = trip.printedAt != null;
            return Center(
              child: Icon(
                printed ? Icons.check_circle : Icons.remove,
                size: 16,
                color: printed ? const Color(0xFF2E7D32) : Colors.white24,
              ),
            );

          case 'action':
            final trip = cell.value as AdminTripModel;
            final canPrint = trip.status == AdminTripStatus.completed;
            return Center(
              child: Tooltip(
                message: canPrint
                    ? 'Print trip ticket'
                    : 'Only completed trips can be printed',
                child: TextButton.icon(
                  onPressed: canPrint ? () => onPrint(trip) : null,
                  icon: const Icon(Icons.print_rounded, size: 14),
                  label: const Text('Print', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF3B4EDB),
                    disabledForegroundColor: Colors.white30,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            );

          default:
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${cell.value}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            );
        }
      }).toList(),
    );
  }
}