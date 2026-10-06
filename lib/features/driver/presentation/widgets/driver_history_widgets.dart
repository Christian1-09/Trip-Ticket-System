// features/driver/presentation/widgets/driver_history_widgets.dart
//
// Light widgets for the driver's Trip History screen.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

import '../../data/driver_models.dart';

// ─────────────────────────────────────────────────────────── palette

const kHNavy = Color(0xFF0B1B3F);
const kHBlue = Color(0xFF1E6FE8);
const kHMuted = Color(0xFF6B7385);
const kHPageBg = Color(0xFFF2F5FA);
const kHYellow = Color(0xFFFFC928);
const kHGreen = Color(0xFF1FA35B);
const kHRed = Color(0xFFE5394A);
const kHBorder = Color(0xFFE3E8F0);

// ─────────────────────────────────────────────────────────── filters

enum HistoryTab { all, completed, cancelled }

enum HistoryPeriod { allTime, thisMonth, last30Days, thisYear }

enum HistorySort { newest, oldest, longestDistance }

extension HistoryPeriodX on HistoryPeriod {
  String get label => switch (this) {
    HistoryPeriod.allTime => 'All time',
    HistoryPeriod.thisMonth => 'This month',
    HistoryPeriod.last30Days => 'Last 30 days',
    HistoryPeriod.thisYear => 'This year',
  };

  bool includes(DateTime date) {
    final now = DateTime.now();
    return switch (this) {
      HistoryPeriod.allTime => true,
      HistoryPeriod.thisMonth =>
      date.year == now.year && date.month == now.month,
      HistoryPeriod.last30Days =>
          date.isAfter(now.subtract(const Duration(days: 30))),
      HistoryPeriod.thisYear => date.year == now.year,
    };
  }
}

extension HistorySortX on HistorySort {
  String get label => switch (this) {
    HistorySort.newest => 'Newest first',
    HistorySort.oldest => 'Oldest first',
    HistorySort.longestDistance => 'Longest distance',
  };
}

/// Rejected and declined trips both count as "Cancelled" in history.
bool isCancelledTrip(DriverTrip t) =>
    t.status == AdminTripStatus.rejected ||
        t.status == AdminTripStatus.driverDeclined;

bool isCompletedTrip(DriverTrip t) => t.status == AdminTripStatus.completed;

// ─────────────────────────────────────────────────────────── header

class HistoryHeader extends StatelessWidget {
  final double height;
  final VoidCallback? onBack;

  const HistoryHeader({super.key, required this.height, this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppMedia.scheduleHeaderImage,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Color(0xFF1B4FD6)),
          ),
          // Blue fade from the left so the title stays readable.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.0, 0.5, 0.85],
                colors: [
                  Color(0xF20A2C8F),
                  Color(0x991B4FD6),
                  Color(0x001B4FD6),
                ],
              ),
            ),
          ),
          // Fade into the page at the bottom, behind the stats card.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1.0],
                colors: [Color(0x000A2C8F), kHPageBg],
              ),
            ),
          ),
          // Yellow corner accent.
          const Positioned(
            left: 0,
            top: 0,
            child: CustomPaint(
              size: Size(64, 64),
              painter: _CornerPainter(),
            ),
          ),
          if (onBack != null)
            Positioned(
              top: top + 8,
              left: 16,
              child: Material(
                color: Colors.white.withOpacity(0.2),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 19),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 20,
            right: 120,
            top: top + (onBack != null ? 56 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(
                        text: 'Trip ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'History',
                        style: TextStyle(color: kHYellow),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'View your past trips and travel records.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = kHYellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────── stats card

class HistoryStatsCard extends StatelessWidget {
  final int completed;
  final int thisMonth;
  final double totalKm;

  const HistoryStatsCard({
    super.key,
    required this.completed,
    required this.thisMonth,
    required this.totalKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2C8F), Color(0xFF1B4FD6)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kHNavy.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.check_circle_outline_rounded,
            label: 'Completed Trips',
            value: '$completed',
          ),
          const _StatDivider(),
          _StatCell(
            icon: Icons.calendar_month_rounded,
            label: 'This Month',
            value: '$thisMonth',
          ),
          const _StatDivider(),
          _StatCell(
            icon: Icons.route_rounded,
            label: 'Total Distance',
            value: NumberFormat('#,##0').format(totalKm),
            unit: 'km',
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.14),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        text: value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        children: [
                          if (unit != null)
                            TextSpan(
                              text: ' $unit',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: Colors.white.withOpacity(0.2));
}

// ─────────────────────────────────────────────────────────── search row

class HistorySearchRow extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final bool filterActive;
  final bool sortActive;

  const HistorySearchRow({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    required this.onSortTap,
    this.filterActive = false,
    this.sortActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kHBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: kHNavy, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    style: const TextStyle(color: kHNavy, fontSize: 13),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Search by route, requester, or vehicle...',
                      hintStyle: TextStyle(color: kHMuted, fontSize: 12.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.filter_list_rounded,
          label: 'Filter',
          active: filterActive,
          onTap: onFilterTap,
        ),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.swap_vert_rounded,
          label: 'Sort',
          active: sortActive,
          onTap: onSortTap,
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? kHBlue : kHNavy;
    return Material(
      color: active ? const Color(0xFFE8F0FD) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: active ? kHBlue.withOpacity(0.4) : kHBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── tabs

class HistoryTabs extends StatelessWidget {
  final HistoryTab selected;
  final Map<HistoryTab, int> counts;
  final ValueChanged<HistoryTab> onSelected;

  const HistoryTabs({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  static const _labels = {
    HistoryTab.all: 'All',
    HistoryTab.completed: 'Completed',
    HistoryTab.cancelled: 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final tab in HistoryTab.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: tab == selected
                        ? const LinearGradient(
                      colors: [Color(0xFF1B4FD6), Color(0xFF0A2C8F)],
                    )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _labels[tab]!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tab == selected ? Colors.white : kHNavy,
                            fontSize: 13,
                            fontWeight: tab == selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: tab == selected
                              ? Colors.white
                              : const Color(0xFFD3DCEA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${counts[tab] ?? 0}',
                          style: TextStyle(
                            color: tab == selected ? kHBlue : kHNavy,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── option sheet

/// Small bottom sheet with a list of choices; returns the picked value.
Future<T?> showHistoryOptions<T>(
    BuildContext context, {
      required String title,
      required List<(T, String, IconData)> options,
      required T selected,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DBE6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: kHNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final (value, label, icon) in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon,
                      color: value == selected ? kHBlue : kHNavy),
                  title: Text(
                    label,
                    style: TextStyle(
                      color: value == selected ? kHBlue : kHNavy,
                      fontWeight: value == selected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: value == selected
                      ? const Icon(Icons.check_circle, color: kHBlue)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(value),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}