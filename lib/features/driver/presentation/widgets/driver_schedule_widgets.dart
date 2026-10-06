// features/driver/presentation/widgets/driver_schedule_widgets.dart
//
// Header and side menu for the driver's Schedule screen.
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/media.dart';

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _yellow = Color(0xFFFFC928);

// ─────────────────────────────────────────────────────────── header

class ScheduleHeader extends StatelessWidget {
  final double height;
  final String userName;
  final int unreadCount;
  final VoidCallback onMenuTap;
  final VoidCallback onBellTap;

  const ScheduleHeader({
    super.key,
    required this.height,
    required this.userName,
    required this.unreadCount,
    required this.onMenuTap,
    required this.onBellTap,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 18) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
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
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.45, 0.8],
                  colors: [
                    Color(0xF20A2C8F),
                    Color(0xB31B4FD6),
                    Color(0x001B4FD6),
                  ],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.6, 1.0],
                  colors: [Color(0x000A2C8F), Color(0x660A2C8F)],
                ),
              ),
            ),
            // Yellow arc, bottom-right accent
            Positioned(
              right: -70,
              bottom: -90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _yellow.withOpacity(0.9), width: 12),
                ),
              ),
            ),
            Positioned(
              top: top + 8,
              left: 12,
              child: _RoundButton(
                onTap: onMenuTap,
                child: const Icon(Icons.menu_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            Positioned(
              top: top + 8,
              right: 12,
              child: _RoundButton(
                onTap: onBellTap,
                child: Badge(
                  isLabelVisible: unreadCount > 0,
                  backgroundColor: _yellow,
                  textColor: _navy,
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  child: const Icon(Icons.notifications_rounded,
                      color: Colors.white, size: 21),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 140,
              top: top + 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: const TextStyle(
                      color: _yellow,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$userName!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here are your scheduled trips\nfor today and upcoming.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 11.5,
                      height: 1.35,
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

class _RoundButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _RoundButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── section header

class ScheduleSectionHeader extends StatelessWidget {
  final int count;
  final String filterLabel;
  final VoidCallback onFilterTap;

  const ScheduleSectionHeader({
    super.key,
    required this.count,
    required this.filterLabel,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_rounded, color: _navy, size: 22),
        const SizedBox(width: 8),
        const Text(
          'Assigned Trips',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onFilterTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filterLabel,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _blue, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────── side menu

class DriverMenuItem {
  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback onTap;

  const DriverMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });
}

class DriverSideMenu extends StatelessWidget {
  final String userName;
  final String? driverCode;
  final List<DriverMenuItem> items;

  const DriverSideMenu({
    super.key,
    required this.userName,
    required this.driverCode,
    required this.items,
  });

  String get _initials {
    final parts = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, top + 24, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A2C8F), Color(0xFF1B4FD6)],
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _yellow,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (driverCode != null && driverCode!.isNotEmpty)
                        Text(
                          'Driver ID: $driverCode',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: _blue, size: 20),
              ),
              title: Text(
                item.label,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: item.badge > 0
                  ? Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _yellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.badge}',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
                  : const Icon(Icons.chevron_right, color: _muted),
              onTap: () {
                Navigator.of(context).pop(); // close the menu first
                item.onTap();
              },
            ),
        ],
      ),
    );
  }
}