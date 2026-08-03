import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

/// Header matching the design:
/// - Deep navy gradient background
/// - Notification bell (top-right) with yellow badge
/// - GOOD MORNING + large name + subtitle on the left
/// - Urgent Travel pill button on the left
/// - Large decorative ring + full-body person image on the right
///
/// [personImagePath]: set to an asset path e.g. 'assets/images/person.png'
///   when you have the real photo. Leave null to use the placeholder icon.
class HeaderSection extends StatelessWidget {
  final String userName;
  final String? personImagePath;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onUrgentTravelTap;

  const HeaderSection({
    super.key,
    required this.userName,
    this.personImagePath = AppMedia.model,
    this.onNotificationTap,
    this.onUrgentTravelTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        height: 240,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFF1565C0), // vivid mid-blue (top-left)
              Color(0xFF0D2B8E), // deep royal blue (centre)
              Color(0xFF071166), // darkest navy (bottom-right)
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Decorative outer ring ──────────────────────────────────────
            Positioned(
              right: -45,
              bottom: 80,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentYellow.withOpacity(0.3),
                    width: 30,
                  ),
                )
              ),
            ),
            // ── Inner decorative ring (tighter, slightly lighter) ──────────
            Positioned(
              right: 10,
              bottom: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 20,
                  ),
                ),
              ),
            ),

            // ── Person photo / placeholder ─────────────────────────────────
            Positioned(
              right: 20,
              bottom: -40,
              child: personImagePath != null
                  ? Image.asset(
                personImagePath!,
                height: 310,
                fit: BoxFit.fitHeight,
              )
                  : _PersonPlaceholder(height: 220),
            ),

            // ── Notification bell (top-right) ─────────────────────────────
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.14),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    // Yellow dot badge
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Text content + button (left half) ─────────────────────────
            Positioned(
              left: 20,
              top: 20,
              right: 150, // keeps text from overlapping the person image
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'GOOD MORNING',
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$userName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "How's the trip today?",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _UrgentTravelButton(onTap: onUrgentTravelTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _UrgentTravelButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _UrgentTravelButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.accentYellow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.75),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bolt_rounded, color: Colors.black, size: 16),
            SizedBox(width: 6),
            Text(
              'Urgent Travel',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-height person placeholder used until a real asset is provided.
class _PersonPlaceholder extends StatelessWidget {
  final double height;

  const _PersonPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 0.55,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Head
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white54, size: 32),
          ),
          const SizedBox(height: 2),
          // Body silhouette
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}