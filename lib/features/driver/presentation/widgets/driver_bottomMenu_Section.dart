import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_history_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_profile_screen.dart';
import 'package:jtrips_app/features/driver/presentation/screens/driver_schedule_screen.dart';

class BottomMenuSection extends StatefulWidget {
  const BottomMenuSection({super.key});

  @override
  State<BottomMenuSection> createState() => _BottomMenuSectionState();
}

class _BottomMenuSectionState extends State<BottomMenuSection> {

  final appScreens = [
    const DriverHomeScreen(),
    const DriverScheduleScreen(),
    const DriverHistoryScreen(),
    const DriverProfileScreen(),
  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.menuBackground,
          selectedItemColor: AppColors.statusBlue,
          unselectedItemColor: AppColors.navInactive,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.schedule_rounded),label: "Schedule"),
            BottomNavigationBarItem(icon: Icon(Icons.history_edu_rounded),label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded),label: "Profile")

          ],
      ),
    );
  }
}
