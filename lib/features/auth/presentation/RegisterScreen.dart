import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/media.dart';
// TODO: adjust this import to wherever your AppMedia class lives.

enum UserRole {
  faculty('Faculty'),
  staff('Staff'),
  ssgPresident('SSG President'),
  driver('Driver');

  final String label;
  const UserRole(this.label);
}

/// Colors used by the light auth design (same as LoginScreen).
class _Palette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1D4ED8);
  static const yellow = Color(0xFFFFC629);
  static const fieldFill = Color(0xFFEDF3FD);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
  static const pageBg = Color(0xFFF4F7FC);
}

class RegisterScreen extends StatefulWidget {
  /// Called after all fields pass validation. Wire this up to your
  /// auth/backend call later — form data is already validated by the time
  /// this fires.
  final void Function({
  required String fullName,
  required String email,
  required String phone,
  required UserRole role,
  required String password,
  })? onRegister;

  final VoidCallback? onLoginTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const RegisterScreen({
    super.key,
    this.onRegister,
    this.onLoginTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _countryCode = '+63';

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole? _selectedRole;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    if (_selectedRole == null) {
      _showSnack('Please select a role.');
      return;
    }

    if (!_agreedToTerms) {
      _showSnack('Please agree to the Terms & Conditions to continue.');
      return;
    }

    // Strip spaces and a leading 0 (e.g. 0908...) so the result is +63908...
    var localNumber = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    if (localNumber.startsWith('0')) localNumber = localNumber.substring(1);

    widget.onRegister?.call(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '$_countryCode$localNumber',
      role: _selectedRole!,
      password: _passwordController.text,
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _Palette.pageBg,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const _Header(),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCard(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
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
            const SizedBox(height: 16),

            const _FieldLabel('Email Address'),
            _AppTextField(
              controller: _emailController,
              hint: 'Enter your email address',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Phone Number'),
            _PhoneField(
              controller: _phoneController,
              countryCode: _countryCode,
              validator: (value) {
                final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10 || digits.length > 11) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Role'),
            _RoleDropdown(
              value: _selectedRole,
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Password'),
            _AppTextField(
              controller: _passwordController,
              hint: 'Create a password',
              icon: Icons.lock_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: _VisibilityToggle(
                obscured: _obscurePassword,
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            const _FieldLabel('Confirm Password'),
            _AppTextField(
              controller: _confirmPasswordController,
              hint: 'Confirm your password',
              icon: Icons.lock_rounded,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: _VisibilityToggle(
                obscured: _obscureConfirmPassword,
                onTap: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            _TermsCheckbox(
              value: _agreedToTerms,
              onChanged: (value) =>
                  setState(() => _agreedToTerms = value ?? false),
              onTermsTap: widget.onTermsTap,
              onPrivacyTap: widget.onPrivacyTap,
            ),
            const SizedBox(height: 22),

            _RegisterButton(onTap: _handleRegister),
            const SizedBox(height: 22),

            const _OrDivider(),
            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: widget.onLoginTap,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: _Palette.textDark,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: TextStyle(
                          color: _Palette.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// Top banner: background photo, navy fade, yellow swoosh, logo and intro.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 250 + topInset,
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
            padding: EdgeInsets.fromLTRB(24, topInset + 16, 24, 44),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JtripsLogo(),
                Spacer(),
                Text(
                  'Create Your Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Join JTRIPS and start booking\nsafe, comfortable, and\nreliable trips.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
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
        const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 30),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 34,
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

/// Shared filled, borderless input decoration.
InputDecoration _fieldDecoration({
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(vertical: 18),
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _Palette.textMuted, fontSize: 14),
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minWidth: 48),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _Palette.fieldFill,
    contentPadding: contentPadding,
    border: border(Colors.transparent),
    enabledBorder: border(Colors.transparent),
    focusedBorder: border(_Palette.blue, 1.5),
    errorBorder: border(Colors.redAccent),
    focusedErrorBorder: border(Colors.redAccent, 1.5),
  );
}

Widget _prefixIcon(IconData icon) => Padding(
  padding: const EdgeInsets.only(left: 14, right: 10),
  child: Icon(icon, color: _Palette.navy, size: 24),
);

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(color: _Palette.textDark, fontSize: 14.5),
      decoration: _fieldDecoration(
        hint: hint,
        prefixIcon: _prefixIcon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;

  const _VisibilityToggle({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: _Palette.navy,
        size: 22,
      ),
      onPressed: onTap,
    );
  }
}

/// Phone input with a "📞 +63 ⌄ |" prefix, like the mockup.
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String countryCode;
  final String? Function(String?)? validator;

  const _PhoneField({
    required this.controller,
    required this.countryCode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = Padding(
      padding: const EdgeInsets.only(left: 14, right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_rounded, color: _Palette.navy, size: 22),
          const SizedBox(width: 14),
          Text(
            countryCode,
            style: const TextStyle(
              color: _Palette.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: _Palette.navy, size: 20),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 24,
            color: _Palette.textMuted.withOpacity(0.3),
          ),
        ],
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
        LengthLimitingTextInputFormatter(14),
      ],
      validator: validator,
      style: const TextStyle(color: _Palette.textDark, fontSize: 14.5),
      decoration: _fieldDecoration(
        hint: 'Enter your phone number',
        prefixIcon: prefix,
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final UserRole? value;
  final ValueChanged<UserRole?> onChanged;

  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const Padding(
        padding: EdgeInsets.only(right: 8),
        child: Icon(Icons.keyboard_arrow_down_rounded,
            color: _Palette.navy, size: 26),
      ),
      style: const TextStyle(color: _Palette.textDark, fontSize: 14.5),
      validator: (value) => value == null ? 'Please select a role' : null,
      decoration: _fieldDecoration(
        hint: 'Select your role',
        prefixIcon: _prefixIcon(Icons.groups_rounded),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
      items: UserRole.values
          .map((role) => DropdownMenuItem(
        value: role,
        child: Text(role.label),
      ))
          .toList(),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      color: _Palette.blue,
      fontWeight: FontWeight.w700,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: _Palette.navy,
            side: const BorderSide(color: _Palette.navy, width: 1.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: _Palette.textDark,
                fontSize: 13,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: linkStyle,
                  recognizer: onTermsTap != null
                      ? (TapGestureRecognizer()..onTap = onTermsTap)
                      : null,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: linkStyle,
                  recognizer: onPrivacyTap != null
                      ? (TapGestureRecognizer()..onTap = onPrivacyTap)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RegisterButton({required this.onTap});

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
              'Register Account',
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