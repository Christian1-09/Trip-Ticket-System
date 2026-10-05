// features/admin/presentation/screens/analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../data/models/dashboard_models.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/analysis_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentTripsProvider);
    final async = ref.watch(adminAnalyticsProvider);
    final months = ref.watch(analysisMonthsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                err is ApiException ? err.message : 'Could not load the analysis.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminAnalyticsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4EDB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      data: (analytics) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminAnalyticsProvider);
          await ref.read(adminAnalyticsProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Analysis',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Text('Trip volume, destinations, drivers and vehicles',
                            style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  _MonthsDropdown(
                    value: months,
                    onChanged: (val) =>
                    ref.read(analysisMonthsProvider.notifier).state = val,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Totals strip
              Row(
                children: [
                  _totalTile('COMPLETED TRIPS', '${analytics.completedTrips}',
                      const Color(0xFF2E7D32)),
                  const SizedBox(width: 12),
                  _totalTile('DISTANCE TRAVELLED', '${analytics.distanceKm} km',
                      const Color(0xFF29B6F6)),
                  const SizedBox(width: 12),
                  _totalTile('FUEL CONSUMED',
                      '${analytics.fuelLiters.toStringAsFixed(1)} L',
                      const Color(0xFFF9A825)),
                ],
              ),
              const SizedBox(height: 16),

              // Department bar + status doughnut
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _chartCard(
                        title: 'TRIP REQUEST BY EACH DEPARTMENT',
                        height: 300,
                        child: departments.isEmpty
                            ? _emptyChart()
                            : SfCartesianChart(
                          primaryXAxis: const CategoryAxis(
                              labelStyle: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          primaryYAxis: const NumericAxis(
                              labelStyle: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          plotAreaBorderWidth: 0,
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <CartesianSeries>[
                            ColumnSeries<DepartmentTripModel, String>(
                              dataSource: departments,
                              xValueMapper: (d, _) => d.department,
                              yValueMapper: (d, _) => d.tripCount,
                              pointColorMapper: (d, _) => d.color,
                              borderRadius: BorderRadius.circular(4),
                              dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 9)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _chartCard(
                        title: 'TRIPS BY STATUS',
                        height: 300,
                        child: analytics.tripsByStatus.isEmpty
                            ? _emptyChart()
                            : SfCircularChart(
                          legend: const Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              overflowMode: LegendItemOverflowMode.wrap,
                              textStyle: TextStyle(
                                  color: Colors.white70, fontSize: 9)),
                          series: <CircularSeries>[
                            DoughnutSeries<StatusCountModel, String>(
                              dataSource: analytics.tripsByStatus,
                              xValueMapper: (d, _) => d.status,
                              yValueMapper: (d, _) => d.count,
                              pointColorMapper: (d, _) => d.color,
                              innerRadius: '65%',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Monthly trend, split by who requested
              _chartCard(
                title: 'TRIP REQUESTS EVERY MONTH, BY REQUESTER',
                height: 340,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
                  primaryYAxis: const NumericAxis(
                      labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
                  legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(color: Colors.white70, fontSize: 9)),
                  plotAreaBorderWidth: 0,
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    // "Visiting Lecturer" is the same role as Faculty in this
                    // system, so there are three requester types, not four.
                    SplineAreaSeries<MonthlyTripModel, String>(
                      dataSource: analytics.tripsByMonth,
                      xValueMapper: (d, _) => d.month,
                      yValueMapper: (d, _) => d.faculty,
                      name: 'Faculty',
                      color: const Color(0xFF29B6F6).withOpacity(0.3),
                      borderColor: const Color(0xFF29B6F6),
                      borderWidth: 2,
                    ),
                    SplineAreaSeries<MonthlyTripModel, String>(
                      dataSource: analytics.tripsByMonth,
                      xValueMapper: (d, _) => d.month,
                      yValueMapper: (d, _) => d.staff,
                      name: 'Staff',
                      color: const Color(0xFFAB47BC).withOpacity(0.3),
                      borderColor: const Color(0xFFAB47BC),
                      borderWidth: 2,
                    ),
                    SplineAreaSeries<MonthlyTripModel, String>(
                      dataSource: analytics.tripsByMonth,
                      xValueMapper: (d, _) => d.month,
                      yValueMapper: (d, _) => d.ssg,
                      name: 'SSG President',
                      color: const Color(0xFF66BB6A).withOpacity(0.3),
                      borderColor: const Color(0xFF66BB6A),
                      borderWidth: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Most visited destinations
              _chartCard(
                title: 'MOST VISITED DESTINATIONS',
                height: 300,
                child: analytics.topDestinations.isEmpty
                    ? _emptyChart()
                    : SfCartesianChart(
                  primaryXAxis: const CategoryAxis(
                      labelStyle:
                      TextStyle(color: Colors.white70, fontSize: 10)),
                  primaryYAxis: const NumericAxis(
                      labelStyle:
                      TextStyle(color: Colors.white70, fontSize: 10)),
                  plotAreaBorderWidth: 0,
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    BarSeries<DestinationCountModel, String>(
                      dataSource: analytics.topDestinations,
                      xValueMapper: (d, _) => d.name,
                      yValueMapper: (d, _) => d.count,
                      pointColorMapper: (d, i) => paletteColor(i),
                      borderRadius: BorderRadius.circular(4),
                      dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle:
                          TextStyle(color: Colors.white, fontSize: 9)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Driver and vehicle tables
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _tableCard(
                        title: 'DRIVER PERFORMANCE',
                        headers: const ['Driver', 'Trips', 'Distance', 'Rating'],
                        rows: analytics.driverPerformance
                            .map((d) => [
                          d.name,
                          '${d.trips}',
                          '${d.distanceKm} km',
                          d.ratingLabel,
                        ])
                            .toList(),
                        emptyText: 'No completed trips yet.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _tableCard(
                        title: 'VEHICLE USAGE',
                        headers: const ['Vehicle', 'Trips', 'Distance', 'Efficiency'],
                        rows: analytics.vehicleUsage
                            .map((v) => [
                          v.label,
                          '${v.trips}',
                          '${v.distanceKm} km',
                          v.efficiencyLabel,
                        ])
                            .toList(),
                        emptyText: 'No completed trips yet.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyChart() => const Center(
    child: Text('Not enough data yet.',
        style: TextStyle(color: Colors.white54, fontSize: 13)),
  );

  Widget _totalTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141B4D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 6),
            Text(value,
                style:
                TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required Widget child,
    double height = 280,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _tableCard({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(emptyText,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            )
          else
            Table(
              columnWidths: const {0: FlexColumnWidth(2)},
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24)),
                  ),
                  children: headers
                      .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(h,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ))
                      .toList(),
                ),
                ...rows.take(8).map(
                      (row) => TableRow(
                    children: row
                        .map((cell) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(cell,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11.5)),
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MonthsDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _MonthsDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          dropdownColor: const Color(0xFF141B4D),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
          items: const [3, 6, 12, 24]
              .map((m) => DropdownMenuItem(value: m, child: Text('Last $m months')))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}