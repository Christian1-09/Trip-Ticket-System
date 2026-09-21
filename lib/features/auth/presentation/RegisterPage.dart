import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';

import 'LoginPage.dart';
import 'RegisterScreen.dart';
import 'data/user_role_mapping.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.redAccent),
        );
      } else if (next is AuthRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });

    final isLoading = ref.watch(authControllerProvider) is AuthLoading;

    return Stack(
      children: [
        RegisterScreen(
          onRegister: ({
            required String fullName,
            required String email,
            required String phone,
            required UserRole role,
            required String password,
          }) {
            ref.read(authControllerProvider.notifier).register(
              fullName: fullName,
              email: email,
              phone: phone,
              role: role.backendValue,
              password: password,
            );
          },
          onLoginTap: () {
            // Also navigates to LoginPage directly (not pop) — Register
            // may be the app's very first screen with nothing to pop back to.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        if (isLoading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
