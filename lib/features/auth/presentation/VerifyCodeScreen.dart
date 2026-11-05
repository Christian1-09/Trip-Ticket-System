// features/auth/presentation/VerifyCodeScreen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/password_reset_provider.dart';

import '../../../core/theme/network/api_exception.dart';
import 'NewPasswordScreen.dart';
import 'auth_ui.dart';

/// Matches RESEND_COOLDOWN_MS in auth.service.js. The server ignores a
/// second request inside that window, so the button stays disabled rather
/// than silently doing nothing.
const int _resendCooldownSeconds = 60;

/// Step 2 of 3 — type the six digits from the email.
class VerifyCodeScreen extends ConsumerStatefulWidget {
  final String email;

  /// Present only when the server has no SMTP configured. It is shown on
  /// screen so the flow can be tested without an inbox; a configured
  /// server never sends it, so the panel disappears on its own.
  final String? devCode;

  const VerifyCodeScreen({required this.email, this.devCode, super.key});

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _codeController = TextEditingController();

  bool _busy = false;
  int _secondsLeft = _resendCooldownSeconds;
  Timer? _ticker;
  String? _devCode;

  @override
  void initState() {
    super.initState();
    _devCode = widget.devCode;
    _startCooldown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _ticker?.cancel();
    setState(() => _secondsLeft = _resendCooldownSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text;

    if (code.length != 6) {
      _showError('Enter all 6 digits');
      return;
    }

    setState(() => _busy = true);

    try {
      final token = await ref
          .read(passwordResetRepositoryProvider)
          .verifyCode(email: widget.email, code: code);

      if (!mounted) return;

      final done = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => NewPasswordScreen(resetToken: token)),
      );

      if (done == true && mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      // The server counts down the remaining attempts in its message, so
      // showing it verbatim is more useful than anything generic.
      _showError(e.message);
      _codeController.clear();
      setState(() {});
    } catch (_) {
      _showError('Could not reach the server. Check your connection.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      final devCode = await ref
          .read(passwordResetRepositoryProvider)
          .requestCode(widget.email);

      if (!mounted) return;

      // A new code invalidates the old one server-side, so clearing the
      // boxes stops someone finishing the digits they had half-typed.
      _codeController.clear();
      setState(() => _devCode = devCode);
      _startCooldown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new code is on its way.'),
          backgroundColor: AuthPalette.success,
        ),
      );
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
    final canResend = _secondsLeft <= 0 && !_busy;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AuthPage(
        heroTitle: 'Check your email',
        heroSubtitle: 'We sent a 6-digit code to\nthe address on your account.',
        onBack: _busy ? null : () => Navigator.pop(context),
        card: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthCardHeading(
                title: 'Enter the code',
                subtitle: 'If that address is registered, a 6-digit code is '
                    'on its way to it.',
              ),
              const SizedBox(height: 16),

              AuthNotice(
                icon: Icons.mark_email_read_outlined,
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    color: AuthPalette.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (_devCode != null) ...[
                const SizedBox(height: 10),
                AuthNotice(
                  icon: Icons.construction_rounded,
                  background: const Color(0xFFFFF7E3),
                  border: const Color(0xFFF2D79B),
                  iconColor: const Color(0xFFB45309),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEVELOPMENT ONLY',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No email was sent. Your code is $_devCode',
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),
              _CodeField(
                controller: _codeController,
                enabled: !_busy,
                onChanged: (_) => setState(() {}),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: 22),

              AuthPrimaryButton(
                label: 'Verify Code',
                busy: _busy,
                onTap: _codeController.text.length == 6 ? _verify : null,
              ),
              const SizedBox(height: 18),

              Center(
                child: canResend
                    ? GestureDetector(
                  onTap: _resend,
                  child: const Text(
                    "Haven't got the email? Resend",
                    style: TextStyle(
                      color: AuthPalette.link,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    : Text(
                  'You can ask for a new code in ${_secondsLeft}s',
                  style: const TextStyle(
                    color: AuthPalette.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Center(
                child: Text(
                  'The code expires in 15 minutes.',
                  style: TextStyle(color: AuthPalette.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Six boxes that are really one text field.
///
/// The obvious build — six separate TextFields wired together with
/// FocusNodes — breaks in all the ways people actually use these: pasting
/// a code from the email fills only the first box, backspace on an empty
/// box goes nowhere, and the keyboard's autofill suggestion can't land.
/// One hidden field holding all six digits, with the boxes drawn from its
/// value, gets paste, backspace and selection for free.
class _CodeField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const _CodeField({
    required this.controller,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<_CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<_CodeField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digits = widget.controller.text;

    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          Row(
            children: List.generate(6, (index) {
              final filled = index < digits.length;
              // The box waiting for the next digit gets the blue ring, so
              // there is still a visible caret equivalent.
              final active = _focus.hasFocus && index == digits.length;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AuthPalette.fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active
                            ? AuthPalette.blue
                            : filled
                            ? AuthPalette.navy.withOpacity(0.25)
                            : Colors.transparent,
                        width: active ? 1.8 : 1,
                      ),
                    ),
                    child: Text(
                      filled ? digits[index] : '',
                      style: const TextStyle(
                        color: AuthPalette.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Invisible, on top, filling the row — so a tap anywhere on the
          // boxes opens the keyboard.
          Positioned.fill(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {});
                widget.onChanged?.call(value);
                if (value.length == 6) {
                  FocusScope.of(context).unfocus();
                  widget.onCompleted?.call(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}