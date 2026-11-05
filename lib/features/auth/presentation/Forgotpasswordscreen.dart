// features/auth/presentation/ForgotPasswordScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/password_reset_provider.dart';

import '../../../core/theme/network/api_exception.dart';
import 'VerifyCodeScreen.dart';
import 'auth_ui.dart';

/// Step 1 of 3 — ask for the email the code should go to.
///
/// Note the copy: "if that address is registered". The server answers
/// identically for a known and an unknown address so this endpoint can't
/// be used to discover who has an account, and the screen has to tell the
/// same truth — promising "we've sent you a code" would be a lie half the
/// time and would also give the game away by implication.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    setState(() => _busy = true);

    try {
      final devCode =
      await ref.read(passwordResetRepositoryProvider).requestCode(email);

      if (!mounted) return;

      // Each step pops with `true` once the reset is finished, so the
      // whole stack unwinds back to the login screen without anyone
      // having to guess how deep it is.
      final done = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: email, devCode: devCode),
        ),
      );

      if (done == true && mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not reach the server. Check your connection.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AuthPalette.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AuthPage(
        heroTitle: 'Forgot Password?',
        heroSubtitle: "It happens. We'll send a code\nto get you back in.",
        onBack: _busy ? null : () => Navigator.pop(context),
        card: AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthCardHeading(
                  title: 'Reset your password',
                  subtitle:
                  'Enter the email address on your account and we will '
                      'send you a 6-digit code.',
                ),
                const SizedBox(height: 26),

                const AuthFieldLabel('Email Address'),
                AuthTextField(
                  controller: _emailController,
                  hint: 'Enter your email address',
                  icon: Icons.mail_rounded,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Email address is required';
                    // Deliberately loose. The server is the real judge of
                    // whether an address exists; this only catches typing
                    // a name into the email box.
                    if (!text.contains('@') || !text.contains('.')) {
                      return "That doesn't look like an email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                const AuthNotice(
                  icon: Icons.info_outline_rounded,
                  child: Text(
                    'You can log in with your full name, but a reset code can '
                        'only be sent to an email address.',
                    style: TextStyle(
                      color: AuthPalette.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                AuthPrimaryButton(
                  label: 'Send Code',
                  busy: _busy,
                  onTap: _submit,
                ),
                const SizedBox(height: 22),

                const AuthOrDivider(),
                const SizedBox(height: 18),

                AuthFooterAction(
                  question: 'Remembered it?',
                  action: 'Back to login',
                  onTap: _busy ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}