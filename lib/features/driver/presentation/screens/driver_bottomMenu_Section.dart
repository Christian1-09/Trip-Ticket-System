// features/driver/presentation/screens/driver_bottomMenu_Section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:jtrips_app/features/driver/presentation/screens/DriverVehicleScreen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_history_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_profile_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_schedule_screen.dart';
import 'package:jtrips_app/features/head_driver/presentation/providers/head_driver_providers.dart';

import '../../../head_driver/presentation/screen/head_driver_approvals_screen.dart';

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _inactive = Color(0xFF9AA3B5);
const _yellow = Color(0xFFFFC928);

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
      isHeadDriver
          ? const HeadDriverApprovalsScreen()
          : const DriverVehicleScreen(),
      const DriverScheduleScreen(),
      const DriverHistoryScreen(),
      const DriverProfileScreen(),
    ];

    // Only watched for the Head Driver, so a normal driver never calls the
    // head-driver endpoints (they would answer 403).
    final waiting = isHeadDriver ? ref.watch(hdWaitingCountProvider) : 0;

    final items = <_NavItem>[
      const _NavItem(Icons.home_rounded, 'Home'),
      isHeadDriver
          ? _NavItem(Icons.fact_check_rounded, 'Approvals', badge: waiting)
          : const _NavItem(Icons.airport_shuttle_rounded, 'Vehicle'),
      const _NavItem(Icons.calendar_month_rounded, 'Schedule'),
      const _NavItem(Icons.history_rounded, 'History'),
      const _NavItem(Icons.person_rounded, 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == _selectedIndex,
                      onTap: () => setState(() => _selectedIndex = i),
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

class _NavItem {
  final IconData icon;
  final String label;
  final int badge;
  const _NavItem(this.icon, this.label, {this.badge = 0});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _blue : _inactive;

    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? _blue.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Badge(
              isLabelVisible: item.badge > 0,
              backgroundColor: _yellow,
              textColor: _navy,
              label: Text('${item.badge}'),
              child: Icon(item.icon, color: color, size: 23),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}