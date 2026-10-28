// presentation/screens/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/presentation/screens/DriverScreen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/analysis_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/setup/admin_setup_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/trip_request_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/trip_ticket_log_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/user_driver_request_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/vehicle_screen.dart';
import 'package:jtrips_app/features/auth/presentation/LoginPage.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';

import '../../../../core/theme/admin_colors.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import 'admin_dashboard_screen.dart';

/// StatefulWidget -> ConsumerStatefulWidget so the shell can read the
/// logged-in admin and call logout. `_selectedIndex` stays local State —
/// unlike the requester's nav, nothing outside this widget switches tabs.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;

  // Order must match `adminNavItems` in admin_sidebar.dart.
  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    TripRequestScreen(),
    VehicleScreen(),
    DriverScreen(),
    AnalysisScreen(),
    UserDriverRequestScreen(),
    TripTicketLogScreen(),
    AdminSetupScreen(), // Destinations + Departments
    AdminSettingsScreen(),
    Center(
      child: Text('Profile', style: TextStyle(color: AdminColors.navy)),
    ),
  ];

  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: AdminColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'You will need to sign in again to manage trips, vehicles and drivers.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AdminColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    // Captured before the await — `context` may be gone afterwards.
    final navigator = Navigator.of(context, rootNavigator: true);

    // Clears the stored access + refresh tokens and flips auth state.
    await ref.read(authControllerProvider.notifier).logout();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
        _screens.length == adminNavItems.length,
         'AdminShell._screens (${_screens.length}) and adminNavItems '
          '(${adminNavItems.length}) are out of sync — every sidebar item '
          'needs exactly one screen, in the same order.',
      );
    final width = MediaQuery.sizeOf(context).width;

    if (width < 900) {
      return const Scaffold(
        backgroundColor: AdminColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Admin panel is desktop-only. Please open on a larger screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AdminColors.navy),
            ),
          ),
        ),
      );
    }

    // Real signed-in admin instead of the hardcoded placeholder.
    final authState = ref.watch(authControllerProvider);
    final userName =
    authState is AuthAuthenticated ? authState.user.fullName : 'Admin';

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
            userName: userName,
            // Only an ADMIN ever reaches this shell, so the label is a
            // constant rather than something read off the user.
            userRole: 'Administrator',
            onLogout: _confirmAndLogout,
          ),
          Expanded(
            child: Column(
              children: [
                // Titles come from the sidebar list, so they can't drift out of sync.
                AdminTopBar(title: adminNavItems[_selectedIndex].label),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _screens),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}