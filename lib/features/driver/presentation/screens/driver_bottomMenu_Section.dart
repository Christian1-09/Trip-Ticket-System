// features/driver/presentation/screens/driver_bottomMenu_Section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:jtrips_app/features/driver/presentation/screens/DriverVehicleScreen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_history_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_profile_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_schedule_screen.dart';
import 'package:jtrips_app/features/head_driver/presentation/providers/head_driver_providers.dart';


import '../../../head_driver/presentation/screen/head_driver_approvals_screen.dart';

/// Shared by Driver and Head Driver. The only difference: the Head Driver's
/// second tab is "Approvals" instead of "Vehicle".
class BottomMenuSection extends ConsumerStatefulWidget {
  const BottomMenuSection({super.key});

  @override
  ConsumerState<BottomMenuSection> createState() => _BottomMenuSectionState();
}

class _BottomMenuSectionState extends ConsumerState<BottomMenuSection> {
  int _selectedIndex = 0;

  bool _isHeadDriver(AuthState state) =>
      state is AuthAuthenticated && state.user.role == AppRole.headDriver;

  @override
  Widget build(BuildContext context) {
    final isHeadDriver = _isHeadDriver(ref.watch(authControllerProvider));

    final screens = <Widget>[
      const DriverHomeScreen(),
      isHeadDriver ? const HeadDriverApprovalsScreen() : const DriverVehicleScreen(),
      const DriverScheduleScreen(),
      const DriverHistoryScreen(),
      const DriverProfileScreen(),
    ];

    // Only watched for the Head Driver, so a normal driver never calls the
    // head-driver endpoints (they would answer 403).
    final waiting = isHeadDriver ? ref.watch(hdWaitingCountProvider) : 0;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.menuBackground,
        selectedItemColor: AppColors.statusBlue,
        unselectedItemColor: AppColors.navInactive,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          isHeadDriver
              ? BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: waiting > 0,
              label: Text('$waiting'),
              child: const Icon(Icons.fact_check_rounded),
            ),
            label: 'Approvals',
          )
              : const BottomNavigationBarItem(
              icon: Icon(Icons.card_travel), label: 'Vehicle'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.schedule_rounded), label: 'Schedule'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.history_edu_rounded), label: 'History'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}