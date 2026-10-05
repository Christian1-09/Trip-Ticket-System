// features/instructor/presentation/widgets/driver_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

import '../../trip_ticket/data/fleet_models.dart';

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _tileBg = Color(0xFFE8F0FD);
const _green = Color(0xFF1FA35B);
const _amber = Color(0xFFE5A400);

/// Expands a driver the directory has already loaded.
///
/// No network call: everything shown here came with the directory response,
/// so opening the sheet is instant and can't fail or spin.
Future<void> showDriverDetailSheet(
    BuildContext context,
    DriverDirectoryModel driver,
    ) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DriverDetailSheet(driver: driver),
  );
}

/// Kept for other files that import it (dark theme colours).
Color driverStatusColor(DriverDirectoryStatus status) {
  switch (status) {
    case DriverDirectoryStatus.available:
      return AppColors.statusGreen;
    case DriverDirectoryStatus.onTrip:
      return AppColors.accentYellow;
    case DriverDirectoryStatus.offDuty:
      return AppColors.textSecondary;
  }
}

Color _statusColorLight(DriverDirectoryStatus status) {
  switch (status) {
    case DriverDirectoryStatus.available:
      return _green;
    case DriverDirectoryStatus.onTrip:
      return _amber;
    case DriverDirectoryStatus.offDuty:
      return _muted;
  }
}

class _DriverDetailSheet extends StatelessWidget {
  final DriverDirectoryModel driver;
  const _DriverDetailSheet({required this.driver});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConfig.mediaUrl(driver.avatarUrl);
    final statusColor = _statusColorLight(driver.status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5DBE6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // ── Blue header block ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A2C8F), Color(0xFF1B4FD6)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.25),
                          ),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF3D8BFF),
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? Text(
                              driver.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 3,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.isHeadDriver ? 'HEAD DRIVER' : 'DRIVER',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          driver.fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (driver.driverCode != null)
                              _HeaderChip(
                                icon: Icons.badge_outlined,
                                label: driver.driverCode!,
                              ),
                            _HeaderChip(
                              icon: Icons.circle,
                              iconColor: statusColor,
                              iconSize: 8,
                              label: driver.status.label,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Stats ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.route_outlined,
                      value: '${driver.completedTrips}',
                      label: driver.completedTrips == 1
                          ? 'Completed trip'
                          : 'Completed trips',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.star_rounded,
                      iconColor: driver.hasRating ? _amber : _muted,
                      tileColor: driver.hasRating
                          ? const Color(0xFFFFF3D1)
                          : _tileBg,
                      value: driver.ratingLabel,
                      label: driver.ratingCountLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Note ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _tileBg.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, size: 17, color: _blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Availability is checked against the date and time you '
                          'choose when booking, so a driver shown as available '
                          'here may still be busy for your schedule.',
                      style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
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

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final double iconSize;

  const _HeaderChip({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
    this.iconSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color tileColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = _blue,
    this.tileColor = _tileBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: tileColor, shape: BoxShape.circle),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}