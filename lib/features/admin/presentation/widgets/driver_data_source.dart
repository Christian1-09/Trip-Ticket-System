// features/admin/presentation/widgets/driver_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/theme/admin_colors.dart';
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

  // Mockup colors
  static const _headDriverOrange = Color(0xFFF59E0B);
  static const _greyButton = Color(0xFFECEFF5);
  static const _greenButton = Color(0xFF22943B);
  static const _demotePurple = Color(0xFF9C1AD6);
  static const _disabledBg = Color(0xFFE5E8EF);

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Colors.white,
      cells: row.getCells().map<Widget>((cell) {
        switch (cell.columnName) {
          case 'role':
            final driver = cell.value as AdminDriverModel;
            return _cell(
              Text(
                driver.roleLabel,
                style: TextStyle(
                  color: driver.isHeadDriver ? _headDriverOrange : AdminColors.navy,
                  fontSize: 13,
                  fontWeight: driver.isHeadDriver ? FontWeight.w700 : FontWeight.w500,
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
                  style: const TextStyle(
                      color: AdminColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
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

  /// Soft pill: light tint of the status color, no border (like the mockup).
  Widget _statusBadge(DriverStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.label,
          style: TextStyle(
              color: status.color, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }

  Widget _button({
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback? onPressed,
    Color? disabledBg,
    Color? disabledFg,
  }) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: disabledBg ?? _disabledBg,
          disabledForegroundColor: disabledFg ?? const Color(0xFFA0A8BC),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(0, 34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _actions(AdminDriverModel driver) {
    // A driver out on the road keeps ON_TRIP until the trip is completed.
    final canToggle = driver.canChangeStatus && !busy;

    // Only one head driver at a time: the promote option is disabled while
    // someone else holds the role.
    final canPromote = !driver.isHeadDriver && !headDriverExists && !busy;
    final canDemote = driver.isHeadDriver && !busy;
    final isOffDuty = driver.status == DriverStatus.offDuty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: driver.canChangeStatus
              ? (isOffDuty ? 'Set available' : 'Set off duty')
              : 'On a trip — status is set by the system',
          child: _button(
            label: isOffDuty ? 'Set Available' : 'Set Off Duty',
            bg: isOffDuty ? _greenButton : _greyButton,
            fg: isOffDuty ? Colors.white : AdminColors.navy,
            onPressed: canToggle ? () => onToggleStatus(driver) : null,
          ),
        ),
        const SizedBox(width: 10),
        if (driver.isHeadDriver)
          SizedBox(
            width: 84,
            child: _button(
              label: 'Demote',
              bg: _demotePurple,
              fg: Colors.white,
              onPressed: canDemote ? () => onChangeRole(driver) : null,
            ),
          )
        else
          Tooltip(
            message: headDriverExists
                ? 'A head driver already exists — demote them first'
                : 'Promote to Head Driver',
            child: SizedBox(
              width: 84,
              child: _button(
                label: 'Make Head',
                // Stays blue like the mockup; faded when disabled because a
                // head driver already exists.
                bg: AdminColors.blue,
                fg: Colors.white,
                disabledBg: AdminColors.blue.withOpacity(0.45),
                disabledFg: Colors.white,
                onPressed: canPromote ? () => onChangeRole(driver) : null,
              ),
            ),
          ),
      ],
    );
  }
}