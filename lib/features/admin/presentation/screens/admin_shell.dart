// presentation/screens/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/admin/presentation/screens/DriverScreen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/analysis_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/trip_request_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/trip_ticket_log_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/user_driver_request_screen.dart';
import 'package:jtrips_app/features/admin/presentation/screens/vehicle_screen.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import 'admin_dashboard_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  // Add more screens here as you build them (TripRequestScreen, VehicleScreen, etc.)
  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    TripRequestScreen(),
    VehicleScreen(),
    DriverScreen(),
    AnalysisScreen(),
    UserDriverRequestScreen(),
    TripTicketLogScreen(),
    Center(child: Text('Profile', style: TextStyle(color: Colors.white))),
  ];

  final _titles = const ['Dashboard', 'Trip Request', 'Vehicle', 'Drivers', 'Analysis','Request', 'Trip Ticket log', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 900) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F35),
        body: Center(
          child: Text('Admin panel is desktop-only. Please open on a larger screen.',
              style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F35),
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(title: _titles[_selectedIndex]),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}