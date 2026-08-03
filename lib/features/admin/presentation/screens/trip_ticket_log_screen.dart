// features/admin/presentation/screens/trip_ticket_log_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../providers/trip_ticket_log_provider.dart';
import '../widgets/trip_ticket_log_data_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TripTicketLogScreen extends ConsumerWidget {
  const TripTicketLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(tripTicketLogProvider);
    final dataSource = TripTicketLogDataSource(logs: logs);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('TRIP TICKET LOG',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Manage trip ticket log',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {}, // placeholder
                icon: const Icon(Icons.download, size: 16, color: Colors.white),
                label: const Text('Download', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4EDB),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141B4D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF29B6F6).withOpacity(0.4)),
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
                  columnWidthMode: ColumnWidthMode.fill,
                  headerRowHeight: 52,
                  rowHeight: 44,
                  columns: [
                    _column('date', 'Date of Travel'),
                    _column('driver', 'Driver'),
                    _column('vehicle', 'Vehicle'),
                    _column('purpose', 'Purpose/Reason'),
                    _column('destination', 'Destination'),
                    _column('passengers', 'Passengers'),
                    _column('timestamp', 'Timestamp/Date & Time of Ticket Printing'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GridColumn _column(String name, String label) {
    return GridColumn(
      columnName: name,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF29B6F6), fontSize: 11, fontWeight: FontWeight.w600),
          maxLines: 2,
        ),
      ),
    );
  }
}