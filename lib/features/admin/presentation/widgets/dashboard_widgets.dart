// features/admin/presentation/widgets/dashboard_widgets.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// TODO: adjust this import to wherever your AppMedia class lives.

import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/media.dart';
import '../../data/models/dashboard_models.dart';


/// ─────────────────────────────────────────────────────────────
/// Trip Overview banner (navy gradient + header image on the right)
/// ─────────────────────────────────────────────────────────────
class TripOverviewBanner extends StatelessWidget {
  final int todayTotal;
  final int pendingToday;
  final int ongoingNow;

  const TripOverviewBanner({
    super.key,
    required this.todayTotal,
    required this.pendingToday,
    required this.ongoingNow,
  });

  /// Banner height. The whole header image is scaled to this height
  /// (zoomed out), so the full van, road and skyline stay visible.
  static const double _height = 165;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            // 1. Navy gradient background across the whole banner
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF0B2580), Color(0xFF12349E), Color(0xFF1B47C7)],
                  ),
                ),
              ),
            ),

            // 2. Header image, zoomed out: fits the banner HEIGHT and sits on
            //    the right. Its own left edge fades into the navy (ShaderMask),
            //    so the fade always lines up with the image no matter how wide
            //    the screen is.
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.45, 0.7],
                  colors: [Colors.transparent, Color(0x99FFFFFF), Colors.white],
                ).createShader(rect),
                child: Image.asset(
                  AppMedia.myTripHeader,
                  height: _height,
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),

            // 3. Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WELCOME TO JTRIPS',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 6),
                        Text('Trip Overview',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                height: 1.1,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 8),
                        Text('Today at a glance, plus everything still in progress.',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  _OverviewChip(
                    icon: Icons.navigation_rounded,
                    color: AdminColors.blue,
                    label: "TODAY'S TRIPS",
                    value: todayTotal,
                  ),
                  const SizedBox(width: 12),
                  _OverviewChip(
                    icon: Icons.schedule,
                    color: AdminColors.orange,
                    label: 'PENDING TODAY',
                    value: pendingToday,
                  ),
                  const SizedBox(width: 12),
                  _OverviewChip(
                    icon: Icons.directions_car,
                    color: AdminColors.green,
                    label: 'ON THE ROAD',
                    value: ongoingNow,
                  ),
                  // Room on the right so the van stays fully visible.
                  // Increase if the chips cover the van on your image.
                  const SizedBox(width: 340),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;

  const _OverviewChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AdminColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$value',
                    style: const TextStyle(
                        color: AdminColors.navy,
                        fontSize: 24,
                        height: 1.1,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Stat card (white, colored left edge, tinted circular icon)
/// ─────────────────────────────────────────────────────────────
class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? subtext;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AdminColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(width: 4, color: color),
          const SizedBox(width: 18),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: AdminColors.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.1)),
                Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AdminColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                if (subtext != null)
                  Text(subtext!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AdminColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// White chart card with navy uppercase title
/// ─────────────────────────────────────────────────────────────
class DashboardChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;

  const DashboardChartCard({
    super.key,
    required this.title,
    required this.child,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
                  color: AdminColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  final String message;
  const DashboardEmptyState(this.message, {super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(message,
        style: const TextStyle(color: AdminColors.textMuted, fontSize: 13)),
  );
}

/// ─────────────────────────────────────────────────────────────
/// "Trip requests every month, by requester" — shared by the
/// Dashboard and Analysis screens.
/// ─────────────────────────────────────────────────────────────
class RequesterMonthlyChart extends StatelessWidget {
  final List<MonthlyTripModel> data;
  const RequesterMonthlyChart({super.key, required this.data});

  static const _axisLabel = TextStyle(color: AdminColors.navy, fontSize: 11);
  static const _grid = MajorGridLines(width: 1, color: AdminColors.border);

  @override
  Widget build(BuildContext context) {
    // "Visiting Lecturer" is the same role as Faculty in this system,
    // so there are three requester types, not four.
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        iconHeight: 12,
        iconWidth: 12,
        textStyle: TextStyle(color: AdminColors.navy, fontSize: 12),
      ),
      tooltipBehavior: TooltipBehavior(enable: true, shared: true),
      primaryXAxis: const CategoryAxis(
        labelStyle: _axisLabel,
        majorGridLines: _grid,
        majorTickLines: MajorTickLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: _axisLabel,
        interval: 1,
        majorGridLines: _grid,
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(width: 0),
      ),
      series: <CartesianSeries>[
        _area('Faculty', const Color(0xFF2563EB), (d) => d.faculty),
        _area('Staff', const Color(0xFFA855F7), (d) => d.staff),
        _area('SSG President', const Color(0xFF22C55E), (d) => d.ssg),
      ],
    );
  }

  SplineAreaSeries<MonthlyTripModel, String> _area(
      String name, Color color, int Function(MonthlyTripModel) y) {
    return SplineAreaSeries<MonthlyTripModel, String>(
      name: name,
      dataSource: data,
      xValueMapper: (d, _) => d.month,
      yValueMapper: (d, _) => y(d),
      borderColor: color,
      borderWidth: 2,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.30), color.withOpacity(0.02)],
      ),
      markerSettings: MarkerSettings(
        isVisible: true,
        height: 6,
        width: 6,
        color: color,
        borderColor: color,
      ),
      legendIconType: LegendIconType.circle,
    );
  }
}

/// White KPI tile: colored left edge, tinted round icon, small caps label
/// above a big value (Analysis screen totals).
class KpiTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const KpiTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AdminColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(width: 4, color: color),
          const SizedBox(width: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AdminColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AdminColors.navy,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}