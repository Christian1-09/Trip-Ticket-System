// features/admin/presentation/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../data/models/dashboard_models.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminDashboardProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _ErrorView(
        message: err is ApiException ? err.message : 'Could not load the dashboard.',
        onRetry: () => ref.invalidate(adminDashboardProvider),
      ),
      data: (dashboard) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardProvider);
          await ref.read(adminDashboardProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Overview banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141B4D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trip Overview',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Today at a glance, plus everything still in progress',
                              style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    _overviewChip(
                        "TODAY'S TRIPS", '${dashboard.todayTotal}', Colors.white),
                    const SizedBox(width: 12),
                    _overviewChip(
                        'PENDING TODAY', '${dashboard.pendingToday}', Colors.amber),
                    const SizedBox(width: 12),
                    _overviewChip(
                        'ON THE ROAD', '${dashboard.ongoingNow}', Colors.greenAccent),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () => ref.invalidate(adminDashboardProvider),
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: dashboard.statCards.map((stat) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(top: BorderSide(color: stat.color, width: 3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(stat.icon, color: stat.color, size: 18),
                          const SizedBox(height: 8),
                          Text(stat.value,
                              style: TextStyle(
                                  color: stat.color,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text(stat.label,
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          if (stat.subtext != null)
                            Text(stat.subtext!,
                                style: const TextStyle(
                                    color: Colors.black45, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              if (dashboard.departmentTrips.isEmpty)
                _chartCard(
                  title: 'TRIP REQUEST BY EACH DEPARTMENT',
                  child: const Center(
                    child: Text('No trips have been submitted yet.',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _chartCard(
                        title: 'TRIP REQUEST BY EACH DEPARTMENT',
                        child: SfCartesianChart(
                          primaryXAxis: const CategoryAxis(
                              labelStyle:
                              TextStyle(color: Colors.white70, fontSize: 10)),
                          primaryYAxis: const NumericAxis(
                              labelStyle:
                              TextStyle(color: Colors.white70, fontSize: 10)),
                          plotAreaBorderWidth: 0,
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <CartesianSeries>[
                            ColumnSeries<DepartmentTripModel, String>(
                              dataSource: dashboard.departmentTrips,
                              xValueMapper: (d, _) => d.department,
                              yValueMapper: (d, _) => d.tripCount,
                              pointColorMapper: (d, _) => d.color,
                              borderRadius: BorderRadius.circular(4),
                              dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle:
                                  TextStyle(color: Colors.white, fontSize: 9)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _chartCard(
                        title: 'TOTAL TRIP FOR EACH DEPARTMENT',
                        child: SfCircularChart(
                          legend: const Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              textStyle:
                              TextStyle(color: Colors.white70, fontSize: 9)),
                          series: <CircularSeries>[
                            DoughnutSeries<DepartmentTripModel, String>(
                              dataSource: dashboard.departmentTrips,
                              xValueMapper: (d, _) => d.department,
                              yValueMapper: (d, _) => d.tripCount,
                              pointColorMapper: (d, _) => d.color,
                              innerRadius: '65%',
                            ),
                          ],
                          annotations: [
                            CircularChartAnnotation(
                              widget: Text('${dashboard.totalTrips}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF141B4D), borderRadius: BorderRadius.circular(16)),
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
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B4EDB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}