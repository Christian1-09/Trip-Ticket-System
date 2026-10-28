// features/admin/presentation/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/dashboard_models.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/dashboard_widgets.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const _axisLabel = TextStyle(color: AdminColors.navy, fontSize: 11);
  static const _gridLine = MajorGridLines(width: 1, color: AdminColors.border);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminDashboardProvider);

    return ColoredBox(
      color: AdminColors.background,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(
          message: err is ApiException ? err.message : 'Could not load the dashboard.',
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
        data: (dashboard) {
          // Same data as the Analysis screen (uses its "Last N months" setting).
          final monthly =
              ref.watch(adminAnalyticsProvider).valueOrNull?.tripsByMonth ?? const [];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminDashboardProvider);
              await ref.read(adminDashboardProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TripOverviewBanner(
                    todayTotal: dashboard.todayTotal,
                    pendingToday: dashboard.pendingToday,
                    ongoingNow: dashboard.ongoingNow,
                  ),
                  const SizedBox(height: 18),

                  // ── Stat cards ─────────────────────────────────
                  Row(
                    children: [
                      for (var i = 0; i < dashboard.statCards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 14),
                        Expanded(
                          child: DashboardStatCard(
                            icon: dashboard.statCards[i].icon,
                            color: dashboard.statCards[i].color,
                            value: dashboard.statCards[i].value,
                            label: dashboard.statCards[i].label,
                            subtext: dashboard.statCards[i].subtext,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Department charts ──────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: DashboardChartCard(
                          title: 'TRIP REQUEST BY EACH DEPARTMENT',
                          child: dashboard.departmentTrips.isEmpty
                              ? const DashboardEmptyState('No trips have been submitted yet.')
                              : _departmentBarChart(dashboard.departmentTrips),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: DashboardChartCard(
                          title: 'TOTAL TRIP FOR EACH DEPARTMENT',
                          child: dashboard.departmentTrips.isEmpty
                              ? const DashboardEmptyState('No data yet.')
                              : _departmentDoughnut(
                              dashboard.departmentTrips, dashboard.totalTrips),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Monthly by requester ───────────────────────
                  DashboardChartCard(
                    title: 'TRIP REQUESTS EVERY MONTH, BY REQUESTER',
                    height: 230,
                    child: monthly.isEmpty
                        ? const DashboardEmptyState('No monthly data yet.')
                        : RequesterMonthlyChart(data: monthly),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _departmentBarChart(List<DepartmentTripModel> data) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: const CategoryAxis(
        labelStyle: _axisLabel,
        majorGridLines: _gridLine,
        majorTickLines: MajorTickLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: _axisLabel,
        majorGridLines: _gridLine,
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<DepartmentTripModel, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.department,
          yValueMapper: (d, _) => d.tripCount,
          pointColorMapper: (d, _) => d.color,
          width: 0.65,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
                color: AdminColors.navy, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _departmentDoughnut(List<DepartmentTripModel> data, int total) {
    return SfCircularChart(
      margin: EdgeInsets.zero,
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        iconHeight: 12,
        iconWidth: 12,
        textStyle: TextStyle(color: AdminColors.navy, fontSize: 12),
      ),
      series: <CircularSeries>[
        DoughnutSeries<DepartmentTripModel, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.department,
          yValueMapper: (d, _) => d.tripCount,
          pointColorMapper: (d, _) => d.color,
          radius: '85%',
          innerRadius: '55%',
          strokeColor: Colors.white,
          strokeWidth: 2,
          legendIconType: LegendIconType.circle,
        ),
      ],
      annotations: [
        CircularChartAnnotation(
          widget: Text('$total',
              style: const TextStyle(
                  color: AdminColors.navy, fontSize: 26, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AdminColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.navy, fontSize: 14)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}