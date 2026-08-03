// presentation/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatCardsProvider);
    final departments = ref.watch(departmentTripsProvider);
    final overview = ref.watch(tripOverviewProvider);

    return SingleChildScrollView(
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
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Trip Overview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Review the total trips pending and ongoing',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                _overviewChip("TODAY'S TRIPS", overview['total'].toString(), Colors.white),
                const SizedBox(width: 12),
                _overviewChip('PENDING TRIPS', overview['pending'].toString(), Colors.amber),
                const SizedBox(width: 12),
                _overviewChip('ONGOING TRIPS', overview['ongoing'].toString(), Colors.greenAccent),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stat cards row
          Row(
            children: stats.map((stat) {
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
                      Text(stat.value, style: TextStyle(color: stat.color, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(stat.label, style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
                      if (stat.subtext != null)
                        Text(stat.subtext!, style: const TextStyle(color: Colors.black45, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _chartCard(
                  title: 'TRIP REQUEST BY EACH DEPARTMENT',
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
                    primaryYAxis: const NumericAxis(labelStyle: TextStyle(color: Colors.white70, fontSize: 10)),
                    plotAreaBorderWidth: 0,
                    series: <CartesianSeries>[
                      ColumnSeries<dynamic, String>(
                        dataSource: departments,
                        xValueMapper: (d, _) => d.department,
                        yValueMapper: (d, _) => d.tripCount,
                        pointColorMapper: (d, _) => d.color,
                        borderRadius: BorderRadius.circular(4),
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
                    legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(color: Colors.white70, fontSize: 9)),
                    series: <CircularSeries>[
                      DoughnutSeries<dynamic, String>(
                        dataSource: departments,
                        xValueMapper: (d, _) => d.department,
                        yValueMapper: (d, _) => d.tripCount,
                        pointColorMapper: (d, _) => d.color,
                        innerRadius: '65%',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF141B4D), borderRadius: BorderRadius.circular(16)),
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