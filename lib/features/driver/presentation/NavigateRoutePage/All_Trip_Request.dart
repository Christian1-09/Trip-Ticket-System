import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';

class AllTripRequest extends StatelessWidget {
  const AllTripRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Trip Request",
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
          fontWeight: FontWeight.w900),

        ),
      ),
      body: SafeArea(child: ListView(
        children: [
          const SizedBox(height: 24,),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
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
                    status: TripStatus.pending),

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
                    imagePath: AppMedia.driver4,
                    status: TripStatus.pending),

                ScheduleCard(
                    name: "Steve P. Baroro",
                    plateNumber: "SJJ 963",
                    vehicleType: "CANTER",
                    imagePath: AppMedia.driver1,
                    status: TripStatus.pending),

              ],
            ),
          )
        ],
      )),
    );
  }
}
