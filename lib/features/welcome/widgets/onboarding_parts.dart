// features/welcome/widgets/onboarding_parts.dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

/// Optional UI card drawn on top of a slide's background picture.
enum OnboardingOverlay { none, selectVehicle, bookingConfirmed }

class OnboardingSlide {
  final String image;
  final String titleTop; // navy line
  final String titleBottom; // yellow line
  final String body;
  final OnboardingOverlay overlay;

  const OnboardingSlide({
    required this.image,
    required this.titleTop,
    required this.titleBottom,
    required this.body,
    this.overlay = OnboardingOverlay.none,
  });
}

const _border = Color(0xFFE3E8F2);
const _dotInactive = Color(0xFFD5DBEA);
const _yellowLight = Color(0xFFFFD95A);

// ─────────────────────────────────────────────────────────────────────────────
// Brand header — pin logo + "Trip Ticket / Travel Made Easy"
// ─────────────────────────────────────────────────────────────────────────────

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  static const _shadow = [
    Shadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/welcome/logo.png', // 👉 your logo
          width: 54,
          height: 54,
          errorBuilder: (_, __, ___) => const _LogoFallback(),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trip Ticket',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                shadows: _shadow,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Travel Made Easy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                shadows: _shadow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Used until assets/welcome/logo.png exists.
class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_yellowLight, AppColors.accentYellow],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: const Icon(Icons.location_on_rounded,
          color: AppColors.homeNavy, size: 30),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero — background picture + optional card
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingHero extends StatelessWidget {
  final OnboardingSlide slide;
  final double topInset; // space kept free for the logo header
  final double bottomInset; // space hidden behind the white panel

  const OnboardingHero({
    super.key,
    required this.slide,
    required this.topInset,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          slide.image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => const _HeroFallback(),
        ),
        if (slide.overlay != OnboardingOverlay.none)
          Positioned(
            top: topInset,
            bottom: bottomInset,
            left: 18,
            right: 18,
            child: switch (slide.overlay) {
              OnboardingOverlay.selectVehicle => const _SelectVehicleOverlay(),
              OnboardingOverlay.bookingConfirmed => const _BookingConfirmedOverlay(),
              OnboardingOverlay.none => const SizedBox.shrink(),
            },
          ),
      ],
    );
  }
}

/// Blue sky gradient shown until your background images are added.
class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.homeNavyDark, AppColors.homeIconBlue, Color(0xFF8EC5FF)],
        ),
      ),
    );
  }
}

// ── Slide 2: "Select Vehicle" card + shield badge ──────────────────────────

class _SelectVehicleOverlay extends StatelessWidget {
  const _SelectVehicleOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(-1, 0.1),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 196,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.9)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.homeIconBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.directions_bus_filled_rounded,
                                color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 8),
                          const Text('Select Vehicle',
                              style: TextStyle(
                                  color: AppColors.homeNavy,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _VehicleOption(
                          name: 'Van',
                          seats: '12 seats',
                          icon: Icons.airport_shuttle_rounded,
                          selected: true),
                      const SizedBox(height: 8),
                      const _VehicleOption(
                          name: 'Bus',
                          seats: '45 seats',
                          icon: Icons.directions_bus_rounded),
                      const SizedBox(height: 8),
                      const _VehicleOption(
                          name: 'Car',
                          seats: '4 seats',
                          icon: Icons.directions_car_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Align(
          alignment: Alignment(0.95, -0.05),
          child: _Badge(icon: Icons.verified_user_rounded),
        ),
      ],
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final String name;
  final String seats;
  final IconData icon;
  final bool selected;

  const _VehicleOption({
    required this.name,
    required this.seats,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.homeIconBlue : _border,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: selected
            ? [
          BoxShadow(
            color: AppColors.homeIconBlue.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ]
            : null,
      ),
      child: Row(
        children: [
          // Radio
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.homeIconBlue : const Color(0xFFB8C1D6),
                width: 1.6,
              ),
            ),
            child: selected
                ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.homeIconBlue, shape: BoxShape.circle),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Container(
            width: 50,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.homeTileBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.homeIconBlue, size: 24),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: AppColors.homeNavy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.person_rounded,
                      size: 11, color: AppColors.homeTextMuted),
                  const SizedBox(width: 2),
                  Text(seats,
                      style: const TextStyle(
                          color: AppColors.homeTextMuted, fontSize: 10.5)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Slide 3: phone with "Booking Confirmed!" + bell badge ──────────────────

class _BookingConfirmedOverlay extends StatelessWidget {
  const _BookingConfirmedOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, right: 44),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(angle: -0.05, child: const _PhoneMock()),
              const Positioned(
                top: -14,
                right: -46,
                child: _Badge(icon: Icons.notifications_rounded, square: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneMock extends StatelessWidget {
  const _PhoneMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.homeGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.homeGreen.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            const Text('Booking Confirmed!',
                style: TextStyle(
                    color: AppColors.homeNavy,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            const Text('Your trip is successfully booked.',
                style: TextStyle(color: AppColors.homeTextMuted, fontSize: 10.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.homeTileBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.airport_shuttle_rounded,
                            color: AppColors.homeIconBlue, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Van',
                              style: TextStyle(
                                  color: AppColors.homeNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                          Text('Oct 26, 2026 • 10:55 AM',
                              style: TextStyle(
                                  color: AppColors.homeTextMuted, fontSize: 9.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Zamboanga  →  Dipolog',
                      style: TextStyle(
                          color: AppColors.homeNavy,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.homeIconBlue, AppColors.homeNavy],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('View Ticket',
                  style: TextStyle(
                      color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold floating badge (shield on slide 2, bell on slide 3).
class _Badge extends StatelessWidget {
  final IconData icon;
  final bool square;
  const _Badge({required this.icon, this.square = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_yellowLight, AppColors.accentYellow, Color(0xFFF2A900)],
        ),
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(14) : null,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// White curved panel
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPanel extends StatelessWidget {
  final OnboardingSlide slide;
  final int index;
  final int count;
  final String buttonLabel;
  final VoidCallback onNext;
  final ValueChanged<int> onDotTap;

  const OnboardingPanel({
    super.key,
    required this.slide,
    required this.index,
    required this.count,
    required this.buttonLabel,
    required this.onNext,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PanelPainter(),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 92, 24, 56),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _SlideText(key: ValueKey(index), slide: slide),
                  ),
                ),
              ),
              _Dots(index: index, count: count, onTap: onDotTap),
              const SizedBox(height: 24),
              _PillButton(label: buttonLabel, onTap: onNext),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideText extends StatelessWidget {
  final OnboardingSlide slide;
  const _SlideText({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${slide.titleTop}\n',
                  style: const TextStyle(color: AppColors.homeNavy),
                ),
                TextSpan(
                  text: slide.titleBottom,
                  style: const TextStyle(
                    color: AppColors.accentYellow,
                    shadows: [
                      Shadow(
                          color: Color(0x22000000),
                          blurRadius: 2,
                          offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          slide.body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.homeNavy,
            fontSize: 15.5,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int index;
  final int count;
  final ValueChanged<int> onTap;
  const _Dots({required this.index, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++)
          GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 7),
              width: i == index ? 12 : 10,
              height: i == index ? 12 : 10,
              decoration: BoxDecoration(
                color: i == index ? AppColors.accentYellow : _dotInactive,
                shape: BoxShape.circle,
                boxShadow: i == index
                    ? [
                  BoxShadow(
                    color: AppColors.accentYellow.withOpacity(0.5),
                    blurRadius: 6,
                  )
                ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_yellowLight, AppColors.accentYellow],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Row(
                  key: ValueKey(label),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.homeNavy,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.homeNavy, size: 26),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the white panel with its curved top edge, the blue band and yellow
/// swoosh above it, and the blue/yellow wave along the bottom.
class _PanelPainter extends CustomPainter {
  Path _topCurve(Size s, double dy) {
    final w = s.width;
    return Path()
      ..moveTo(0, 80 + dy)
      ..cubicTo(w * 0.35, 24 + dy, w * 0.65, 62 + dy, w, 32 + dy);
  }

  Path _fillBelow(Path curve, Size s) => Path.from(curve)
    ..lineTo(s.width, s.height)
    ..lineTo(0, s.height)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final full = Rect.fromLTWH(0, 0, w, h);

    // Blue band peeking above the white edge.
    canvas.drawPath(
      _fillBelow(_topCurve(size, -20), size),
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.homeIconBlue, AppColors.homeNavy],
        ).createShader(full),
    );

    // Yellow swoosh (strong on the left, fading to the right).
    canvas.drawPath(
      _topCurve(size, -10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            AppColors.accentYellow,
            AppColors.accentYellow,
            AppColors.accentYellow.withOpacity(0),
          ],
          stops: const [0, 0.35, 0.75],
        ).createShader(full),
    );

    // White body with a soft shadow on its edge.
    final white = _fillBelow(_topCurve(size, 0), size);
    canvas.drawShadow(white, const Color(0x55000000), 6, false);
    canvas.drawPath(white, Paint()..color = Colors.white);

    // Bottom wave: blue fill + yellow line (strong on the right).
    Path bottomCurve(double dy) => Path()
      ..moveTo(0, h - 16 + dy)
      ..cubicTo(w * 0.3, h - 4 + dy, w * 0.62, h - 58 + dy, w, h - 48 + dy);

    canvas.drawPath(
      bottomCurve(-7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [AppColors.accentYellow.withOpacity(0), AppColors.accentYellow],
          stops: const [0.3, 0.9],
        ).createShader(full),
    );
    canvas.drawPath(
      _fillBelow(bottomCurve(0), size),
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.homeIconBlue, AppColors.homeNavyDark],
        ).createShader(full),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}