import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: adjust this import to wherever your AppMedia class lives.

import '../../../core/theme/media.dart';

/// Colors used by the new light login design.
class _Palette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1D4ED8);
  static const yellow = Color(0xFFFFC629);
  static const fieldFill = Color(0xFFEDF3FD);
  static const registerFill = Color(0xFFF0F5FD);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
  static const pageBg = Color(0xFFF4F7FC);
}

class LoginScreen extends StatefulWidget {
  final void Function({
  required String fullName,
  required String password,
  required bool rememberMe,
  })? onLogin;
  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onRegisterTap;

  const LoginScreen({
    super.key,
    this.onLogin,
    this.onForgotPasswordTap,
    this.onRegisterTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    widget.onLogin?.call(
      fullName: _fullNameController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _Palette.pageBg,
        body: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomWaves(),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const _Header(),
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCard(),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _Palette.navy.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Login to Your Account',
                style: TextStyle(
                  color: _Palette.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Enter your credentials to continue.',
                style: TextStyle(color: _Palette.textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 28),

            const _FieldLabel('Full Name'),
            _AppTextField(
              controller: _fullNameController,
              hint: 'Enter your full name',
              icon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            const _FieldLabel('Password'),
            _AppTextField(
              controller: _passwordController,
              hint: 'Enter your password',
              icon: Icons.lock_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _Palette.navy,
                  size: 22,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
                          activeColor: _Palette.navy,
                          side: const BorderSide(
                              color: _Palette.navy, width: 1.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          color: _Palette.textDark,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onForgotPasswordTap,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFFF5B400),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            _LoginButton(onTap: _handleLogin),
            const SizedBox(height: 22),

            const _OrDivider(),
            const SizedBox(height: 18),

            _RegisterBox(onTap: widget.onRegisterTap),
          ],
        ),
      ),
    );
  }
}

/// Top banner: background photo, navy fade, yellow swoosh, logo and greeting.
class _Header extends StatelessWidget {
  const _Header();

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
                  _Palette.navy.withOpacity(0.96),
                  _Palette.navy.withOpacity(0.70),
                  _Palette.navy.withOpacity(0.0),
                ],
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),
          CustomPaint(painter: _HeaderSwooshPainter()),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topInset + 20, 24, 60),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JtripsLogo(),
                Spacer(),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Login to your account and\ncontinue your journey.',
                  style: TextStyle(
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

class _HeaderSwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final yellow = Paint()
      ..color = _Palette.yellow
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

class _JtripsLogo extends StatelessWidget {
  const _JtripsLogo();

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
              TextSpan(text: 'RIPS', style: TextStyle(color: _Palette.yellow)),
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _Palette.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
    this.validator,
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
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(color: _Palette.textDark, fontSize: 14.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _Palette.textMuted, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, color: _Palette.navy, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _Palette.fieldFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(_Palette.blue, 1.5),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 1.5),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LoginButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _Palette.yellow.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Palette.yellow,
          foregroundColor: _Palette.textDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                color: _Palette.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward_rounded,
                  color: _Palette.textDark, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: _Palette.textMuted.withOpacity(0.25), thickness: 1),
    );
    return Row(
      children: [
        line,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(color: _Palette.textMuted, fontSize: 12),
          ),
        ),
        line,
      ],
    );
  }
}

class _RegisterBox extends StatelessWidget {
  final VoidCallback? onTap;

  const _RegisterBox({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.registerFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?  ",
                style: TextStyle(color: _Palette.textDark, fontSize: 13.5),
              ),
              Text(
                'Register',
                style: TextStyle(
                  color: _Palette.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, color: _Palette.blue, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative blue/yellow waves along the bottom of the screen.
class _BottomWaves extends StatelessWidget {
  const _BottomWaves();

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

    // Soft light-blue wave
    final light = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 0.05, w * 0.65, h * 0.40)
      ..quadraticBezierTo(w * 0.85, h * 0.60, w, h * 0.30)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(light, Paint()..color = const Color(0xFFCFE0FB));

    // Strong blue wave
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
          colors: [_Palette.blue, _Palette.navy],
        ).createShader(Offset.zero & size),
    );

    // Yellow swoosh
    final yellow = Path()
      ..moveTo(w * 0.30, h)
      ..quadraticBezierTo(w * 0.70, h * 0.70, w, h * 0.35);
    canvas.drawPath(
      yellow,
      Paint()
        ..color = _Palette.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}