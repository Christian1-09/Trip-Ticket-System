import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/notifications/presentation/notification_providers.dart';

/// Home header (photo banner):
/// - The sharp photo starts BELOW the status bar + action buttons, so the
///   person's face is never covered. A blurred copy of the same photo fills
///   the strip behind the status bar and fades into it — no visible seam.
/// - Navy fade on the left so the text stays readable
/// - Sun/moon + greeting, large name, tagline, "Search Schedule Trips"
/// - Top-right: small round buttons (urgent travel, notifications, profile)
/// - Yellow swoosh along the bottom-right edge, rounded bottom corners
///
/// The stats card is NOT part of this widget — it sits below it on the
/// home screen as its own card.
class HeaderSection extends ConsumerWidget {
  final String userName;
  final String backgroundImagePath;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onUrgentTravelTap;

  /// How far below the status bar the sharp photo begins. Bigger = the
  /// face sits lower. 0 = photo starts right at the status bar's bottom.
  final double photoDrop;

  /// Which part of the photo stays visible when it's cropped.
  /// x: 1 keeps the right side (the person). y: -1 keeps the top.
  final Alignment imageAlignment;

  /// Height below the status bar.
  static const double contentHeight = 200;

  const HeaderSection({
    super.key,
    required this.userName,
    this.backgroundImagePath = AppMedia.headerImage,
    this.photoDrop = 3,
    this.imageAlignment = const Alignment(1, -1),
    this.onNotificationTap,
    this.onProfileTap,
    this.onSearchTap,
    this.onUrgentTravelTap,
  });

  int get _hour => DateTime.now().hour;

  String get _greeting {
    if (_hour < 12) return 'Good Morning';
    if (_hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData get _greetingIcon =>
      _hour < 18 ? Icons.wb_sunny_rounded : Icons.nightlight_round;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final topInset = MediaQuery.of(context).padding.top;
    final photoTop = topInset + photoDrop;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(26),
        bottomRight: Radius.circular(26),
      ),
      child: SizedBox(
        height: topInset + contentHeight,
        child: Stack(
          children: [
            // ── 1. Blurred copy fills everything (mainly the status bar) ──
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Image.asset(
                  backgroundImagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // ── 2. Sharp photo, dropped below the status bar ─────────────
            Positioned(
              top: photoTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: ShaderMask(
                // Fade the photo's top edge into the blurred strip.
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.14],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  backgroundImagePath,
                  fit: BoxFit.cover,
                  alignment: imageAlignment,
                ),
              ),
            ),

            // ── Navy fade on the left (text readability) ─────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.38, 0.60],
                    colors: [
                      AppColors.homeNavy.withOpacity(0.90),
                      AppColors.homeNavy.withOpacity(0.50),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Soft dark band behind the status bar ─────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset + 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.homeNavyDark.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Yellow swoosh (bottom-right) ─────────────────────────────
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 64,
              child: CustomPaint(painter: _SwooshPainter()),
            ),

            // ── Top-right actions: small separate circles ────────────────
            Positioned(
              top: topInset + 4,
              right: 10,
              child: Row(
                children: [
                  if (onUrgentTravelTap != null) ...[
                    _HeaderIconButton(
                      icon: Icons.bolt_rounded,
                      background: AppColors.accentYellow,
                      iconColor: AppColors.homeNavy,
                      tooltip: 'Urgent travel',
                      onTap: onUrgentTravelTap,
                    ),
                    const SizedBox(width: 6),
                  ],
                  _HeaderIconButton(
                    icon: Icons.notifications_rounded,
                    tooltip: 'Notifications',
                    badge: unreadCount,
                    onTap: onNotificationTap,
                  ),
                  if (onProfileTap != null) ...[
                    const SizedBox(width: 6),
                    _HeaderIconButton(
                      icon: Icons.person_rounded,
                      tooltip: 'Profile',
                      onTap: onProfileTap,
                    ),
                  ],
                ],
              ),
            ),

            // ── Greeting, name, tagline ──────────────────────────────────
            Positioned(
              left: 18,
              top: topInset + 14,
              right: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_greetingIcon,
                          color: AppColors.accentYellow, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.accentYellow,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$userName!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Where are you heading today?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Safe trips. Better journeys.',
                    maxLines: 1,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            // ── Search button ────────────────────────────────────────────
            Positioned(
              left: 18,
              bottom: 24,
              child: _SearchButton(onTap: onSearchTap),
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

class _SearchButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SearchButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
        decoration: BoxDecoration(
          color: AppColors.accentYellow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, color: AppColors.homeNavy, size: 18),
            SizedBox(width: 8),
            Text(
              'Search Schedule Trips',
              style: TextStyle(
                color: AppColors.homeNavy,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded,
                color: AppColors.homeNavy, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Small round header button with a white ring and optional unread [badge].
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? background;
  final Color iconColor;
  final int badge;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.background,
    this.iconColor = Colors.white,
    this.badge = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background ?? AppColors.homeNavy.withOpacity(0.85),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            if (badge > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: badge > 9 ? 4 : 0),
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.homeNavy, width: 1.5),
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: const TextStyle(
                      color: AppColors.homeNavy,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Yellow band sweeping up to the right edge, with a white highlight.
class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final band = Path()
      ..moveTo(w * 0.50, h)
      ..quadraticBezierTo(w * 0.82, h * 0.78, w, h * 0.10)
      ..lineTo(w, h * 0.45)
      ..quadraticBezierTo(w * 0.86, h * 1.0, w * 0.68, h)
      ..close();
    canvas.drawPath(band, Paint()..color = AppColors.accentYellow);

    final highlight = Path()
      ..moveTo(w * 0.42, h)
      ..quadraticBezierTo(w * 0.80, h * 0.66, w, h * -0.05);
    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}