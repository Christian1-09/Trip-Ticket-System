import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';


enum VehicleStatus { available, onTrip }

/// Card shown in the horizontal "Recommended Vehicles" list.
/// Uses an icon placeholder in place of a real vehicle photo.
class VehicleCard extends StatelessWidget {
  final String plateNumber;
  final String type;
  final VehicleStatus status;
  final IconData icon;
  final String? imagePath;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.plateNumber,
    required this.type,
    required this.status,
    this.icon = Icons.local_shipping_rounded,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = status == VehicleStatus.available;
    final Color statusColor =
    isAvailable ? AppColors.statusGreen : AppColors.statusBlue;
    final String statusLabel = isAvailable ? 'Available' : 'On Trip';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          border: Border.all(color: AppColors.statusBlue.withOpacity(0.75)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.statusBlue.withOpacity(0.75),
            blurRadius: 3,
              offset: const Offset(0,0 )
            )
          ]
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(

                height: 70,
                width: double.infinity,
                color: AppColors.cardDark.withOpacity(0.5),
                child: imagePath != null
                    ? Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                )
                    : Icon(icon, color: AppColors.textSecondary, size: 36),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              plateNumber,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              type,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              color: AppColors.statusBlue.withOpacity(0.3),
              child:    Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),


                ],
              ),
              
            )
         
          ],
        ),
      ),
    );
  }
}