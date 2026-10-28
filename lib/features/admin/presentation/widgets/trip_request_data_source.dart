// features/admin/presentation/widgets/trip_request_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/admin_trip_model.dart';

class TripRequestDataSource extends DataGridSource {
  TripRequestDataSource({
    required List<AdminTripModel> requests,
    required this.onReviewTap,
    required this.onApprove,
    required this.onReject,
    this.busy = false,
  }) {
    _rows = requests
        .map<DataGridRow>((r) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: r.ticketNumber),
      DataGridCell<String>(columnName: 'requesting', value: r.requester.fullName),
      DataGridCell<String>(columnName: 'department', value: r.departmentCode),
      DataGridCell<String>(columnName: 'driver', value: r.driver.fullName),
      DataGridCell<AdminTripModel>(columnName: 'status', value: r),
      DataGridCell<AdminTripModel>(columnName: 'review', value: r),
      DataGridCell<AdminTripModel>(columnName: 'action', value: r),
    ]))
        .toList();
  }

  final void Function(AdminTripModel) onReviewTap;
  final void Function(AdminTripModel) onApprove;
  final void Function(AdminTripModel) onReject;
  final bool busy;

  List<DataGridRow> _rows = [];

  // Button colors from the mockup
  static const _reviewBlue = Color(0xFF2453E8);
  static const _rejectRed = Color(0xFFE53935);
  static const _approveGreen = Color(0xFF22943B);

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.white,
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'id':
            return _cellText(cell.value as String, bold: true);
          case 'requesting':
          case 'department':
          case 'driver':
            return _cellText(cell.value as String);
          case 'status':
            return Center(child: _statusBadge(cell.value as AdminTripModel));
          case 'review':
            final model = cell.value as AdminTripModel;
            return Center(
              child: _actionButton(
                label: 'Review Trip',
                color: _reviewBlue,
                onPressed: () => onReviewTap(model),
                horizontalPadding: 16,
              ),
            );
          case 'action':
            final model = cell.value as AdminTripModel;
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(
                    label: 'Reject',
                    color: _rejectRed,
                    onPressed: busy ? null : () => onReject(model),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    label: 'Approve',
                    color: _approveGreen,
                    onPressed: busy ? null : () => onApprove(model),
                  ),
                ],
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  Widget _cellText(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AdminColors.navy,
            fontSize: 13.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    double horizontalPadding = 18,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.4),
          disabledForegroundColor: Colors.white70,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _badge(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  /// Urgent is a flag, not a status, so it is shown as its own badge
  /// beside the real status.
  Widget _statusBadge(AdminTripModel trip) {
    // "Pending" in the mockup is a soft grey pill; other statuses use
    // a light tint of their own color with darker text.
    final isPending = trip.status.label.toLowerCase() == 'pending';
    final statusBg =
    isPending ? const Color(0xFFE5E8EF) : trip.status.color.withOpacity(0.15);
    final statusFg = isPending ? const Color(0xFF6B7280) : trip.status.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trip.isUrgent) ...[
          _badge('Urgent', bg: AdminColors.amber, fg: AdminColors.navy),
          const SizedBox(width: 8),
        ],
        _badge(trip.status.label, bg: statusBg, fg: statusFg),
      ],
    );
  }
}