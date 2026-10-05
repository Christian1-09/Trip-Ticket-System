// features/instructor/presentation/screens/driver_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

import '../../data/driver_detail_model.dart';
import '../providers/fleet_providers.dart';
import '../../trip_ticket/data/fleet_models.dart';

// ─────────────────────────────────────────────────────────── light palette

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _pageBg = Color(0xFFF2F5FA);
const _tileBg = Color(0xFFE8F0FD);
const _divider = Color(0xFFE9EDF4);
const _green = Color(0xFF1FA35B);
const _amber = Color(0xFFE5A400);
const _red = Color(0xFFE5394A);

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

/// Status colours that read well on a white background.
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

class DriverDetailScreen extends ConsumerWidget {
  final String driverId;
  const DriverDetailScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(driverDetailProvider(driverId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _BackBar(onTap: () => Navigator.of(context).pop()),
              Expanded(
                child: detailAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: _blue),
                  ),
                  error: (err, _) => _ErrorView(
                    detail: '$err',
                    onRetry: () =>
                        ref.invalidate(driverDetailProvider(driverId)),
                  ),
                  data: (driver) => _DetailBody(driver: driver),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: _navy, size: 24),
              SizedBox(width: 10),
              Text(
                'Back',
                style: TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).alignLeft();
  }
}

extension on Widget {
  Widget alignLeft() => Align(alignment: Alignment.centerLeft, child: this);
}

class _DetailBody extends StatelessWidget {
  final DriverDetailModel driver;
  const _DetailBody({required this.driver});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _HeroCard(driver: driver),
        const SizedBox(height: 22),
        const _SectionHeader(
          icon: Icons.person,
          title: 'Personal Information',
        ),
        const SizedBox(height: 12),
        _WhiteCard(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Employee ID',
                value: driver.employeeId ?? 'Not set',
                trailing: _StatusPill(status: driver.status),
              ),
              const _RowDivider(),
              _InfoRow(
                icon: Icons.phone,
                label: 'Phone Number',
                value: driver.phone ?? 'Not provided',
                copyable: driver.phone != null,
              ),
              const _RowDivider(),
              _InfoRow(
                icon: Icons.mail,
                label: 'Email Address',
                value: driver.email.isEmpty ? 'Not provided' : driver.email,
                copyable: driver.email.isNotEmpty,
              ),
              const _RowDivider(),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Date Hired',
                value: driver.dateHired == null
                    ? 'Not recorded'
                    : DateFormat('MMMM d, y').format(driver.dateHired!),
                caption: driver.dateHired == null ? null : driver.serviceLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SectionHeader(
          icon: Icons.directions_car,
          title: 'Assigned Vehicle',
          iconColor: _amber,
          tileColor: Color(0xFFFFF3D1),
        ),
        const SizedBox(height: 12),
        if (driver.assignedVehicles.isEmpty)
          const _WhiteCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'No vehicle assigned to this driver.',
                  style: TextStyle(color: _muted, fontSize: 12.5),
                ),
              ),
            ),
          )
        else
          ...driver.assignedVehicles.map(
                (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _VehicleTile(vehicle: vehicle),
            ),
          ),
        const SizedBox(height: 12),
        const _InfoNote(
          text: 'Availability shown here is current. When you book, the '
              'driver is checked again against your chosen date and time.',
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────── hero card

class _HeroCard extends StatelessWidget {
  final DriverDetailModel driver;
  const _HeroCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConfig.mediaUrl(driver.avatarUrl);
    final statusColor = _statusColorLight(driver.status);
    final violation = driver.incidentCount == 0
        ? 'No pending violation'
        : '${driver.incidentCount} incident${driver.incidentCount == 1 ? '' : 's'} recorded';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2C8F), Color(0xFF1B4FD6)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative shapes on the right (stand-in for the photo).
            Positioned(
              right: -40,
              top: -30,
              child: Icon(Icons.trip_origin,
                  size: 190, color: Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFC928).withOpacity(0.85),
                    width: 10,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Row(
                    children: [
                      _Avatar(
                        url: avatarUrl,
                        initials: driver.initials,
                        dotColor: statusColor,
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
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (driver.driverCode != null)
                                  _HeroChip(
                                    icon: Icons.badge_outlined,
                                    label: driver.driverCode!,
                                  ),
                                _HeroChip(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFFC928),
                                  label: driver.hasRating
                                      ? '${driver.ratingLabel}/5.0'
                                      : 'No ratings',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${driver.experienceLabel}  ·  $violation',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Stats strip ──
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _HeroStat(
                          icon: Icons.local_shipping,
                          iconColor: const Color(0xFF7FB2FF),
                          value: '${driver.completedTrips}',
                          label: 'Trips Done',
                        ),
                        const _StatDivider(),
                        _HeroStat(
                          icon: Icons.speed,
                          iconColor: const Color(0xFFFFC928),
                          value: driver.kilometresLabel,
                          label: 'KM Driven',
                        ),
                        const _StatDivider(),
                        _HeroStat(
                          icon: Icons.report_gmailerrorred,
                          iconColor: driver.incidentCount == 0
                              ? const Color(0xFF5BD68E)
                              : const Color(0xFFFF6B78),
                          value: '${driver.incidentCount}',
                          label: 'Incidents',
                        ),
                        const _StatDivider(),
                        _HeroStat(
                          icon: Icons.schedule,
                          iconColor: const Color(0xFF7FD4FF),
                          value: driver.onTimeLabel,
                          label: 'On Time',
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
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String initials;
  final Color dotColor;

  const _Avatar({
    required this.url,
    required this.initials,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3D8BFF),
              backgroundImage: url != null ? NetworkImage(url!) : null,
              child: url == null
                  ? Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              )
                  : null,
            ),
          ),
          Positioned(
            right: 2,
            bottom: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _HeroChip({
    required this.icon,
    required this.label,
    this.iconColor = Colors.white,
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
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
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

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _HeroStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white.withOpacity(0.15),
    );
  }
}

// ────────────────────────────────────────────────────────────── info rows

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: _divider);
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color tileColor;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.iconColor = _blue,
    this.tileColor = _tileBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final bool copyable;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.copyable = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _tileBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: _blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    style: const TextStyle(color: _muted, fontSize: 10.5),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (copyable)
            IconButton(
              tooltip: 'Copy',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded, size: 20, color: _blue),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DriverDirectoryStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColorLight(status);
    return _DotPill(label: status.label, color: color);
  }
}

class _DotPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _DotPill({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 12, color: color)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────── vehicle

class _VehicleTile extends StatelessWidget {
  final AssignedVehicle vehicle;
  const _VehicleTile({required this.vehicle});

  Color get _statusColor {
    switch (vehicle.status) {
      case 'ACTIVE':
        return _green;
      case 'ON_TRIP':
        return _amber;
      case 'MAINTENANCE':
        return Colors.orange;
      default:
        return _red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.mediaUrl(vehicle.imageUrl);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: vehicle.isPrimary
            ? Border.all(color: _amber.withOpacity(0.6), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 70,
              color: const Color(0xFFF1F4F9),
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.directions_car,
                  color: Colors.black26,
                  size: 32,
                ),
              )
                  : const Icon(Icons.directions_car,
                  color: Colors.black26, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.plateNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle.model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _DotPill(label: vehicle.statusLabel, color: _statusColor),
                    _DotPill(
                      label: vehicle.rankLabel,
                      color: vehicle.isPrimary ? _amber : _blue,
                      icon: vehicle.isPrimary ? Icons.star_rounded : Icons.link,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────── footer

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _tileBg.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, size: 18, color: _blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _muted, fontSize: 11.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────── error

class _ErrorView extends StatelessWidget {
  final String detail;
  final VoidCallback onRetry;

  const _ErrorView({required this.detail, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _red, size: 34),
            const SizedBox(height: 10),
            const Text(
              'Could not load this driver',
              style: TextStyle(
                color: _navy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}