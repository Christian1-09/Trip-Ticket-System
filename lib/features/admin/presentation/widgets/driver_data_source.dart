// features/admin/presentation/widgets/driver_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../data/models/driver_model.dart';

class DriverDataSource extends DataGridSource {
  DriverDataSource({required List<DriverModel> drivers}) {
    _rows = drivers
        .map<DataGridRow>((d) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: '${d.id}'),
      DataGridCell<String>(columnName: 'name', value: d.name),
      DataGridCell<String>(columnName: 'date', value: d.date),
      DataGridCell<String>(columnName: 'trips', value: '${d.totalTrips}'),
      DataGridCell<DriverStatus>(columnName: 'status', value: d.status),
    ]))
        .toList();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'status') {
          final status = cell.value as DriverStatus;
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: status.color.withOpacity(0.6)),
              ),
              child: Text(status.label,
                  style: TextStyle(color: status.color, fontSize: 11, fontWeight: FontWeight.w600)),
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