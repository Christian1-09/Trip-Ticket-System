import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

class DriverHeaderSection extends StatelessWidget {
  final String userName;
  final String? personImagePath;
  final String? carImagePath;
  final String driverId;
  final VoidCallback? onNotificationTap;

  const DriverHeaderSection({super.key,
    required this.userName,
    this.personImagePath = AppMedia.model,
    this.onNotificationTap,
    this.carImagePath = AppMedia.innova,
    required this.driverId
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:  const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32)
      ),
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
            Positioned(
              right: -45,
              bottom: 80,
              child:Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentYellow.withOpacity(0.3),
                    width: 30
                  )
                ),
              ) ,
            ),
            Positioned(
                right: 20,
                bottom: -40,
                child: personImagePath != null
                ? Image.asset(personImagePath!, height: 310,fit: BoxFit.fitHeight,)
                    : _PersonPlaceholder(height: 220),
            ),
            Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                onTap: onNotificationTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.14),
                        ),
                        child: const Icon(Icons.notifications_none_rounded,color: Colors.white,size: 20,),
                      ),
                      Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                          width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentYellow
                            ),
                      ))
                    ],
                  ),
            )),
            Positioned(
                left: 20,
                top: 20,
                right: 150,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5,),
                    const Text("Good Morning",
                    style: TextStyle(
                      color: AppColors.accentYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                    ),
                    const SizedBox(height: 6,),
                    Text(
                      '$userName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1
                      ),
                    ),
                    const SizedBox(height: 4,),
                    Text(
                      'Driver ID:$driverId!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11.5
                      ),
                    ),
                    const SizedBox(height: 2,),
                    SizedBox(
                      width: 100,
                      height: 130,
                      child: Image.asset("$carImagePath",
                        fit: BoxFit.contain,),
                    )


                                      ],
            )

            )



          ],
        ),
      ),



    );
  }
}



class _PersonPlaceholder extends StatelessWidget {
  final double height;

  const _PersonPlaceholder({required this.height});

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