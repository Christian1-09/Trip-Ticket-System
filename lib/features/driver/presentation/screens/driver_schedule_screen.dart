import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/HeaderText_Schedule.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/search_bar_widget.dart';

class DriverScheduleScreen extends StatefulWidget {

  const DriverScheduleScreen({
    super.key,

  });

  @override
  State<DriverScheduleScreen> createState() => _DriverScheduleScreenState();
}

class _DriverScheduleScreenState extends State<DriverScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
          child: ListView(
            children: [
              const SizedBox(height: 14,),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 54),
                child:
                    Column(
                      children: [
                        SearchBarWidget(onFilterTap: () {},),
                        const SizedBox(height: 14,),
                        HeaderTextSchedule(totalDriver: 3,),

                        const SizedBox(height: 24,),
                        ScheduleCard(
                            name: "Steve P. Baroro",
                            plateNumber: "SJJ 963",
                            vehicleType: "CANTER",
                            imagePath: AppMedia.driver1,
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
                            vehicleType: "CANTER",
                            imagePath: AppMedia.driver3,
                            status: TripStatus.pending),
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
                            imagePath: AppMedia.driver3,
                            status: TripStatus.pending),
                      ],
                    ),


              ),

            ],
          )),
    );
  }
}
