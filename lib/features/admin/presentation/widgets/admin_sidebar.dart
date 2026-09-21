// presentation/widgets/admin_sidebar.dart
import 'package:flutter/material.dart';

class AdminNavItem {
  final IconData icon;
  final String label;
  const AdminNavItem(this.icon, this.label);
}

const adminNavItems = [
  AdminNavItem(Icons.dashboard_outlined, 'Dashboard'),
  AdminNavItem(Icons.description_outlined, 'Trip Request'),
  AdminNavItem(Icons.directions_car_outlined, 'Vehicle'),
  AdminNavItem(Icons.people_outline, 'Drivers'),
  AdminNavItem(Icons.bar_chart_outlined, 'Analysis'),
  AdminNavItem(Icons.person_add_alt_outlined, 'Request'),
  AdminNavItem(Icons.receipt_long_outlined, 'Trip Ticket log'),
  AdminNavItem(Icons.person_outline, 'Profile'),
];

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AdminSidebar({required this.selectedIndex, required this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFF0D1442),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('JTRIPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('JTIPS MANAGEMENT SYSTEM', style: TextStyle(color: Colors.white54, fontSize: 8)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: adminNavItems.length,
              itemBuilder: (context, index) {
                final item = adminNavItems[index];
                final isSelected = index == selectedIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(item.icon, color: isSelected ? const Color(0xFF0D1442) : Colors.white70, size: 20),
                    title: Text(item.label,
                        style: TextStyle(
                            color: isSelected ? const Color(0xFF0D1442) : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13)),
                    onTap: () => onSelect(index),
                    dense: true,
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 16, color: Colors.white)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cris brown', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Administrator', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: hook to logout logic
                },
                icon: const Icon(Icons.logout, size: 16, color: Color(0xFF0D1442)),
                label: const Text('Logout', style: TextStyle(color: Color(0xFF0D1442), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}