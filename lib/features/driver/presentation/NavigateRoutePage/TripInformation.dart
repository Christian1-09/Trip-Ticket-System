import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/DriverSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/RouteSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/TimeStatusSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/TimelineSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/TripInfoSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/VehicleSection.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/passenger.dart';

class TripInformation extends StatelessWidget {
  const TripInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.background,
        title: Text("Information",
          style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w900
        ),),
      ),
      body:SafeArea(
          child:SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                DriverSection(),
                SizedBox(height: 14,),
                TimeStatsSection(),
                SizedBox(height: 14,),
                TripInfoSection(),
                SizedBox(height: 14,),
                RouteSection(),
                SizedBox(height: 14,),
                VehicleSection(),
                SizedBox(height: 14,),
                PassengersSection(),
                SizedBox(height:14 ,),
                TimelineSection()


              ],
            ),
          )

      )
    );

  }
}
