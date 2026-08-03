import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

class VehicleHeader extends StatelessWidget {
  final String plateNumber;
  final String smallText;
  final String available;
  final String driver;
  final String onTrip;
  final String? carImage;
  const VehicleHeader({
    super.key,
    required this.plateNumber,
    required this.smallText,
    required this.available,
    this.carImage = AppMedia.innova,
    required this.driver,
    required this.onTrip
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        height: 240,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0,0.45,1.0],
            colors: [
              Color(0xFF1565C0), // vivid mid-blue (top-left)
              Color(0xFF0D2B8E), // deep royal blue (centre)
              Color(0xFF071166), // darkest navy (bottom-right)
            ]
          )
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Decorative outer ring ──────────────────────────────────────
            Positioned(
              right: -110,
              bottom: -30,
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentYellow.withOpacity(0.25),
                    width: 45,
                  )
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 30,
              top: 50,
              left: 50,
              child: carImage != null
                  ? Image.asset(
                carImage!,
                height: 210,
                fit: BoxFit.fitHeight,

              ) : _CarPlaceholder(height: 120),

            ),

            Positioned(
              top: -10,
              left:-50 ,
              right: -50,
              child: Column(
                children: [
                  const SizedBox(height: 14,),
                  Text(plateNumber,
                    style:TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.8
                    ) ,),
                    const SizedBox(height: 6),
                    Text('$smallText',
                      style: TextStyle(
                        color: AppColors.statusBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),)

                ],


              )
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 5, // makes the pills straddle the bottom edge of the card
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(
                    color: AppColors.statusBlue,
                    label: available,
                    icon: null, // uses a dot instead
                  ),
                  _StatusBadge(
                    color: Colors.white,
                    label: driver,
                    icon: Icons.person,
                  ),
                  _StatusBadge(
                    color: AppColors.accentYellow,
                    label: onTrip,
                    icon: null,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _CarPlaceholder extends StatelessWidget {
  final double height;
  const _CarPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 0.55,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Head
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white54, size: 32),
          ),
          const SizedBox(height: 2),
          // Body silhouette
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}




class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;
  
  const _StatusBadge({
    required this.color,
    required this.label,
    this.icon,
});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDeepBlue,
        border: Border.all(color: AppColors.statusBlue.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.statusBlue.withOpacity(0.40),
            blurRadius: 6,
            offset: const Offset(0, 2)
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == null)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )
          else
            Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),

    );
  }
}


