import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_TripTicketFlowScreen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_home_screen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_profile_screen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_schedule_screen.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/instructor_vehicle_screen.dart';



class BottonNavBar extends StatefulWidget {
  const BottonNavBar({super.key});

  @override
  State<BottonNavBar> createState() => _BottonNavBarState();
}

class _BottonNavBarState extends State<BottonNavBar> {
  final appScreens = [
    const HomeScreen(),
    const VehicleScreen(),
    const TripTicketFlowScreen(),
    const ScheduleScreen(),
    const ProfileScreen()
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: appScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.menuBackground,
        selectedItemColor: AppColors.statusBlue,
        unselectedItemColor: AppColors. navInactive,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // keeps all 5 labels visible
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Vehicles",),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle,color: AppColors.accentYellow,size: 45,), label: "",),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule",),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
