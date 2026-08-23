import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

BoxDecoration appBoxShadow( {Color color = AppColors.accentYellow,double radius =15,double sR=1,double bR=2})
{
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.accentYellow.withOpacity(0.6),
        spreadRadius: sR,
        blurRadius: bR,
        offset: Offset(0, 1)
      )
    ]
  );
}