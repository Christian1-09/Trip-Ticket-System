import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_ui.dart';

/// Unchanged visually. The palette, header, waves, text field and button
/// that used to be private classes in this file now live in auth_ui.dart,
/// so the password-reset screens can use the same ones instead of
/// carrying copies that drift.
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
      child: AuthPage(
        heroTitle: 'Welcome Back!',
        heroSubtitle: 'Login to your account and\ncontinue your journey.',
        card: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return AuthCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthCardHeading(
              title: 'Login to Your Account',
              subtitle: 'Enter your credentials to continue.',
            ),
            const SizedBox(height: 28),

            const AuthFieldLabel('Full Name'),
            AuthTextField(
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

            const AuthFieldLabel('Password'),
            AuthTextField(
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
                          activeColor: AuthPalette.navy,
                          side: const BorderSide(
                              color: AuthPalette.navy, width: 1.6),
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
                          color: AuthPalette.textDark,
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
                      color: AuthPalette.link,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            AuthPrimaryButton(label: 'Login', onTap: _handleLogin),
            const SizedBox(height: 22),

            const AuthOrDivider(),
            const SizedBox(height: 18),

            AuthFooterAction(
              question: "Don't have an account?",
              action: 'Register',
              onTap: widget.onRegisterTap,
            ),
          ],
        ),
      ),
    );
  }
}