import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_TripTicketFlowScreen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_home_screen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_schedule_screen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_vehicle_screen.dart';
import 'package:jtrips_app/features/profile/profile_screen.dart';

import '../providers/requester_tab_provider.dart';

class _NavPalette {
  static const barTop = Color(0xFF173A8A);
  static const barBottom = Color(0xFF0B1E5B);
  static const yellow = Color(0xFFFFC629);
  static const inactive = Color(0xFFC3CEEA);
  static const navy = Color(0xFF0B1E5B);
}

/// The selected tab lives in `requesterTabProvider`, so the Home screen
/// (and anything else) can switch tabs.
class BottonNavBar extends ConsumerWidget {
  const BottonNavBar({super.key});

  static const List<Widget> _appScreens = [
    HomeScreen(),            // RequesterTabs.home     = 0
    VehicleScreen(),         // RequesterTabs.vehicles = 1
    TripTicketFlowScreen(),  // RequesterTabs.book     = 2
    ScheduleScreen(),        // RequesterTabs.schedule = 3
    ProfileScreen(),         // RequesterTabs.profile  = 4
  ];

  /// Height of the navy bar itself (without the phone's bottom inset).
  static const double _barHeight = 70;

  /// How far the yellow + button sticks out above the bar.
  static const double _raise = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(requesterTabProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    void select(int index) =>
        ref.read(requesterTabProvider.notifier).state = index;

    return Scaffold(
      // Lets the raised + button float over the screen content.
      extendBody: true,
      body: Builder(
        builder: (innerContext) => MediaQuery.removePadding(
          context: innerContext,
          removeBottom: true,
          // Screens stop at the top of the navy bar; only the raised
          // button overlaps them.
          child: Padding(
            padding: EdgeInsets.only(bottom: _barHeight + bottomInset),
            child: _appScreens[selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: _barHeight + _raise + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ---------- Navy bar ----------
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _barHeight + bottomInset,
              child: Container(
                padding: EdgeInsets.only(bottom: bottomInset),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_NavPalette.barTop, _NavPalette.barBottom],
                  ),
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      selected: selectedIndex == 0,
                      onTap: () => select(0),
                    ),
                    _NavItem(
                      icon: Icons.directions_car_rounded,
                      label: 'Vehicles',
                      selected: selectedIndex == 1,
                      onTap: () => select(1),
                    ),
                    const Expanded(child: SizedBox()), // space for + button
                    _NavItem(
                      icon: Icons.schedule_rounded,
                      label: 'Schedule',
                      selected: selectedIndex == 3,
                      onTap: () => select(3),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      selected: selectedIndex == 4,
                      onTap: () => select(4),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Raised yellow + button ----------
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _CenterButton(
                  selected: selectedIndex == 2,
                  onTap: () => select(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? _NavPalette.yellow : _NavPalette.inactive;

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightColor: Colors.transparent,
        splashColor: Colors.white.withOpacity(0.12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: _NavPalette.yellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CenterButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _NavPalette.yellow,
          border: Border.all(color: _NavPalette.barTop, width: 5),
          boxShadow: [
            BoxShadow(
              color: _NavPalette.yellow.withOpacity(selected ? 0.7 : 0.45),
              blurRadius: selected ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: _NavPalette.navy, size: 36),
      ),
    );
  }
}