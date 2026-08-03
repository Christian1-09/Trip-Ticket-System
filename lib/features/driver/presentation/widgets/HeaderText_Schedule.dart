import 'package:flutter/cupertino.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

class HeaderTextSchedule extends StatelessWidget {
  final int totalDriver;
  const HeaderTextSchedule({super.key, required this.totalDriver});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text("Assigned Trips",style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 20,fontWeight: FontWeight.bold,  letterSpacing: 1
          ),),
          const SizedBox(width: 8,),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.statusBlue),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.statusBlue.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 1)
                  ),

                ]
            ),
            child: Text('$totalDriver',style: const TextStyle(
                color: AppColors.statusBlue,
                fontSize: 14,
                fontWeight: FontWeight.w700
            ),),
          )
        ],
      ),
    );
  }
}
