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

  static const _textPrimary = Color(0xFF1F2937);
  static const _navy = Color(0xFF1A237E);

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.white,
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'status') {
          // Every row here is, by definition, pending — once approved or
          // rejected, the backend stops returning it in this list.
          return const Center(
            child: _StatusPill(
              label: 'Pending',
              background: Color(0xFFFFF4DB),
              foreground: Color(0xFFB7791F),
            ),
          );
        }

        if (cell.columnName == 'action') {
          final user = cell.value as RequestModel;
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  label: 'Reject',
                  background: const Color(0xFFEEF0F6),
                  foreground: const Color(0xFFDC2626),
                  onPressed: () => onReject(user),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Approve',
                  background: const Color(0xFF9C27F0),
                  foreground: Colors.white,
                  onPressed: () => onApprove(user),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${cell.value}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cell.columnName == 'name' ? _navy : _textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  const _StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          label,
          style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}