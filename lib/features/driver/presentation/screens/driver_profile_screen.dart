import 'package:flutter/material.dart';
import 'package:jtrips_app/features/profile/profile_screen.dart';

/// The driver's profile is the SAME screen as the requester's.
///
/// No hardcoded name, no hardcoded email, no AssetImage — it now reads the
/// logged-in user from profileControllerProvider like every other role,
/// and logging out works here for free.
///
/// When you want a driver-only group (driver code, rating, "My vehicle"),
/// pass it through `extraSections` — see the commented example below. That
/// is the whole point of sharing the screen: the driver adds rows instead
/// of copying 200 lines.
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(
      // extraSections: [
      //   ProfileMenuSection(
      //     title: 'Driving',
      //     items: [
      //       AccountMenu(label: 'My vehicle', icon: Icons.directions_car_outlined),
      //       AccountMenu(label: 'My rating',  icon: Icons.star_outline),
      //     ],
      //   ),
      // ],
    );
  }
}