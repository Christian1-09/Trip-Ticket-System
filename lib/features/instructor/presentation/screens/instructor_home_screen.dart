import 'package:flutter/material.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/HeaderSection.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/quick_action_tile.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/search_bar_widget.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/stat_card.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/vehicle_card.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(                         // ← Column, not Stack
          children: [

            // ── FIXED: Header ────────────────────────────────────────────
            HeaderSection(
              userName: 'Rianesil',
              onNotificationTap: () {},
              onUrgentTravelTap: () {},
            ),

            // ── FIXED: Search bar overlapping header bottom ───────────────
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(onFilterTap: () {}),
              ),
            ),

            // ── SCROLLABLE: Everything below ─────────────────────────────
            Expanded(                          // ← takes all remaining height
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [

                  // Stats
                  const StatsRow(items: [
                    StatItem(label: 'Total Trips', value: '12',accentColor: AppColors.statusBlue),
                    StatItem(label: 'Pending', value: '3', valueColor: AppColors.accentYellow,accentColor:AppColors.accentYellow ),
                    StatItem(label: 'On Trip', value: '1', valueColor: AppColors.statusGreen,accentColor: AppColors.statusBlue),
                  ]),

                  const SizedBox(height: 24),

                  // Quick Actions
                  QuickActions(actions: [
                    QuickAction(label: 'Book Trip', icon: Icons.add_circle_outline_rounded, valueColor: AppColors.statusBlue),
                    QuickAction(label: 'Drivers', icon: Icons.people_alt_outlined, valueColor: AppColors.accentYellow),
                    QuickAction(label: 'Schedule', icon: Icons.calendar_today_outlined, valueColor: AppColors.statusBlue),
                  ]),

                  const SizedBox(height: 24),

                  // Recommended Vehicles header
                  _SectionHeader(title: 'Recommended Vehicles', label: 'See all', onTap: () {}),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        const vehicles = [
                          VehicleCard(plateNumber: 'JJS 963', type: 'Innova', status: VehicleStatus.available, imagePath: AppMedia.innova),
                          VehicleCard(plateNumber: 'SEM-832', type: 'Cantor', status: VehicleStatus.onTrip, imagePath: AppMedia.canter),
                          VehicleCard(plateNumber: '100/10', type: 'HI-AC', status: VehicleStatus.available, imagePath: AppMedia.hiAce),
                        ];
                        return vehicles[index];
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Appointments header
                  _SectionHeader(title: 'Appointments', label: 'View all', onTap: () {}),
                  const SizedBox(height: 14),

                  ScheduleCard(
                    name: 'Steve P. Bareno',
                    plateNumber: 'SJJ 963',
                    vehicleType: 'Innova',
                    status: TripStatus.confirmed,
                    imagePath: AppMedia.driver1,
                    date: 'MON SEP 23',
                    time: '1:00 - 3:30PM',

                  ),
                  ScheduleCard(
                    name: 'Renero P. Luma...',
                    plateNumber: 'SEM-832',
                    vehicleType: 'CANTER',
                    status: TripStatus.confirmed,
                    imagePath: AppMedia.driver2,
                    date: 'MON SEP 23',

                    time: '1:00 - 3:30PM',
                  ),
                  ScheduleCard(
                    name: 'John T. Gonzales',
                    plateNumber: '100/10',
                    vehicleType: 'TOYOTA HI-ACE',
                    status: TripStatus.pending,
                    imagePath: AppMedia.driver3,
                    date: 'MON SEP 23',

                    time: '1:00 - 3:30PM',
                    onMoreTap: () {},
                  ),
                  ScheduleCard(
                    name: 'Lover boy G. Mon...',
                    plateNumber: 'SJJ 963',
                    vehicleType: 'Innova',
                    status: TripStatus.pending,
                    imagePath: AppMedia.driver4,
                    date: 'MON SEP 23',

                    time: '1:00 - 3:30PM',
                    onMoreTap: () {},
                  ),

                  const SizedBox(height: 90), // space for bottom nav
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ── Reusable section header ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String label;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(color: AppColors.statusBlue, fontSize: 12)),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.statusBlue, size: 14),
            ],
          ),
        ),
      ],
    );
  }
}