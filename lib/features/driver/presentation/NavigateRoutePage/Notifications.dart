import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/messages.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/viewMessage.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:AppBar(
      iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.background,
        title: Text("notification",style:TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
            fontSize: 18
        ),
        ),
      ),
      body: SafeArea(
          child:SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                // Regular notification
                Messages(
                  headerText: 'Admin',
                  imagePath: AppMedia.driver1,
                  date: 'Yesterday',
                  bodyText: 'Good news! The trip ticket request has been approved by the admin..',
                  onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const ViewMessage(), ));
                    },
                ),
                Messages(
                  headerText: 'Admin',
                  imagePath: AppMedia.driver2,
                  date: 'Yesterday',
                  bodyText: 'Good news! The trip ticket request has been approved by the admin..',
                ),

// Trip Completed variant with review row
                Messages(
                  headerText: 'Trip Completed',
                  imagePath: AppMedia.driver1,
                  date: 'March 12,2026',
                  isUnread: true,
                  bodyText: 'Welcome back! The trip ticket request has been approved by the admin..',
                  showReview: true,
                  onWriteReviewTap: () {},
                )
              ],
            )

          ) ),
    );
  }
}
