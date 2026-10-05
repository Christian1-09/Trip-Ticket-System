// features/driver/presentation/widgets/driver_home_widgets.dart
//
// Light "home" widgets used only by the driver home screen, so the shared
// instructor widgets (SearchBarWidget, DashboardActionCard, DriverHeader)
// keep their current look.
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/media.dart';

// ─────────────────────────────────────────────────────────── palette

const kDhNavy = Color(0xFF0B1B3F);
const kDhBlue = Color(0xFF1E6FE8);
const kDhMuted = Color(0xFF6B7385);
const kDhPageBg = Color(0xFFF2F5FA);
const kDhYellow = Color(0xFFFFC928);
const kDhGreen = Color(0xFF1FA35B);

// ─────────────────────────────────────────────────────────── header

class DriverHomeHeader extends StatelessWidget {
  final String userName;
  final String driverId;
  final bool hasUnread;
  final VoidCallback? onNotificationTap;

  const DriverHomeHeader({
    super.key,
    required this.userName,
    required this.driverId,
    this.hasUnread = true,
    this.onNotificationTap,
  });

  (String, IconData) get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return ('Good Morning', Icons.wb_sunny_outlined);
    if (h < 18) return ('Good Afternoon', Icons.wb_sunny_rounded);
    return ('Good Evening', Icons.nights_stay_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final (greet, greetIcon) = _greeting;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
        height: 232 + top,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background photo
            Image.asset(
              AppMedia.scheduleHeaderImage,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF1B4FD6)),
            ),
            // Blue fade from the left so the text stays readable
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
            // Soft darkening at the bottom where the search bar overlaps
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
            // Yellow arc, bottom-left accent
            Positioned(
              left: -60,
              bottom: -70,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kDhYellow.withOpacity(0.9), width: 12),
                ),
              ),
            ),
            // Bell
            Positioned(
              top: top + 10,
              right: 16,
              child: _Bell(hasUnread: hasUnread, onTap: onNotificationTap),
            ),
            // Text
            Positioned(
              left: 20,
              right: 150,
              top: top + 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        greet,
                        style: const TextStyle(
                          color: kDhYellow,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(greetIcon, color: kDhYellow, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$userName!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (driverId.isNotEmpty)
                    Text(
                      'Driver ID: $driverId',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: kDhYellow, width: 2.5),
                      ),
                    ),
                    child: Text(
                      'Safe drives. Happy passengers.\nKeep it up!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                        height: 1.35,
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

class _Bell extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback? onTap;
  const _Bell({required this.hasUnread, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_rounded, color: Colors.white, size: 21),
              if (hasUnread)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: kDhYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1B4FD6), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── search

class DriverSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const DriverSearchBar({super.key, this.onChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kDhNavy.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: kDhMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: kDhNavy, fontSize: 14),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search schedule trips...',
                hintStyle: TextStyle(color: kDhMuted, fontSize: 14),
              ),
            ),
          ),
          Material(
            color: kDhYellow,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onFilterTap,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.tune_rounded, color: kDhNavy, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── stats

class DriverStat {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String caption;
  final VoidCallback? onTap;

  const DriverStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.caption,
    this.onTap,
  });
}

class DriverStatsRow extends StatelessWidget {
  final List<DriverStat> items;
  const DriverStatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _StatCard(stat: items[i])),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final DriverStat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: stat.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kDhNavy.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(stat.icon, size: 16, color: stat.color),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: stat.color == kDhYellow ? const Color(0xFFB58900) : stat.color,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      stat.value,
                      style: const TextStyle(
                        color: kDhNavy,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      stat.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kDhMuted, fontSize: 8.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: kDhMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── action tiles

class DriverActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final IconData watermark;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const DriverActionTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.watermark,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B4FD6), Color(0xFF0A2C8F)],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -6,
                  child: Icon(watermark,
                      size: 92, color: Colors.white.withOpacity(0.08)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 20, color: iconColor),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 11.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 26,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: kDhYellow,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white, size: 22),
                        ],
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────── section header

class DriverSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onViewAll;

  const DriverSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.route_rounded, color: kDhBlue, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: kDhNavy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: kDhBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: kDhBlue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        const Spacer(),
        Material(
          color: Colors.white,
          shape: StadiumBorder(
            side: BorderSide(color: kDhBlue.withOpacity(0.35)),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onViewAll,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      color: kDhBlue,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 15, color: kDhBlue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}