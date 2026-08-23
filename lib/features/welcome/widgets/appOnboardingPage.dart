import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/welcome/widgets/ButtonShadow_widget.dart';
import 'package:jtrips_app/features/welcome/widgets/text_widgets.dart';

Widget appOnboardingPage(
    PageController controller,
    {String imagePath = "assets/welcome/Location.png",
  String title="",
  String subtext = "",index=0}){
  return   Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset(imagePath,fit: BoxFit.fitWidth,),
      Container(
        width: double.infinity,
          margin: EdgeInsets.only(top: 15, left: 30, right: 30),
          child: textHeader( text:title,)

      ),
      Container(
        margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.only(left: 30,right: 30),
        child: subtitle(text: subtext),
      ),
      _nextButton(index,controller)
    ],
  );
}


Widget _nextButton(int index,PageController controller) {
  return GestureDetector(
    onTap: (){
      if(index < 4) {
        controller.animateToPage(index, duration: Duration(milliseconds: 300),
            curve: Curves.linear);
      }
    },
    child: Container(
      width: 325,
      height: 50,
      margin:  const EdgeInsets.only(top:50,left: 50),
      decoration: appBoxShadow(),
      child: Center(child: Text("next",style: TextStyle(color: AppColors.textPrimary,fontSize: 24,fontWeight: FontWeight.w600),),),
    ),
  );
}
