// features/admin/presentation/widgets/trip_request_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'id':
            return _cellText(cell.value as String, bold: true);
          case 'requesting':
          case 'department':
          case 'driver':
            return _cellText(cell.value as String);
          case 'status':
            final model = cell.value as AdminTripModel;
            return Center(child: _statusBadge(model));
          case 'review':
            final model = cell.value as AdminTripModel;
            return Center(
              child: TextButton(
                onPressed: () => onReviewTap(model),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4EDB),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Review Trip',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            );
          case 'action':
            final model = cell.value as AdminTripModel;
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: busy ? null : () => onReject(model),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      disabledBackgroundColor: const Color(0xFFC62828).withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: busy ? null : () => onApprove(model),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: const Color(0xFF2E7D32).withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Approve',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  /// Urgent is a flag, not a status, so it is shown as its own badge
  /// beside the real status.
  Widget _statusBadge(AdminTripModel trip) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trip.isUrgent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF9A825),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Urgent',
                style: TextStyle(
                    color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: trip.status.color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(trip.status.label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}