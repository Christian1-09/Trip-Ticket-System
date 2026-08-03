// features/admin/presentation/widgets/trip_request_data_source.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/admin/presentation/screens/trip_request_screen.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../data/models/trip_request_model.dart';

class TripRequestDataSource extends DataGridSource {

  TripRequestDataSource({
    required List<TripRequestModel> requests,
        required this.onReviewTap,
      }) {
    _rows = requests
        .map<DataGridRow>((r) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: r.id),
      DataGridCell<String>(columnName: 'requesting', value: r.requestingPerson),
      DataGridCell<String>(columnName: 'department', value: r.department),
      DataGridCell<String>(columnName: 'driver', value: r.driver),
      DataGridCell<TripRequestModel>(columnName: 'status', value: r),
      DataGridCell<TripRequestModel>(columnName: 'review', value: r),
      DataGridCell<TripRequestModel>(columnName: 'action', value: r),
    ]))
        .toList();
  }
  final void Function(TripRequestModel) onReviewTap;
  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'id':
            return _cellText(cell.value, bold: true);
          case 'requesting':
          case 'department':
          case 'driver':
            return _cellText(cell.value);
          case 'status':
            final model = cell.value as TripRequestModel;
            return Center(child: _statusBadge(model.status));
          case 'review':
            final model = cell.value as TripRequestModel;
            return Center(
              child: TextButton(
                onPressed: () => onReviewTap(model), // placeholder
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4EDB),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Review Trip', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            );
          case 'action':
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {}, // placeholder
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () {}, // placeholder
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 11)),
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
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _statusBadge(TripRequestStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: status.color, borderRadius: BorderRadius.circular(6)),
      child: Text(status.label,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}