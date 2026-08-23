
import 'package:flutter/cupertino.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

Widget textHeader({ String text =""}){
  return Text(
    text,
    textAlign: TextAlign.start,
      style: TextStyle(color: AppColors.accentYellow,
          fontWeight: FontWeight.bold,
          fontSize: 32)
  );
}

Widget subtitle({ String text =""}){
  return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16)
  );
}