// features/auth/presentation/auth_ui.dart
//
// The shared look of every auth screen: login, register, and the three
// password-reset steps.
//
// This was lifted out of LoginScreen.dart, where it lived as private
// classes. Private meant no other screen could use it, and the only way
// to add a screen in the same style was to copy the palette and the
// widgets — which is how a codebase ends up with four slightly different
// shades of navy and a button that's 14px rounded on one screen and 12
// on another.

import 'package:flutter/material.dart';

import '../../../core/theme/media.dart';

/// Screens at least this wide (desktop app, web) show the side-by-side layout.
const double kAuthWideBreakpoint = 900;

class AuthPalette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1D4ED8);
  static const yellow = Color(0xFFFFC629);

  /// The slightly deeper amber used for links, where the button yellow
  /// would be too pale against white.
  static const link = Color(0xFFF5B400);

  static const fieldFill = Color(0xFFEDF3FD);
  static const softFill = Color(0xFFF0F5FD);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
  static const pageBg = Color(0xFFF4F7FC);

  static const danger = Color(0xFFE53935);
  static const success = Color(0xFF16A34A);
}

// ---------------------------------------------------------------------------
// Page shell
// ---------------------------------------------------------------------------

/// The responsive frame every auth screen sits in.
///
/// Narrow: photo header on top, card below, waves at the bottom.
/// Wide:   photo hero on the left, card centred on the right.
///
/// A screen supplies its hero copy and its card; the layout, the swoosh
/// and the waves come for free, so a new step can't accidentally be
/// responsive in a different way from the login.
class AuthPage extends StatelessWidget {
  final String heroTitle;
  final String heroSubtitle;
  final Widget card;

  /// Shown at the top left when the screen is part of a flow the user can
  /// back out of. Null on login and register, which are entry points.
  final VoidCallback? onBack;

  const AuthPage({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.card,
    this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.pageBg,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) =>
            constraints.maxWidth >= kAuthWideBreakpoint
                ? _wide()
                : _narrow(),
          ),
          if (onBack != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 6,
              left: 6,
              // White because it always sits over the navy hero, on both
              // layouts.
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 26),
                tooltip: 'Back',
              ),
            ),
        ],
      ),
    );
  }

  Widget _narrow() {
    return Stack(
      children: [
        const Positioned(left: 0, right: 0, bottom: 0, child: AuthBottomWaves()),
        SingleChildScrollView(
          child: Column(
            children: [
              AuthHeader(title: heroTitle, subtitle: heroSubtitle),
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: card,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wide() {
    return Row(
      children: [
        Expanded(
          flex: 11,
          child: AuthSideHero(title: heroTitle, subtitle: heroSubtitle),
        ),
        Expanded(
          flex: 9,
          child: Stack(
            children: [
              const Positioned(
                  left: 0, right: 0, bottom: 0, child: AuthBottomWaves()),
              Center(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: card,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The white rounded panel the form sits in.
class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.navy.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Centred title and supporting line at the top of a card.
class AuthCardHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthCardHeading({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AuthPalette.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AuthPalette.textMuted,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

/// Phone header: background photo, navy fade, yellow swoosh, logo, greeting.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 290 + topInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppMedia.scheduleHeaderImage,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AuthPalette.navy.withOpacity(0.96),
                  AuthPalette.navy.withOpacity(0.70),
                  AuthPalette.navy.withOpacity(0.0),
                ],
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),
          CustomPaint(painter: AuthSwooshPainter()),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topInset + 20, 24, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JtripsLogo(),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.4,
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

/// Left half on desktop / web: full-height photo with logo, title and
/// highlights.
class AuthSideHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthSideHero({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppMedia.scheduleHeaderImage,
          fit: BoxFit.cover,
          alignment: const Alignment(0.4, 0),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AuthPalette.navy.withOpacity(0.95),
                AuthPalette.navy.withOpacity(0.65),
                AuthPalette.navy.withOpacity(0.10),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AuthPalette.navy.withOpacity(0.55),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        CustomPaint(painter: AuthSwooshPainter()),
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 48, 56, 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const JtripsLogo(),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const _HeroPoint(
                icon: Icons.touch_app_rounded,
                text: 'Book a trip in a few steps',
              ),
              const _HeroPoint(
                icon: Icons.track_changes_rounded,
                text: 'Follow every approval as it happens',
              ),
              const _HeroPoint(
                icon: Icons.verified_user_rounded,
                text: 'Safe, comfortable and reliable trips',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AuthPalette.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AuthPalette.navy, size: 20),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JtripsLogo extends StatelessWidget {
  const JtripsLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 34),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              height: 1.0,
            ),
            children: [
              TextSpan(text: 'JT', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'RIPS', style: TextStyle(color: AuthPalette.yellow)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'TRAVEL MADE EASY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class AuthSwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final yellow = Paint()
      ..color = AuthPalette.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final white = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final main = Path()
      ..moveTo(w * 0.78, -10)
      ..cubicTo(w * 0.60, h * 0.30, w * 0.55, h * 0.70, w * 0.28, h + 10);
    canvas.drawPath(main, yellow);

    final accent = Path()
      ..moveTo(w * 0.84, -10)
      ..cubicTo(w * 0.66, h * 0.32, w * 0.62, h * 0.72, w * 0.36, h + 10);
    canvas.drawPath(accent, white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Decorative blue/yellow waves along the bottom of the screen.
class AuthBottomWaves extends StatelessWidget {
  const AuthBottomWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(painter: _BottomWavesPainter()),
    );
  }
}

class _BottomWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final light = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 0.05, w * 0.65, h * 0.40)
      ..quadraticBezierTo(w * 0.85, h * 0.60, w, h * 0.30)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(light, Paint()..color = const Color(0xFFCFE0FB));

    final blue = Path()
      ..moveTo(0, h * 0.60)
      ..quadraticBezierTo(w * 0.30, h * 0.40, w * 0.55, h * 0.75)
      ..quadraticBezierTo(w * 0.80, h * 1.0, w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      blue,
      Paint()
        ..shader = const LinearGradient(
          colors: [AuthPalette.blue, AuthPalette.navy],
        ).createShader(Offset.zero & size),
    );

    final yellow = Path()
      ..moveTo(w * 0.30, h)
      ..quadraticBezierTo(w * 0.70, h * 0.70, w, h * 0.35);
    canvas.drawPath(
      yellow,
      Paint()
        ..color = AuthPalette.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Form parts
// ---------------------------------------------------------------------------

class AuthFieldLabel extends StatelessWidget {
  final String text;

  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AuthPalette.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool autofocus;

  const AuthTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
    this.validator,
    this.autofocus = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(color: AuthPalette.textDark, fontSize: 14.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AuthPalette.textMuted, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: AuthPalette.navy, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AuthPalette.fieldFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        disabledBorder: border(Colors.transparent),
        focusedBorder: border(AuthPalette.blue, 1.5),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 1.5),
      ),
    );
  }
}

/// The full-width yellow button, with the arrow pinned to the right.
///
/// [busy] swaps the label for a spinner and blocks the tap — every screen
/// in the reset flow makes a network call, and a double tap would send
/// the request twice.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final bool showArrow;

  const AuthPrimaryButton({
    required this.label,
    required this.onTap,
    this.busy = false,
    this.showArrow = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
          BoxShadow(
            color: AuthPalette.yellow.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthPalette.yellow,
          foregroundColor: AuthPalette.textDark,
          disabledBackgroundColor: AuthPalette.yellow.withOpacity(0.55),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: busy
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AuthPalette.textDark,
          ),
        )
            : Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AuthPalette.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (showArrow)
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded,
                    color: AuthPalette.textDark, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child:
      Divider(color: AuthPalette.textMuted.withOpacity(0.25), thickness: 1),
    );
    return Row(
      children: [
        line,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(color: AuthPalette.textMuted, fontSize: 12),
          ),
        ),
        line,
      ],
    );
  }
}

/// The pale rounded panel at the foot of a card, e.g. "Don't have an
/// account? Register".
class AuthFooterAction extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;

  const AuthFooterAction({
    required this.question,
    required this.action,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuthPalette.softFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '$question  ',
                  style: const TextStyle(
                      color: AuthPalette.textDark, fontSize: 13.5),
                ),
              ),
              Text(
                action,
                style: const TextStyle(
                  color: AuthPalette.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  color: AuthPalette.blue, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// A soft informational strip inside a card — used for "we sent a code to
/// this address" and for the development-only code notice.
class AuthNotice extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final Color background;
  final Color border;
  final Color iconColor;

  const AuthNotice({
    required this.icon,
    required this.child,
    this.background = const Color(0xFFF0F5FD),
    this.border = const Color(0xFFD9E4F7),
    this.iconColor = AuthPalette.blue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}