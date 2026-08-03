import 'package:flutter/cupertino.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

class DriverHeader extends StatelessWidget {
  final String title;
  final int totalDriver;
  final String label;
  final VoidCallback? onTap;

  const DriverHeader({
    required this.title,
    required this.label,
    required this.totalDriver,
    this.onTap,
});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 5),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title,style: const TextStyle(color: CupertinoColors.white,
               fontSize: 20,fontWeight: FontWeight.bold,  letterSpacing: 1),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(

                  border:Border.all(color: AppColors.statusBlue),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.statusBlue.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 1)
                    )
                  ]
                ),

                child: Text('$totalDriver',
                style: const TextStyle(
                  color: AppColors.statusBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w700
                ),
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:  AppColors.statusBlue.withOpacity(0.34),
                  width: 1,
                )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color:AppColors.statusBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,

                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    CupertinoIcons.arrow_right,
                    color: AppColors.statusBlue,
                    size: 16,),
                ],
              ),
            ),
          )
        ],
      ),

    );
  }
}
