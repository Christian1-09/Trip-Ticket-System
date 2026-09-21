// features/admin/presentation/widgets/user_driver_data_source.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:jtrips_app/features/admin/data/models/request_model.dart';

class UserDriverDataSource extends DataGridSource {
  UserDriverDataSource({
    required List<RequestModel> users,
    required this.onReject,
    required this.onApprove,
  }) {
    _rows = users
        .map<DataGridRow>((u) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: u.id.substring(0, 8)),
      DataGridCell<String>(columnName: 'name', value: u.fullName),
      DataGridCell<String>(columnName: 'email', value: u.email),
      DataGridCell<String>(columnName: 'phone', value: u.phone ?? '—'),
      DataGridCell<String>(
        columnName: 'date',
        value: DateFormat('MMM d, yyyy').format(u.createdAt),
      ),
      DataGridCell<RequestModel>(columnName: 'status', value: u),
      DataGridCell<RequestModel>(columnName: 'action', value: u),
    ]))
        .toList();
  }

  final void Function(RequestModel user) onReject;
  final void Function(RequestModel user) onApprove;

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'status') {
          // Every row here is, by definition, pending — once approved or
          // rejected, the backend stops returning it in this list.
          return const Center(
            child: _StatusBadge(label: 'Pending', color: Color(0xFFF9A825)),
          );
        }

        if (cell.columnName == 'action') {
          final user = cell.value as RequestModel;
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => onReject(user),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => onApprove(user),
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
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${cell.value}', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}