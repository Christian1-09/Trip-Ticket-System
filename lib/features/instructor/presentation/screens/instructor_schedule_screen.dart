import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/HeaderSection.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.background,
      body:  SafeArea(
        child: Column(
          children: [
            // ── FIXED: Header ────────────────────────────────────────────
            HeaderSection(userName: "Rianesil",
              onNotificationTap: () {},
              onUrgentTravelTap: () {},
            ),
            const SizedBox(height: 14,),

            Expanded(child:
            ListView(
              padding:  const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                _SectionHeader(time:"September 20,2026",label: "View all",),

                const SizedBox(height: 14),
                ScheduleCard(
                  name: 'Steve P. Bareno',
                  plateNumber: "SJJ 963",
                  vehicleType: "Innova",
                  status: TripStatus.confirmed,
                  imagePath: AppMedia.driver1,),
                ScheduleCard(
                  name: 'Steve P. Bareno',
                  plateNumber: "SJJ 963",
                  vehicleType: "Innova",
                  status: TripStatus.pending,
                  imagePath: AppMedia.driver2,),
                ScheduleCard(
                  name: 'Steve P. Bareno',
                  plateNumber: "SJJ 963",
                  vehicleType: "Innova",
                  status: TripStatus.confirmed,
                  imagePath: AppMedia.driver3,),
                ScheduleCard(
                  name: 'Steve P. Bareno',
                  plateNumber: "SJJ 963",
                  vehicleType: "Innova",
                  status: TripStatus.pending,
                  imagePath: AppMedia.driver4,),
                ScheduleCard(
                  name: 'Steve P. Bareno',
                  plateNumber: "SJJ 963",
                  vehicleType: "Innova",
                  status: TripStatus.pending,
                  imagePath: AppMedia.driver1,),
              ],
            ))

          ],


        ),
      ),

    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String time;
  final String label;
  final VoidCallback? onTap;

  const _SectionHeader({
    this.time = "September 20,2026",
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          time,
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