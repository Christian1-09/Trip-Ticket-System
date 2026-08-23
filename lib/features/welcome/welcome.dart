import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/welcome/widgets/appOnboardingPage.dart';
import 'package:jtrips_app/features/welcome/widgets/text_widgets.dart';

// final indexProvider = StateProvider<int>(((ref)=>0));

class Welcome extends StatefulWidget{
 Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController _controller = PageController();
  int dotsIndex=0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            margin: EdgeInsets.only(top: 30),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                PageView(
                  onPageChanged: (value) {
                    setState(() {
                      dotsIndex=value;
                    });
                  } ,
                  controller: _controller,
                  children: [
                    appOnboardingPage(
                        _controller,
                        title:"Where Would You Like to Go",
                        subtext: "Choose your departure and destination city."
                            " Trip Ticket will find the best available routes and vehicles for your journey.", index:1 ),
                    appOnboardingPage(
                        _controller,
                        imagePath:"assets/welcome/Order_ride-pana.png" , title:"Select Your \nPreferred Vehicle",
                        subtext: "We offer a variety of travel options to suit every journey. "
                            "Browse available vehicles, compare schedules,"
                            " and reserve your seat with just a few taps.",index:2  ),
                    appOnboardingPage(
                        _controller,
                        imagePath:"assets/welcome/Time_management-pana.png" , title:"Plan Ahead, \nTravel on Time",
                        subtext: "We offer a variety of travel options to suit every journey. "
                            "Browse available vehicles, compare schedules,"
                            " and reserve your seat with just a few taps.",index:3  ),
                    appOnboardingPage(
                        _controller,
                        imagePath:"assets/welcome/Bus.png" , title:"Know Who's \nDriving Your Trip ",
                        subtext: "Never miss your departure again. Choose your schedule, set your trip time,"
                            " and let Trip Ticket handle the rest — stress-free booking in seconds.",index:4  ),
                  ],

                ),
               Positioned(
                 bottom: 50,
                   child: DotsIndicator(
                     position: dotsIndex.toDouble(),
                     dotsCount: 4,
                   mainAxisAlignment: MainAxisAlignment.center,
                   decorator: DotsDecorator(
                     size: const Size.square(9.0),
                     activeSize: const Size(24.0,8.0,),
                     activeShape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(5)
                     )
                   ),)

               ),


              ],
            ),
          )
        ),
      ),
    );
  }
}
