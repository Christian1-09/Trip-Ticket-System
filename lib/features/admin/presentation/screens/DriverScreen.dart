// features/admin/presentation/screens/driver_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_data_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class DriverScreen extends ConsumerWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driverListProvider);
    final dataSource = DriverDataSource(drivers: drivers);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Driver',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Manage vehicle drivers',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141B4D),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: SfDataGridTheme(
              data: SfDataGridThemeData(
                headerColor: const Color(0xFF1E2761),
                gridLineColor: Colors.white12,
                gridLineStrokeWidth: 0.5,
              ),
              child: SfDataGrid(
                source: dataSource,
                shrinkWrapRows: true,
                columnWidthMode: ColumnWidthMode.fill,
                headerRowHeight: 44,
                rowHeight: 48,
                columns: [
                  _column('id', 'ID', width: 60),
                  _column('name', 'Name'),
                  _column('date', 'Date'),
                  _column('trips', 'Total trips'),
                  _column('status', 'Status', alignCenter: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  GridColumn _column(String name, String label, {double? width, bool alignCenter = false}) {
    return GridColumn(
      columnName: name,
      width: width ?? double.nan,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: alignCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}