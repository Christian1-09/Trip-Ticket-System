// features/instructor/presentation/widgets/requester_vehicle_card.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/core/theme/media.dart';

import '../../trip_ticket/data/fleet_models.dart';

/// The one vehicle card the requester sees — used by the home carousel and
/// by the Vehicles tab.
///
/// Layout (matches the home design):
/// - Shared scenic background (AppMedia.vehicleBackGround) on every card
/// - Vehicle photo large and low, standing on the road, with a soft shadow
/// - Yellow badge top-left (vehicle status by default, or a custom [badge])
/// - Navy fade at the bottom with name, "capacity • plate", yellow arrow
///
/// Everything is sized from the card's own height, so it looks right at
/// any size the parent gives it.
class RequesterVehicleCard extends StatelessWidget {
  final VehicleDirectoryModel vehicle;
  final VoidCallback? onTap;

  /// The home carousel is fixed-width; the Vehicles tab lets it stretch.
  final double? width;

  /// Optional custom badge text (e.g. 'Popular'). When null the badge shows
  /// the vehicle's status, which is real data rather than a made-up label.
  final String? badge;
  final IconData? badgeIcon;

  /// Enlarges the vehicle photo a little, anchored at its bottom, to make up
  /// for empty space many photos have around the vehicle. 1.0 = as-is.
  final double vehicleScale;

  /// Where the road is in the background image, as a fraction of its
  /// height (0 = top, 1 = bottom). The background is shifted so this line
  /// lands exactly under the vehicle's wheels. Raise it if the car looks
  /// like it's floating above the road, lower it if it's sinking below.
  final double roadLevel;

  /// Pushes ONLY the vehicle photo down, as a fraction of the card height,
  /// to cancel the empty transparent space most photos have under the
  /// wheels. The road and shadow don't move. Raise it if the car still
  /// floats, lower it if the wheels go under the road.
  final double carDrop;

  const RequesterVehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.width,
    this.badge,
    this.badgeIcon,
    this.vehicleScale = 1.12,
    this.roadLevel = 0.88,
    this.carDrop = 0.16,
  });

  /// Badge colors per status. Available uses the design's yellow.
  (Color bg, Color fg, IconData icon) get _statusBadge {
    switch (vehicle.status) {
      case VehicleDirectoryStatus.active:
        return (AppColors.accentYellow, AppColors.homeNavy,
        Icons.check_circle_rounded);
      case VehicleDirectoryStatus.onTrip:
        return (AppColors.homeIconBlue, Colors.white, Icons.route_rounded);
      case VehicleDirectoryStatus.maintenance:
        return (Colors.orange, Colors.white, Icons.build_rounded);
      case VehicleDirectoryStatus.inactive:
        return (Colors.grey.shade600, Colors.white, Icons.block_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.mediaUrl(vehicle.imageUrl);
    final (statusBg, statusFg, statusIcon) = _statusBadge;

    final badgeText = badge ?? vehicle.status.label;
    final badgeBg = badge != null ? AppColors.accentYellow : statusBg;
    final badgeFg = badge != null ? AppColors.homeNavy : statusFg;
    final icon = badgeIcon ?? (badge != null ? Icons.star_rounded : statusIcon);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.homeNavy.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LayoutBuilder(
            builder: (context, c) {
              final h = c.maxHeight;
              final w = c.maxWidth;

              // Bottom strip with the name/details takes ~30% of the card.
              final infoHeight = (h * 0.30).clamp(34.0, 46.0);
              // The vehicle stands right on top of that strip.
              final carBottom = infoHeight - 4;
              final carTop = h * 0.18;

              // Shift the background so its road sits under the wheels.
              // Negative = move up; the strip it uncovers at the bottom is
              // filled with navy, which the text area covers anyway.
              final wheelsY = h - carBottom;
              final bgShift = wheelsY - roadLevel * h;

              return Stack(
                children: [
                  // ── Base colour for the strip the shift uncovers ─────
                  const Positioned.fill(
                    child: ColoredBox(color: AppColors.homeNavyDark),
                  ),

                  // ── Shared scenic background, road under the wheels ──
                  Positioned(
                    left: 0,
                    right: 0,
                    top: bgShift,
                    height: h,
                    child: Image.asset(
                      AppMedia.vehicleBackGround,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),

                  // ── Navy fade at the bottom (text readability) ───────
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55, 1.0],
                          colors: [
                            Colors.transparent,
                            AppColors.homeNavyDark.withOpacity(0.15),
                            AppColors.homeNavyDark.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Ground shadow under the vehicle ──────────────────
                  Positioned(
                    left: w * 0.14,
                    right: w * 0.14,
                    bottom: carBottom - 3,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Vehicle photo: big, low, centred ─────────────────
                  // Dropped by [carDrop] so the wheels — not the photo's
                  // empty bottom edge — touch the road.
                  Positioned(
                    left: 4,
                    right: 4,
                    top: carTop + h * carDrop,
                    bottom: carBottom - h * carDrop,
                    child: Transform.scale(
                      scale: vehicleScale,
                      alignment: Alignment.bottomCenter,
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        // A broken URL shouldn't blank the whole card.
                        errorBuilder: (_, _, _) => const _Placeholder(),
                      )
                          : const _Placeholder(),
                    ),
                  ),

                  // ── Badge (top-left) ─────────────────────────────────
                  Positioned(
                    top: 6,
                    left: 6,
                    right: 6,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 11, color: badgeFg),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                badgeText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: badgeFg,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Name, details, arrow (bottom) ────────────────────
                  Positioned(
                    left: 9,
                    right: 7,
                    bottom: 7,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black38, blurRadius: 4),
                                  ],
                                ),
                              ),
                              Text(
                                '${vehicle.capacityLabel}  •  ${vehicle.plateNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.accentYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppColors.homeNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Icon(
        Icons.directions_car_rounded,
        size: 44,
        color: Colors.white.withOpacity(0.85),
        shadows: const [Shadow(color: Colors.black26, blurRadius: 6)],
      ),
    );
  }
}