// features/admin/presentation/widgets/trip_ticket_log_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../data/models/trip_ticket_log_model.dart';

class TripTicketLogDataSource extends DataGridSource {
  TripTicketLogDataSource({required List<TripTicketLogModel> logs}) {
    _rows = logs
        .map<DataGridRow>((log) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'date', value: log.dateOfTravel),
      DataGridCell<String>(columnName: 'driver', value: log.driver),
      DataGridCell<String>(columnName: 'vehicle', value: log.vehicle),
      DataGridCell<String>(columnName: 'purpose', value: log.purpose),
      DataGridCell<String>(columnName: 'destination', value: log.destination),
      DataGridCell<String>(columnName: 'passengers', value: log.passengers),
      DataGridCell<String>(columnName: 'timestamp', value: log.timestamp),
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${cell.value}',
              style: const TextStyle(color: Colors.white, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
    );
  }
}