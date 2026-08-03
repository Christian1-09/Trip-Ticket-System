// features/admin/presentation/screens/trip_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/presentation/screens/review_trip_screen.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../providers/trip_request_provider.dart';
import '../widgets/trip_request_data_source.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TripRequestScreen extends ConsumerStatefulWidget {
  const TripRequestScreen({super.key});

  @override
  ConsumerState<TripRequestScreen> createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends ConsumerState<TripRequestScreen> {
  late TripRequestDataSource _dataSource;
  String? _reviewingtripId;

  @override
  Widget build(BuildContext context) {
    if (_reviewingtripId != null){
      return ReviewTripScreen(tripId: _reviewingtripId!, onBack: () => setState(() => _reviewingtripId = null),
      );
    }
    final requests = ref.watch(tripRequestListProvider);
    _dataSource = TripRequestDataSource(
        requests: requests,
      onReviewTap: (model) => setState(() => _reviewingtripId = model.id),
    );

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
                    Text('Trip Request',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Pending Approval', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {}, // placeholder
                icon: const Icon(Icons.download, size: 16, color: Colors.white),
                label: const Text('Export', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4EDB),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters row
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF141B4D),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  onChanged: (val) => ref.read(tripRequestSearchProvider.notifier).state = val,
                ),
              ),
              const SizedBox(width: 12),
              _filterDropdown(
                value: ref.watch(tripRequestStatusFilterProvider),
                items: const ['Status', 'Pending', 'Complete', 'Urgent'],
                onChanged: (val) => ref.read(tripRequestStatusFilterProvider.notifier).state = val!,
              ),
              const SizedBox(width: 12),
              _filterDropdown(
                value: ref.watch(tripRequestDepartmentFilterProvider),
                items: const ['All Department', 'BSIS', 'BSCS', 'BSIT'],
                onChanged: (val) => ref.read(tripRequestDepartmentFilterProvider.notifier).state = val!,
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
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
                  source: _dataSource,
                  columnWidthMode: ColumnWidthMode.fill,
                  headerRowHeight: 46,
                  rowHeight: 56,
                  columns: [
                    _column('id', 'ID', width: 70),
                    _column('requesting', 'Requesting'),
                    _column('department', 'Department'),
                    _column('driver', 'Drive'),
                    _column('status', 'Status',alignment: Alignment.center),
                    _column('review', 'Review',alignment: Alignment.center),
                    _column('action', 'Action',alignment: Alignment.center),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GridColumn _column(String name, String label, {double? width,AlignmentGeometry alignment = Alignment.centerLeft}) {
    return GridColumn(
      columnName: name,
      width: width ?? double.nan,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: alignment,
        child: Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF141B4D),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}