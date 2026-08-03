import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/All_Trip_Request.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/Notifications.dart';
import 'package:jtrips_app/features/driver/presentation/NavigateRoutePage/TripInformation.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/DriverHeaderSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/driver_stats.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/_DriverHeader.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/search_bar_widget.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/stat_card.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Column(
            children: [
              // ── FIXED: Bottom Menu ────────────────────────────────────────────
              // DriverHeader(title: "Assigned Trips",totalDriver: 4,label: "View all",onTap: () {
              //   Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AllTripRequest(), ));
              // },),
              DriverHeaderSection(
                userName: "Steve P. Bareno",
                driverId: "DRV-2024-012",
                onNotificationTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Notifications(),));
                },

              ),
              // ── FIXED: Search Bar ────────────────────────────────────────────
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchBarWidget(onFilterTap: () {}),
                ),
              ),
              // ── SCROLLABLE: Everything below ─────────────────────────────
              Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      //Driver stats
                      const StatsRow(items: [
                        StatItem(label: "NEW TRIPS", value: "12", accentColor: AppColors.statusBlue),
                        StatItem(label: "NEW TRIPS", value: "6", valueColor: AppColors.accentYellow,accentColor: AppColors.accentYellow),
                        StatItem(label: "NEW TRIPS", value: "120", accentColor: AppColors.statusGreen, valueColor: AppColors.statusGreen),
                      ],),

                      const SizedBox(height: 24,),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        DashboardActionCard(
                          icon: Icons.send_rounded,
                          iconBackgroundColor: AppColors.accentYellow.withOpacity(0.2),
                          iconColor: AppColors.accentYellow,
                          title: "New Bookings",
                          subtitle: "2 awaiting you",
                          onTap: () {},
                        ),
                        DashboardActionCard(
                          icon: Icons.calendar_today_rounded,
                          iconBackgroundColor: AppColors.statusBlue.withOpacity(0.2),
                          iconColor: AppColors.statusBlue,
                          title: "New Bookings",
                          subtitle: "3 trip today",
                          onTap: () {},
                        ),
                        DashboardActionCard(
                          icon: Icons.location_on_rounded,
                          iconBackgroundColor: AppColors.statusBlue.withOpacity(0.2),
                          iconColor: AppColors.statusBlue,
                          title: "Navigation",
                          subtitle: "Open map",
                          onTap: () {},
                        ),
                        DashboardActionCard(
                          icon: Icons.bar_chart_rounded,
                          iconBackgroundColor: AppColors.accentYellow.withOpacity(0.2),
                          iconColor: AppColors.accentYellow,
                          title: "My Performance",
                          subtitle: "4.8 Rating",
                          onTap: () {},
                        ),
                      ],

                    ),
                      const SizedBox(height: 24,),
                      DriverHeader(title: "Assigned Trips",totalDriver: 4,label: "View all",onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AllTripRequest(), ));
                      },),
                      const SizedBox(height: 14,),
                      ScheduleCard(
                          name: "Steve P. 1Baroro",
                          plateNumber: "SJJ 963",
                          vehicleType: "CANTER",
                          imagePath: AppMedia.driver3,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const TripInformation()));
                          },
                          status: TripStatus.pending),
                      ScheduleCard(
                          name: "Steve P. Baroro",
                          plateNumber: "SJJ 963",
                          vehicleType: "CANTER",
                          imagePath: AppMedia.driver4,
                          status: TripStatus.pending),
                      ScheduleCard(
                          name: "Steve P. Baroro",
                          plateNumber: "SJJ 963",
                          vehicleType: "CANTER",
                          imagePath: AppMedia.driver2,
                          status: TripStatus.confirmed),
                      ScheduleCard(
                          name: "Steve P. Baroro",
                          plateNumber: "SJJ 963",
                          imagePath: AppMedia.driver1,
                          vehicleType: "CANTER",
                          status: TripStatus.confirmed),
                    ],
              ),
              )
            ],
          )),
    );
  }
}
