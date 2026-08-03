// features/admin/presentation/screens/analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/models/monthly_trip_model.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/analysis_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(departmentTripsProvider);
    final monthlyData = ref.watch(monthlyTripProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analysis',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Manage and view the trip request on each department',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),

          // Bar + Donut row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _chartCard(
                    title: 'TRIP REQUEST BY EACH DEPARTMENT',
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
                      primaryYAxis: const NumericAxis(labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
                      legend: const Legend(isVisible: true, position: LegendPosition.top, textStyle: TextStyle(color: Colors.white70, fontSize: 9)),
                      plotAreaBorderWidth: 0,
                      series: <CartesianSeries>[
                        ColumnSeries<dynamic, String>(
                          dataSource: departments,
                          xValueMapper: (d, _) => d.department,
                          yValueMapper: (d, _) => d.tripCount,
                          pointColorMapper: (d, _) => d.color,
                          borderRadius: BorderRadius.circular(4),
                          dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Colors.white, fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _chartCard(
                    title: 'TOTAL TRIP FOR EACH DEPARTMENT',
                    height: 300,
                    child: SfCircularChart(
                      legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(color: Colors.white70, fontSize: 9)),
                      series: <CircularSeries>[
                        DoughnutSeries<dynamic, String>(
                          dataSource: departments,
                          xValueMapper: (d, _) => d.department,
                          yValueMapper: (d, _) => d.tripCount,
                          pointColorMapper: (d, _) => d.color,
                          innerRadius: '65%',
                          dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(color: Colors.white, fontSize: 9)),
                        ),
                      ],
                      annotations: const [
                        CircularChartAnnotation(
                          widget: Text('107', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Monthly trend area chart
          _chartCard(
            title: 'TRIP REQUEST TOTAL EVERY (MONTH)',
            height: 340,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
              primaryYAxis: const NumericAxis(labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
              legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(color: Colors.white70, fontSize: 9)),
              plotAreaBorderWidth: 0,
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                SplineAreaSeries<MonthlyTripModel, String>(
                  dataSource: monthlyData,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.visitingLecturer,
                  name: 'Visiting Lecturer',
                  color: const Color(0xFF29B6F6).withOpacity(0.3),
                  borderColor: const Color(0xFF29B6F6),
                  borderWidth: 2,
                ),
                SplineAreaSeries<MonthlyTripModel, String>(
                  dataSource: monthlyData,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.faculty,
                  name: 'Faculty',
                  color: const Color(0xFFAB47BC).withOpacity(0.3),
                  borderColor: const Color(0xFFAB47BC),
                  borderWidth: 2,
                ),
                SplineAreaSeries<MonthlyTripModel, String>(
                  dataSource: monthlyData,
                  xValueMapper: (d, _) => d.staff.toString(),
                  yValueMapper: (d, _) => d.staff,
                  name: 'Staff',
                  color: const Color(0xFFF9A825).withOpacity(0.3),
                  borderColor: const Color(0xFFF9A825),
                  borderWidth: 2,
                ),
                SplineAreaSeries<MonthlyTripModel, String>(
                  dataSource: monthlyData,
                  xValueMapper: (d, _) => d.month,
                  yValueMapper: (d, _) => d.ssg,
                  name: 'SSG',
                  color: const Color(0xFF66BB6A).withOpacity(0.3),
                  borderColor: const Color(0xFF66BB6A),
                  borderWidth: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child, double height = 280}) {
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
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}