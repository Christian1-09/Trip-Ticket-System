// features/admin/presentation/screens/setup/admin_setup_screen.dart
import 'package:flutter/material.dart';

import '../../../../../core/theme/admin_colors.dart';
import 'departments_tab.dart';
import 'locations_screen.dart';

/// One home for the admin-managed reference lists the rest of the system
/// reads from.
///
/// Tabs rather than separate sidebar items: these lists are small, rarely
/// touched, and conceptually the same job — "the things requesters pick
/// from". A third list later is one more tab instead of one more sidebar
/// row.
///
/// No page heading here: `AdminShell` already renders one through
/// `AdminTopBar(title: adminNavItems[...].label)`, so a "Setup" title in
/// this widget would print twice.
class AdminSetupScreen extends StatelessWidget {
  const AdminSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AdminColors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AdminColors.border, width: 1),
                ),
              ),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AdminColors.blue,
                indicatorWeight: 2.5,
                labelColor: AdminColors.blue,
                unselectedLabelColor: AdminColors.textMuted,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    height: 48,
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Destinations'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 48,
                    child: Row(
                      children: [
                        Icon(Icons.apartment_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Departments'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // TabBarView keeps both tabs alive once built, so switching back
            // doesn't refetch — these lists change rarely and each tab has
            // its own filter chips worth preserving.
            const Expanded(
              child: TabBarView(
                children: [
                  LocationsTab(),
                  DepartmentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}