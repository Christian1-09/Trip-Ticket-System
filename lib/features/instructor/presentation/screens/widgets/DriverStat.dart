import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/schedule.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

enum TripStatus {active,onTrip}
class DriverStat extends StatelessWidget {
  final String label;
  final String name;
  final String? imagePath;
  final TripStatus status;
  final String totalTrips;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;


  const DriverStat({
    required this.label,
    required this.name,
    this.imagePath,
    required this.status,
    required this.totalTrips,
    this.onTap,
    this.onMoreTap
});

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == TripStatus.active;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          border: Border.all(color: AppColors.statusBlue.withOpacity(0.75)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: AppColors.statusBlue.withOpacity(0.35),
            blurRadius: 12,
            offset:  const Offset(0, 2))
          ]
        ),
        child: Row(
          children: [
            //  ───────────Avatar─────────────────────────────────────
            _Avatar(imagePath: imagePath),
            const SizedBox(width: 12),
            //  ───────────Driver Name ─────────────────────────────────────
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label , style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5
                        ),)
                      ],
                    ),
              const SizedBox(height: 1),
                    //Name
                    Text(name, style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,),

                    const SizedBox(height: 3),

                    Row(
                      children: [
                        const Icon(
                          Icons.card_travel_rounded,
                          color: AppColors.textSecondary,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text('$totalTrips', style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,

                        ),
                          overflow: TextOverflow.ellipsis,)
                      ],
                    )
                  ],
                ) ,
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(isActive: isActive),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: onMoreTap,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: AppColors.statusBlue.withOpacity(0.2),
                          shape: BoxShape.rectangle,
                          border: BoxBorder.all(color: AppColors.statusBlue.withOpacity(0.35)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.statusBlue,
                        size: 20,),
                      ),
                    )
                  ],

                )
              ],
            )
          ],
        ),
      ),
    );
  }
}












class _Avatar extends StatelessWidget {
  final String? imagePath;

  const _Avatar({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
        height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardDark,
        border:Border.all(color: Colors.white12,width: 1.5),
        image: imagePath != null ? DecorationImage(image: AssetImage(imagePath!),
        fit: BoxFit.cover,) : null,
      ),
      child: imagePath == null ? const Icon(Icons.person_rounded,color: Colors.white38, size: 28,) : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.statusBlue.withOpacity(0.20)
            :AppColors.accentYellow.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(color: AppColors.statusBlue.withOpacity(0.35)),

      ),
      child: Text(
        isActive ? 'AVAILABLE' : 'ON TRIP',
        style: TextStyle(
         color: isActive ? AppColors.statusBlue : AppColors.accentYellow,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}


