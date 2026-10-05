// features/instructor/presentation/widgets/schedule_header.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

enum ScheduleTab { all, upcoming, past }

/// Scenic header for the Schedule tab: back button (only when there's a
/// screen to go back to), "N trips today" chip, title and subtitle.
class ScheduleHeader extends StatelessWidget {
  final double topInset;
  final String backgroundAsset;
  final int todayCount;

  /// Turn off if the header image already has its own yellow curve.
  final bool showSwoosh;

  const ScheduleHeader({
    super.key,
    required this.topInset,
    required this.backgroundAsset,
    required this.todayCount,
    this.showSwoosh = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final canPop = Navigator.of(context).canPop();

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          backgroundAsset,
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),

        // Navy wash on the left so the title stays readable over the sky.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.45, 0.7],
              colors: [
                AppColors.homeNavyDark.withOpacity(0.85),
                AppColors.homeNavy.withOpacity(0.45),
                Colors.transparent,
              ],
            ),
          ),
        ),

        if (showSwoosh) const CustomPaint(painter: _SwooshPainter()),

        // Back button
        if (canPop)
          Positioned(
            top: topInset + 8,
            left: 14,
            child: _GlassCircleButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),

        // "N trips today" chip
        Positioned(
          top: topInset + 10,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white70),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month_rounded,
                    size: 13, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  todayCount == 1 ? '1 trip today' : '$todayCount trips today',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Title + subtitle
        Positioned(
          left: 18,
          top: topInset + 54,
          width: width * 0.55,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule Trips',
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View and manage your upcoming and past trips.',
                maxLines: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.homeNavyDark.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white70, width: 1.4),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final yellow = Path()
      ..moveTo(0, h * 0.74)
      ..quadraticBezierTo(w * 0.28, h * 0.98, w * 0.62, h * 0.90)
      ..quadraticBezierTo(w * 0.85, h * 0.84, w, h * 0.70);
    final blue = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.30, h * 1.04, w * 0.66, h * 0.96)
      ..quadraticBezierTo(w * 0.87, h * 0.91, w, h * 0.80);

    canvas.drawPath(
      blue,
      Paint()
        ..color = const Color(0xFF3B82F6).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawPath(
      yellow,
      Paint()
        ..color = AppColors.accentYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────── tabs

/// Navy segmented bar with yellow edges peeking out behind it.
class ScheduleTabBar extends StatelessWidget {
  final ScheduleTab selected;
  final int allCount;
  final int upcomingCount;
  final int pastCount;
  final ValueChanged<ScheduleTab> onSelect;

  const ScheduleTabBar({
    super.key,
    required this.selected,
    required this.allCount,
    required this.upcomingCount,
    required this.pastCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (ScheduleTab.all, Icons.calendar_month_rounded, 'All Trips', allCount),
      (ScheduleTab.upcoming, Icons.schedule_rounded, 'Upcoming', upcomingCount),
      (ScheduleTab.past, Icons.check_circle_rounded, 'Past Trips', pastCount),
    ];

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final (tab, icon, label, count) = items[i];
      if (i > 0) {
        // Divider only between two unselected tabs.
        final hide = selected == tab || selected == items[i - 1].$1;
        children.add(Container(
          width: 1,
          height: 22,
          color: hide ? Colors.transparent : Colors.white24,
        ));
      }
      children.add(Expanded(
        child: _TabItem(
          icon: icon,
          label: label,
          count: count,
          selected: selected == tab,
          onTap: () => onSelect(tab),
        ),
      ));
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Yellow layer behind, showing at the ends and along the bottom.
        Positioned(
          left: -5,
          right: -5,
          top: 5,
          bottom: -4,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accentYellow,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.homeNavyDark.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.homeNavy, AppColors.homeNavyDark],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(children: children),
          ),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.homeNavy : Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.35),
              blurRadius: 8,
            ),
          ]
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? icon : _outlined(icon),
                  size: 16,
                  color: fg,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.homeNavy
                        : const Color(0xFF3A5BA8),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _outlined(IconData icon) {
    if (icon == Icons.calendar_month_rounded) return Icons.calendar_month_outlined;
    if (icon == Icons.check_circle_rounded) return Icons.check_circle_outline_rounded;
    return icon;
  }
}