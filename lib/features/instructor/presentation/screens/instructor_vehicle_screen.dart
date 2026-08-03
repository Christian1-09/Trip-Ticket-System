import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/DriverStat.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/_DriverHeader.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/vehicle_header.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── FIXED: Header ────────────────────────────────────────────
            VehicleHeader(
              plateNumber:"SJJ963 INNOVA" ,
              smallText: "DRIVER OVERVIEW",
              available: "1 Available",
              driver: "6 Drivers",
              onTrip: "1 On Trip",
            ),
            Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    // Recommended Drivers header
                    DriverHeader(title: "Drivers",totalDriver: 4,label: "Manage",),

                    const SizedBox(height: 14),
                    DriverStat(
                      label: "Driver",
                      name: "Steve P. Baroro",
                      imagePath: AppMedia.driver1,
                      status: TripStatus.onTrip,
                      totalTrips: "23 total Trip",
                    ),
                    DriverStat(
                      label: "Driver",
                      name: "Richard C. Granton",
                      imagePath: AppMedia.driver2,
                      status: TripStatus.active,
                      totalTrips: "23 total Trip",
                    ),
                    DriverStat(
                      label: "Driver",
                      name: "Lover boy G. Tulabing",
                      imagePath: AppMedia.driver3,
                      status: TripStatus.onTrip,
                      totalTrips: "23 total Trip",
                    ),
                    DriverStat(
                      label: "Driver",
                      name: "Rex Ivan S. Reyes",
                      imagePath: AppMedia.driver4,
                      status: TripStatus.active,
                      totalTrips: "23 total Trip",
                    ),
                  ],
                ))

          ],
        ),
      ),


    );
  }
}
