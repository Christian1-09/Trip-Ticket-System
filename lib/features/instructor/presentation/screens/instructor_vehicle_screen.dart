// features/instructor/presentation/screens/instructor_vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/core/theme/media.dart';

import 'driver_detail_screen.dart';
import '../providers/fleet_providers.dart';
import '../../trip_ticket/data/fleet_models.dart';

/// Light page colours used only by this screen (the header + summary card
/// stay navy like the rest of the app).
const _pageBg = Color(0xFFF3F5FA);
const _ink = AppColors.homeNavy; // titles / names on the light page
const _muted = Color(0xFF8A93A8); // secondary text on the light page

/// The requester's Vehicles tab: scenic header, summary card, fleet carousel,
/// then the full driver roster. Everything is live data.
class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  final _driversKey = GlobalKey();

  void _scrollToDrivers() {
    final ctx = _driversKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driverDirectoryProvider);
    final vehiclesAsync = ref.watch(vehicleDirectoryProvider);
    final summary = ref.watch(fleetSummaryProvider);
    final topInset = MediaQuery.of(context).padding.top;

    const headerBody = 150.0;
    const summaryHeight = 84.0;
    final headerHeight = topInset + headerBody;

    return Scaffold(
      backgroundColor: _pageBg,
      body: RefreshIndicator(
        edgeOffset: topInset,
        onRefresh: () async {
          refreshFleet(ref);
          await Future.wait([
            ref.read(driverDirectoryProvider.future),
            ref.read(vehicleDirectoryProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            // ---------------- HEADER + SUMMARY ----------------
            SizedBox(
              height: headerHeight + summaryHeight / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: headerHeight,
                    child: _FleetHeader(topInset: topInset),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 0,
                    height: summaryHeight,
                    child: _SummaryCard(
                      summary: summary,
                      onTap: _scrollToDrivers,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ---------------- VEHICLES ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle(
                icon: Icons.directions_car_filled_rounded,
                title: 'Vehicles',
                trailing: summary.totalVehicles == 0
                    ? null
                    : '${summary.availableVehicles} of ${summary.totalVehicles} available',
              ),
            ),
            const SizedBox(height: 12),
            vehiclesAsync.when(
              loading: () => const _SectionLoading(height: 150),
              error: (err, _) => _padded(_SectionError(
                message: 'Could not load the fleet',
                detail: '$err',
                onRetry: () => ref.invalidate(vehicleDirectoryProvider),
              )),
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return _padded(const _SectionEmpty(
                    message: 'No vehicles have been added yet.',
                  ));
                }
                return SizedBox(
                  height: 158,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _VehicleCard(vehicle: vehicles[index]),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ---------------- DRIVERS ----------------
            Padding(
              key: _driversKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle(
                icon: Icons.person_rounded,
                title: 'Drivers',
                trailing: summary.totalDrivers == 0
                    ? null
                    : '${summary.availableDrivers} available',
              ),
            ),
            const SizedBox(height: 12),
            driversAsync.when(
              loading: () => const _SectionLoading(height: 220),
              error: (err, _) => _padded(_SectionError(
                message: 'Could not load drivers',
                detail: '$err',
                onRetry: () => ref.invalidate(driverDirectoryProvider),
              )),
              data: (drivers) {
                if (drivers.isEmpty) {
                  return _padded(const _SectionEmpty(
                    message: 'No drivers have been approved yet.',
                  ));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: drivers
                        .map((driver) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DriverRow(
                        driver: driver,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DriverDetailScreen(driverId: driver.id),
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}

// ---------------------------------------------------------------- header

class _FleetHeader extends StatelessWidget {
  final double topInset;

  const _FleetHeader({required this.topInset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Scenic background (same photo as the Schedule header)
          Image.asset(
            AppMedia.scheduleHeaderImage,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),

          // Navy wash on the left so the title stays readable
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.45, 0.8],
                colors: [
                  AppColors.homeNavyDark.withOpacity(0.92),
                  AppColors.homeNavy.withOpacity(0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Yellow swoosh along the bottom edge
          const CustomPaint(painter: _SwooshPainter()),

          // Icon + title
          Positioned(
            left: 16,
            right: 16,
            top: topInset + 22,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.homeNavyDark.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentYellow, width: 2),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: 'Fleet & '),
                            TextSpan(
                              text: 'Drivers',
                              style: TextStyle(color: AppColors.accentYellow),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Who and what is on campus today.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
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

class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final thick = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.30, h * 1.02, w * 0.70, h * 0.86)
      ..quadraticBezierTo(w * 0.88, h * 0.79, w, h * 0.62);

    final thin = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.32, h * 1.08, w * 0.72, h * 0.93)
      ..quadraticBezierTo(w * 0.90, h * 0.86, w, h * 0.72);

    canvas.drawPath(
      thick,
      Paint()
        ..color = AppColors.accentYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      thin,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------- summary

class _SummaryCard extends StatelessWidget {
  final FleetSummary summary;
  final VoidCallback? onTap;

  const _SummaryCard({required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.homeNavy, AppColors.homeNavyDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeNavyDark.withOpacity(0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              icon: Icons.groups_rounded,
              color: AppColors.accentYellow,
              value: '${summary.totalDrivers}',
              label: 'Drivers',
              onTap: onTap,
            ),
          ),
          _divider(),
          Expanded(
            child: _SummaryCell(
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.statusGreen,
              value: '${summary.availableDrivers}',
              label: 'Available',
              onTap: onTap,
            ),
          ),
          _divider(),
          Expanded(
            child: _SummaryCell(
              icon: Icons.directions_car_filled_rounded,
              color: Colors.redAccent,
              value: '${summary.driversOnTrip}',
              label: 'On trip',
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withOpacity(0.12),
  );
}

class _SummaryCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _SummaryCell({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- vehicle

class _VehicleCard extends StatelessWidget {
  final VehicleDirectoryModel vehicle;
  const _VehicleCard({required this.vehicle});

  /// (badge background, text colour, dot colour)
  (Color, Color, Color) get _badge {
    switch (vehicle.status) {
      case VehicleDirectoryStatus.active:
        return (AppColors.accentYellow, AppColors.homeNavy, AppColors.statusGreen);
      case VehicleDirectoryStatus.onTrip:
        return (AppColors.homeIconBlue, Colors.white, Colors.white);
      case VehicleDirectoryStatus.maintenance:
        return (Colors.orange, Colors.white, Colors.white);
      case VehicleDirectoryStatus.inactive:
        return (Colors.grey.shade600, Colors.white, Colors.white70);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.mediaUrl(vehicle.imageUrl);
    final (badgeBg, badgeFg, dot) = _badge;

    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: AppColors.homeNavyDark,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeNavy.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // ── Photo area ───────────────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Card background stays the plain scenic image
                  Image.asset(AppMedia.vehicleBackGround, fit: BoxFit.cover),
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 22,
                    bottom: 30,
                    child: imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, _, _) =>
                      const _VehiclePlaceholder(),
                    )
                        : const _VehiclePlaceholder(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.homeNavyDark.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.status.label,
                            style: TextStyle(
                              color: badgeFg,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Name, plate, arrow
                  Positioned(
                    left: 10,
                    right: 8,
                    bottom: 6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vehicle.model,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                vehicle.plateNumber,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.accentYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.homeNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer strip ─────────────────────────────────────────
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: AppColors.homeNavyDark,
              child: Row(
                children: [
                  // TODO: add a fuel row here (e.g. "Diesel") once
                  // VehicleDirectoryModel exposes the fuel type.
                  const Icon(Icons.airline_seat_recline_normal_rounded,
                      size: 13, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      vehicle.capacityLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
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

class _VehiclePlaceholder extends StatelessWidget {
  const _VehiclePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.directions_car_rounded,
        size: 40,
        color: Colors.white.withOpacity(0.85),
        shadows: const [Shadow(color: Colors.black26, blurRadius: 6)],
      ),
    );
  }
}

// ---------------------------------------------------------------- driver

/// (text/dot colour, pill background, pill text)
(Color, Color, String) _driverStatusStyle(DriverDirectoryStatus status) {
  switch (status) {
    case DriverDirectoryStatus.available:
      return (const Color(0xFF1FA463), const Color(0xFFE3F6EC), 'AVAILABLE');
    case DriverDirectoryStatus.onTrip:
      return (const Color(0xFFD99A00), const Color(0xFFFFF4D6), 'ON TRIP');
    case DriverDirectoryStatus.offDuty:
      return (const Color(0xFF7A8296), const Color(0xFFECEEF3), 'OFF DUTY');
  }
}

class _DriverRow extends StatelessWidget {
  final DriverDirectoryModel driver;
  final VoidCallback onTap;

  const _DriverRow({required this.driver, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConfig.mediaUrl(driver.avatarUrl);
    final (statusColor, pillBg, pillText) = _driverStatusStyle(driver.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E9F2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.homeNavy.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.homeNavy,
                backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                  driver.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            driver.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (driver.isHeadDriver) ...[
                          const SizedBox(width: 6),
                          const _HeadBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          driver.status.label,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: const Color(0xFFD5D9E4),
                        ),
                        Flexible(
                          child: Text(
                            driver.tripsLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _muted, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Rated drivers show their rating; new ones show a status pill.
              if (driver.hasRating)
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 18, color: AppColors.accentYellow),
                    const SizedBox(width: 3),
                    Text(
                      driver.ratingLabel,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pillText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: _muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadBadge extends StatelessWidget {
  const _HeadBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.homeNavy,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded,
              size: 10, color: AppColors.accentYellow),
          SizedBox(width: 3),
          Text(
            'HEAD',
            style: TextStyle(
              color: AppColors.accentYellow,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- shared

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _ink, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Row(
              children: [
                Text(
                  trailing!,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: _ink, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionLoading extends StatelessWidget {
  final double height;
  const _SectionLoading({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.homeNavy),
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  final String message;
  const _SectionEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E9F2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted, fontSize: 12),
      ),
    );
  }
}

/// One failed section shows an error card; the rest of the screen keeps
/// working. That's why each section calls .when() separately.
class _SectionError extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _SectionError({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 26),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 10),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: AppColors.homeNavy)),
          ),
        ],
      ),
    );
  }
}