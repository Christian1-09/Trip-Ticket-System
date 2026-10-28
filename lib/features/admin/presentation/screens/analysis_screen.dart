// features/admin/presentation/screens/analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/dashboard_models.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/dashboard_widgets.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  static const _axisLabel = TextStyle(color: AdminColors.navy, fontSize: 11);
  static const _grid = MajorGridLines(width: 1, color: AdminColors.border);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentTripsProvider);
    final async = ref.watch(adminAnalyticsProvider);
    final months = ref.watch(analysisMonthsProvider);

    return ColoredBox(
      color: AdminColors.background,
      child: async.when(
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
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(adminAnalyticsProvider),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AdminColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Retry'),
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ───────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Analysis',
                              style: TextStyle(
                                  color: AdminColors.navy,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Trip volume, destinations, drivers and vehicles',
                              style: TextStyle(
                                  color: AdminColors.textMuted, fontSize: 14)),
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

                // ── Totals ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: KpiTile(
                        icon: Icons.assignment_rounded,
                        color: AdminColors.blue,
                        label: 'COMPLETED TRIPS',
                        value: '${analytics.completedTrips}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiTile(
                        icon: Icons.location_on_rounded,
                        color: AdminColors.orange,
                        label: 'DISTANCE TRAVELLED',
                        value: '${analytics.distanceKm} km',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: KpiTile(
                        icon: Icons.local_gas_station_rounded,
                        color: AdminColors.green,
                        label: 'FUEL CONSUMED',
                        value: '${analytics.fuelLiters.toStringAsFixed(1)} L',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Department bar + status doughnut ─────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DashboardChartCard(
                        title: 'TRIP REQUEST BY EACH DEPARTMENT',
                        height: 290,
                        child: departments.isEmpty
                            ? const DashboardEmptyState('Not enough data yet.')
                            : _departmentChart(departments),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: DashboardChartCard(
                        title: 'TRIPS BY STATUS',
                        height: 290,
                        child: analytics.tripsByStatus.isEmpty
                            ? const DashboardEmptyState('Not enough data yet.')
                            : _statusChart(analytics.tripsByStatus),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Monthly by requester ─────────────────────────
                DashboardChartCard(
                  title: 'TRIP REQUESTS EVERY MONTH, BY REQUESTER',
                  height: 280,
                  child: analytics.tripsByMonth.isEmpty
                      ? const DashboardEmptyState('Not enough data yet.')
                      : RequesterMonthlyChart(data: analytics.tripsByMonth),
                ),
                const SizedBox(height: 18),

                // ── Top destinations ─────────────────────────────
                DashboardChartCard(
                  title: 'MOST VISITED DESTINATIONS',
                  height: 290,
                  child: analytics.topDestinations.isEmpty
                      ? const DashboardEmptyState('Not enough data yet.')
                      : _destinationsChart(analytics.topDestinations),
                ),
                const SizedBox(height: 18),

                // ── Driver + vehicle tables ──────────────────────
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _TableCard(
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
                      const SizedBox(width: 18),
                      Expanded(
                        child: _TableCard(
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _departmentChart(List<DepartmentTripModel> data) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: const CategoryAxis(
        labelStyle: _axisLabel,
        majorGridLines: _grid,
        majorTickLines: MajorTickLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: _axisLabel,
        majorGridLines: _grid,
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(width: 0),
      ),
      series: <CartesianSeries>[
        ColumnSeries<DepartmentTripModel, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.department,
          yValueMapper: (d, _) => d.tripCount,
          pointColorMapper: (d, _) => d.color,
          width: 0.7,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
                color: AdminColors.navy, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _statusChart(List<StatusCountModel> data) {
    return SfCircularChart(
      margin: EdgeInsets.zero,
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        iconHeight: 12,
        iconWidth: 12,
        textStyle: TextStyle(color: AdminColors.navy, fontSize: 12),
      ),
      series: <CircularSeries>[
        DoughnutSeries<StatusCountModel, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.status,
          yValueMapper: (d, _) => d.count,
          pointColorMapper: (d, _) => d.color,
          radius: '85%',
          innerRadius: '68%',
          strokeColor: Colors.white,
          strokeWidth: 2,
          legendIconType: LegendIconType.circle,
        ),
      ],
    );
  }

  Widget _destinationsChart(List<DestinationCountModel> data) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: const CategoryAxis(
        labelStyle: _axisLabel,
        majorGridLines: MajorGridLines(width: 0),
        majorTickLines: MajorTickLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: _axisLabel,
        majorGridLines: _grid,
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(width: 0),
      ),
      series: <CartesianSeries>[
        BarSeries<DestinationCountModel, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.name,
          yValueMapper: (d, _) => d.count,
          pointColorMapper: (d, i) => paletteColor(i),
          width: 0.6,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
                color: AdminColors.navy, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final String emptyText;

  const _TableCard({
    required this.title,
    required this.headers,
    required this.rows,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AdminColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AdminColors.navy, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(emptyText,
                  style: const TextStyle(color: AdminColors.textMuted, fontSize: 13)),
            )
          else
            Table(
              columnWidths: const {0: FlexColumnWidth(2)},
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: headers
                      .map((h) => Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(h,
                        style: const TextStyle(
                            color: Color(0xFF5B6582),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ))
                      .toList(),
                ),
                ...rows.take(8).map(
                      (row) => TableRow(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AdminColors.border)),
                    ),
                    children: row
                        .map((cell) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(cell,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AdminColors.navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
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
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
        boxShadow: AdminColors.cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(
              color: AdminColors.navy, fontSize: 14, fontWeight: FontWeight.w500),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.keyboard_arrow_down, color: AdminColors.navy, size: 20),
          ),
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