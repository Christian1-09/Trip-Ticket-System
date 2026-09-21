import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/presentation/screens/admin_shell.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_botton_bar.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';

import '../../driver/presentation/screens/driver_bottomMenu_Section.dart';
import 'LoginScreen.dart';
import 'RegisterPage.dart';
import 'data/app_user.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.redAccent),
        );
      } else if (next is AuthAuthenticated) {
        _navigateToRoleHome(context, next.user);
      }
    });

    final isLoading = ref.watch(authControllerProvider) is AuthLoading;

    return Stack(
      children: [
        LoginScreen(
          onLogin: ({
            required String fullName,
            required String password,
            required bool rememberMe,
          }) {
            // This field accepts either an email or a full name — the
            // backend figures out which and looks up the account.
            ref.read(authControllerProvider.notifier).login(
              identifier: fullName,
              password: password,
            );
          },
          onRegisterTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
          onForgotPasswordTap: () {
            // TODO: wire up once a forgot-password screen/endpoint exists.
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

  void _navigateToRoleHome(BuildContext context, AppUser user) {
    switch (user.role) {
      case AppRole.faculty:
      case AppRole.staff:
      case AppRole.ssgPresident:
      // Faculty/Staff/SSG President all share the same dashboard —
      // the screens under "instructor" (BottonNavBar) ARE that dashboard.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BottonNavBar()),
              (route) => false,
        );
        break;

      case AppRole.driver:
      case AppRole.headDriver:
      // Head Driver temporarily reuses the Driver UI until its own
      // dedicated screens are built.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BottomMenuSection()),
              (route) => false,
        );
        break;

      case AppRole.admin:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminShell()),
              (route) => false,
        );
        break;
    }
  }
}
