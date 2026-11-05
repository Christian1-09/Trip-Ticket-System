// features/auth/presentation/NewPasswordScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/password_reset_provider.dart';

import '../../../core/theme/network/api_exception.dart';
import 'auth_ui.dart';

/// Keep in step with MIN_PASSWORD_LENGTH in auth.service.js. Checking
/// here as well isn't duplication for its own sake — it saves a round
/// trip and shows the rule before the user commits to a password.
const int _minPasswordLength = 8;

/// Step 3 of 3 — choose the new password.
class NewPasswordScreen extends ConsumerStatefulWidget {
  final String resetToken;

  const NewPasswordScreen({required this.resetToken, super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Drives the live rule checklist below the field. Both controllers,
    // because the "both fields match" rule reads the confirm box too —
    // listening to only one leaves that tick frozen while you type into
    // the other.
    _passwordController.addListener(_onTyping);
    _confirmController.addListener(_onTyping);
  }

  void _onTyping() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onTyping);
    _confirmController.removeListener(_onTyping);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);

    try {
      await ref.read(passwordResetRepositoryProvider).resetPassword(
        resetToken: widget.resetToken,
        password: _passwordController.text,
      );

      if (!mounted) return;
      await _showSuccess();

      // Pops with true, which unwinds the two screens behind this one and
      // lands back on the login page.
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not reach the server. Check your connection.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showSuccess() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AuthPalette.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: AuthPalette.success, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Password changed',
              style: TextStyle(
                color: AuthPalette.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can now log in with your new password. Anywhere else you '
                  'were signed in has been logged out.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AuthPalette.textMuted,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: AuthPrimaryButton(
              label: 'Back to login',
              showArrow: false,
              onTap: () => Navigator.pop(dialogContext),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AuthPalette.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AuthPage(
        heroTitle: 'Set a new password',
        heroSubtitle: 'Choose something you haven\'t\nused here before.',
        onBack: _busy ? null : () => Navigator.pop(context),
        card: AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthCardHeading(
                  title: 'New password',
                  subtitle: 'Your code was accepted. Set the password you '
                      'will use from now on.',
                ),
                const SizedBox(height: 26),

                const AuthFieldLabel('Password'),
                AuthTextField(
                  controller: _passwordController,
                  hint: 'Enter your new password',
                  icon: Icons.lock_rounded,
                  obscureText: _obscurePassword,
                  enabled: !_busy,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AuthPalette.navy,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < _minPasswordLength) {
                      return 'At least $_minPasswordLength characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                _Rule(
                  met: password.length >= _minPasswordLength,
                  text: 'At least $_minPasswordLength characters',
                ),
                _Rule(
                  met: password.isNotEmpty &&
                      password == _confirmController.text,
                  text: 'Both fields match',
                ),
                const SizedBox(height: 14),

                const AuthFieldLabel('Confirm Password'),
                AuthTextField(
                  controller: _confirmController,
                  hint: 'Re-enter your new password',
                  icon: Icons.lock_reset_rounded,
                  obscureText: _obscureConfirm,
                  enabled: !_busy,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AuthPalette.navy,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'The two passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                AuthPrimaryButton(
                  label: 'Update Password',
                  busy: _busy,
                  onTap: _submit,
                ),
                const SizedBox(height: 16),

                const AuthNotice(
                  icon: Icons.shield_outlined,
                  child: Text(
                    'Changing your password signs you out everywhere else.',
                    style: TextStyle(
                      color: AuthPalette.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final bool met;
  final String text;

  const _Rule({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 15,
            color: met ? AuthPalette.success : AuthPalette.textMuted,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? AuthPalette.success : AuthPalette.textMuted,
              fontSize: 12.5,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}