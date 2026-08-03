import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          bottom: false,
          child: ListView(
            children: [
              const SizedBox( height: 24,),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                child:
                Column(
                  children: [
                    ScheduleCard(
                        name: "Steve P. Baroro",
                        plateNumber: "SJJ 963",
                        vehicleType: "CANTER",
                        imagePath: AppMedia.driver1,
                        status: TripStatus.confirmed),
                    ScheduleCard(
                        name: "Steve P. Baroro",
                        plateNumber: "SJJ 963",
                        vehicleType: "CANTER",
                        imagePath: AppMedia.driver2,
                        status: TripStatus.confirmed),
                    ScheduleCard(
                        name: "Steve P. Baroro",
                        plateNumber: "SJJ 963",
                        vehicleType: "CANTER",
                        imagePath: AppMedia.driver3,
                        status: TripStatus.confirmed),
                    ScheduleCard(
                        name: "Steve P. Baroro",
                        plateNumber: "SJJ 963",
                        vehicleType: "CANTER",
                        imagePath: AppMedia.driver4,
                        status: TripStatus.confirmed),
                    ScheduleCard(
                        name: "Steve P. Baroro",
                        plateNumber: "SJJ 963",
                        vehicleType: "CANTER",
                        imagePath: AppMedia.driver1,
                        status: TripStatus.confirmed),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
