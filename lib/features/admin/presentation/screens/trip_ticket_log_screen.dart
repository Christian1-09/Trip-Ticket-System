// features/admin/presentation/screens/trip_ticket_log_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/core/theme/printing/print_trip_ticket.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/theme/admin_colors.dart';
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

    return ColoredBox(
      color: AdminColors.background,
      child: Padding(
        padding: const EdgeInsets.all(20),
        // The whole page sits in one big white card, like the mockup.
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AdminColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trip Ticket Log',
                            style: TextStyle(
                                color: AdminColors.navy,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          async.when(
                            data: (page) => page.total == 0
                                ? 'No tickets match this filter'
                                : '${page.total} ticket${page.total == 1 ? '' : 's'} · '
                                'page ${page.page} of ${page.pageCount}',
                            loading: () => 'Loading...',
                            error: (_, __) => 'Could not load the log',
                          ),
                          style: const TextStyle(
                              color: AdminColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidate(tripLogPageProvider(filter)),
                    icon: const Icon(Icons.refresh, color: AdminColors.blue, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Filters ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        style: const TextStyle(color: AdminColors.navy, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search ticket, requester, driver, plate, purpose...',
                          hintStyle: const TextStyle(
                              color: AdminColors.textMuted, fontSize: 14),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 14, right: 6),
                            child: Icon(Icons.search,
                                color: AdminColors.textMuted, size: 20),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8FC),
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: _border(AdminColors.border),
                          focusedBorder: _border(AdminColors.blue),
                        ),
                        // Searching resets to the first page, or you would land on
                        // an empty page 3 of a much shorter result set.
                        onSubmitted: (val) =>
                            update(filter.copyWith(search: val, offset: 0)),
                      ),
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
                          : filter.copyWith(from: range.start, to: range.end, offset: 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Table ──────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminColors.border),
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
                              const TextStyle(color: Colors.redAccent, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.invalidate(tripLogPageProvider(filter)),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AdminColors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Retry'),
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
                            style: TextStyle(
                                color: AdminColors.textMuted, fontSize: 14)),
                      ),
                    )
                        : SfDataGridTheme(
                      data: const SfDataGridThemeData(
                        headerColor: Color(0xFFF6F8FC),
                        gridLineColor: AdminColors.border,
                        gridLineStrokeWidth: 1,
                        rowHoverColor: Color(0xFFF9FAFD),
                      ),
                      child: SfDataGrid(
                        source: _TripLogDataSource(
                          trips: page.trips,
                          onPrint: (trip) => printTripTicket(context, ref, trip.id),
                        ),
                        gridLinesVisibility: GridLinesVisibility.horizontal,
                        headerGridLinesVisibility: GridLinesVisibility.horizontal,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: 44,
                        rowHeight: 46,
                        columns: [
                          _column('ticket', 'Ticket', width: 140),
                          _column('date', 'Date', width: 120),
                          _column('requester', 'Requester'),
                          _column('department', 'Dept', width: 90),
                          _column('driver', 'Driver'),
                          _column('vehicle', 'Vehicle', width: 110),
                          _column('status', 'Status', alignCenter: true, width: 160),
                          _column('printed', 'Printed', alignCenter: true, width: 100),
                          _column('action', 'Action', alignCenter: true, width: 110),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Footer: count + pager ─────────────────────────
              async.maybeWhen(
                data: (page) => page.total == 0
                    ? const SizedBox.shrink()
                    : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${page.offset + 1} to '
                            '${page.offset + page.trips.length} of ${page.total} '
                            'ticket${page.total == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: AdminColors.textMuted, fontSize: 13),
                      ),
                      const Spacer(),
                      _Pager(
                        page: page.page,
                        pageCount: page.pageCount,
                        onPrev: page.offset == 0
                            ? null
                            : () => update(filter.copyWith(
                            offset: (filter.offset - filter.limit)
                                .clamp(0, 1 << 30))),
                        onNext: !page.hasMore
                            ? null
                            : () => update(filter.copyWith(
                            offset: filter.offset + filter.limit)),
                        onPage: (p) => update(
                            filter.copyWith(offset: (p - 1) * filter.limit)),
                      ),
                    ],
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );

  GridColumn _column(String name, String label,
      {double? width, bool alignCenter = false}) {
    return GridColumn(
      columnName: name,
      width: width ?? double.nan,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: alignCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
                color: AdminColors.navy, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required Map<String, T> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          style: const TextStyle(
              color: AdminColors.navy, fontSize: 14, fontWeight: FontWeight.w500),
          icon: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.keyboard_arrow_down, color: AdminColors.navy, size: 20),
          ),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
              .toList(),
          onChanged: (val) => onChanged(val as T),
        ),
      ),
    );
  }
}

/// ‹  1 2 3  › — shows up to 5 page numbers around the current page.
class _Pager extends StatelessWidget {
  final int page;
  final int pageCount;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final ValueChanged<int> onPage;

  const _Pager({
    required this.page,
    required this.pageCount,
    required this.onPrev,
    required this.onNext,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    final count = math.max(pageCount, 1);
    final start = math.max(1, math.min(page - 2, count - 4));
    final end = math.min(count, start + 4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _box(child: const Icon(Icons.chevron_left, size: 18), onTap: onPrev),
        for (var p = start; p <= end; p++) ...[
          const SizedBox(width: 6),
          _box(
            selected: p == page,
            onTap: p == page ? null : () => onPage(p),
            child: Text('$p',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p == page ? Colors.white : AdminColors.navy)),
          ),
        ],
        const SizedBox(width: 6),
        _box(child: const Icon(Icons.chevron_right, size: 18), onTap: onNext),
      ],
    );
  }

  Widget _box({required Widget child, VoidCallback? onTap, bool selected = false}) {
    return Material(
      color: selected ? AdminColors.blue : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? AdminColors.blue : AdminColors.border),
          ),
          child: IconTheme(
            data: IconThemeData(
                color: onTap == null && !selected
                    ? const Color(0xFFB7BECF)
                    : AdminColors.navy),
            child: child,
          ),
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
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
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
            icon: const Icon(Icons.calendar_today_outlined,
                size: 17, color: AdminColors.navy),
            label: Text(
              hasRange
                  ? '${from!.month}/${from!.day} - ${to!.month}/${to!.day}'
                  : 'Any date',
              style: const TextStyle(
                  color: AdminColors.navy, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AdminColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        if (hasRange)
          IconButton(
            tooltip: 'Clear dates',
            onPressed: () => onPicked(null),
            icon: const Icon(Icons.close, size: 18, color: AdminColors.textMuted),
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
      DataGridCell<String>(columnName: 'requester', value: t.requester.fullName),
      DataGridCell<String>(
          columnName: 'department',
          // Blank instead of "—" keeps the column clean, like the mockup.
          value: t.departmentCode == '—' ? '' : t.departmentCode),
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

  /// Solid pills like the mockup. Pending is the only light one.
  static (Color bg, Color fg) _statusColors(AdminTripStatus s) {
    switch (s) {
      case AdminTripStatus.pending:
        return (const Color(0xFFDDE2EC), const Color(0xFF475069));
      case AdminTripStatus.adminApproved:
        return (const Color(0xFF6366F1), Colors.white);
      case AdminTripStatus.headDriverApproved:
        return (const Color(0xFF2453E8), Colors.white);
      case AdminTripStatus.driverAccepted:
        return (const Color(0xFF16A34A), Colors.white);
      case AdminTripStatus.driverDeclined:
        return (const Color(0xFFF97316), Colors.white);
      case AdminTripStatus.rejected:
        return (const Color(0xFFE53935), Colors.white);
      case AdminTripStatus.ongoing:
        return (const Color(0xFF14B8A6), Colors.white);
      case AdminTripStatus.completed:
        return (const Color(0xFF15803D), Colors.white);
      case AdminTripStatus.unknown:
        return (const Color(0xFF94A3B8), Colors.white);
    }
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.white,
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'status':
            final trip = cell.value as AdminTripModel;
            final (bg, fg) = _statusColors(trip.status);
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fixed-width slot so status pills line up whether or not
                  // the trip is urgent.
                  SizedBox(
                    width: 24,
                    child: trip.isUrgent
                        ? Tooltip(
                      message: 'Urgent',
                      child: Container(
                        width: 16,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AdminColors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('!',
                            style: TextStyle(
                                color: AdminColors.navy,
                                fontSize: 11,
                                fontWeight: FontWeight.w900)),
                      ),
                    )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(trip.status.label,
                        style: TextStyle(
                            color: fg, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );

          case 'printed':
            final trip = cell.value as AdminTripModel;
            return Center(
              child: trip.printedAt != null
                  ? const Icon(Icons.check_circle,
                  size: 18, color: Color(0xFF22C55E))
                  : const Text('–',
                  style: TextStyle(color: Color(0xFFA0A8BC), fontSize: 14)),
            );

          case 'action':
            final trip = cell.value as AdminTripModel;
            final canPrint = trip.status == AdminTripStatus.completed;
            return Center(
              child: Tooltip(
                message: canPrint
                    ? 'Print trip ticket'
                    : 'Only completed trips can be printed',
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: canPrint ? () => onPrint(trip) : null,
                    icon: const Icon(Icons.print_rounded, size: 15),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: AdminColors.blue,
                      disabledForegroundColor: const Color(0xFFA0A8BC),
                      disabledBackgroundColor: const Color(0xFFF1F3F8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            );

          default:
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${cell.value}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AdminColors.navy,
                        fontSize: 13,
                        fontWeight: cell.columnName == 'ticket'
                            ? FontWeight.w600
                            : FontWeight.w500)),
              ),
            );
        }
      }).toList(),
    );
  }
}