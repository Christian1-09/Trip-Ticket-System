// features/admin/presentation/widgets/admin_sidebar.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/admin_colors.dart';

class AdminNavItem {
  final IconData icon;
  final String label;
  const AdminNavItem(this.icon, this.label);
}

/// Order MUST match `_screens` in AdminShell.
/// Order MUST match `_screens` in AdminShell.
const adminNavItems = <AdminNavItem>[
  AdminNavItem(Icons.grid_view_rounded, 'Dashboard'),
  AdminNavItem(Icons.description_outlined, 'Trip Request'),
  AdminNavItem(Icons.directions_car_outlined, 'Vehicle'),
  AdminNavItem(Icons.groups_outlined, 'Drivers'),
  AdminNavItem(Icons.bar_chart_rounded, 'Analysis'),
  AdminNavItem(Icons.person_add_alt_outlined, 'Account request'),
  AdminNavItem(Icons.receipt_long_outlined, 'Trip Ticket log'),
  AdminNavItem(Icons.tune_rounded, 'Setup'),          // Destinations + Departments
  AdminNavItem(Icons.settings_outlined, 'Settings'),
  AdminNavItem(Icons.person_outline, 'Profile'),
];

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String userName;
  final String userRole;
  final VoidCallback? onLogout;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.userName = 'Administrator',
    this.userRole = 'Administrator',
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AdminColors.sidebarTop, AdminColors.sidebarBottom],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Logo ──────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: AdminColors.amber, size: 36),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('JTRIPS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                      Text('TRIP MANAGEMENT SYSTEM',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 7.5,
                              letterSpacing: 0.4)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Nav items ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: adminNavItems.length,
                itemBuilder: (_, i) => _NavTile(
                  item: adminNavItems[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelect(i),
                ),
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.12), height: 1),

            // ── User card ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AdminColors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        Text(userRole,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Logout ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AdminColors.amber,
                    foregroundColor: AdminColors.navy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AdminColors.navy : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AdminColors.amber : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withOpacity(0.06),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(item.icon, color: fg, size: 20),
                const SizedBox(width: 14),
                Text(item.label,
                    style: TextStyle(
                        color: fg,
                        fontSize: 13.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}