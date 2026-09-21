// features/admin/presentation/widgets/driver_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../data/models/driver_model.dart';

class DriverDataSource extends DataGridSource {
  DriverDataSource({
    required List<AdminDriverModel> drivers,
    required this.onToggleStatus,
    required this.onChangeRole,
    this.headDriverExists = false,
    this.busy = false,
  }) {
    _rows = drivers
        .map<DataGridRow>((d) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'code', value: d.driverCode ?? '—'),
      DataGridCell<String>(columnName: 'name', value: d.fullName),
      DataGridCell<String>(columnName: 'contact', value: d.contact),
      DataGridCell<AdminDriverModel>(columnName: 'role', value: d),
      DataGridCell<String>(columnName: 'vehicle', value: d.vehicleLabel),
      DataGridCell<String>(columnName: 'trips', value: d.tripsLabel),
      DataGridCell<String>(columnName: 'rating', value: d.ratingLabel),
      DataGridCell<AdminDriverModel>(columnName: 'status', value: d),
      DataGridCell<AdminDriverModel>(columnName: 'action', value: d),
    ]))
        .toList();
  }

  /// Switches between AVAILABLE and OFF_DUTY.
  final void Function(AdminDriverModel driver) onToggleStatus;

  /// Promotes to HEAD_DRIVER or demotes back to DRIVER.
  final void Function(AdminDriverModel driver) onChangeRole;

  final bool headDriverExists;
  final bool busy;

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'role':
            final driver = cell.value as AdminDriverModel;
            return _cell(
              Text(
                driver.roleLabel,
                style: TextStyle(
                  color: driver.isHeadDriver ? const Color(0xFFFFD54F) : Colors.white,
                  fontSize: 12,
                  fontWeight: driver.isHeadDriver ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            );

          case 'status':
            final driver = cell.value as AdminDriverModel;
            return Center(child: _statusBadge(driver.status));

          case 'action':
            final driver = cell.value as AdminDriverModel;
            return Center(child: _actions(driver));

          default:
            return _cell(
              Text('${cell.value}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            );
        }
      }).toList(),
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }

  Widget _statusBadge(DriverStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withOpacity(0.6)),
      ),
      child: Text(status.label,
          style: TextStyle(color: status.color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actions(AdminDriverModel driver) {
    // A driver out on the road keeps ON_TRIP until the trip is completed.
    final canToggle = driver.canChangeStatus && !busy;

    // Only one head driver at a time: the promote option is hidden while
    // someone else holds the role.
    final canPromote = !driver.isHeadDriver && !headDriverExists && !busy;
    final canDemote = driver.isHeadDriver && !busy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: driver.canChangeStatus
              ? (driver.status == DriverStatus.offDuty
              ? 'Set available'
              : 'Set off duty')
              : 'On a trip — status is set by the system',
          child: TextButton(
            onPressed: canToggle ? () => onToggleStatus(driver) : null,
            style: TextButton.styleFrom(
              backgroundColor: driver.status == DriverStatus.offDuty
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF546E7A),
              disabledBackgroundColor: Colors.white12,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              driver.status == DriverStatus.offDuty ? 'Set Available' : 'Set Off Duty',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (canDemote)
          TextButton(
            onPressed: () => onChangeRole(driver),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8E24AA),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Demote',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          )
        else
          Tooltip(
            message: headDriverExists
                ? 'A head driver already exists — demote them first'
                : 'Promote to Head Driver',
            child: TextButton(
              onPressed: canPromote ? () => onChangeRole(driver) : null,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF3B4EDB),
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Make Head',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
      ],
    );
  }
}