import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';
import 'package:jtrips_app/features/profile/instructor_profile_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  final String name;
  final String email;

  const DriverProfileScreen({
    this.name = "Christian T Gonzaga",
    this.email = "@christian.gonzaga.23473"
});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.statusBlue,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.statusBlue.withOpacity(0.70),
                                blurRadius: 12,
                                offset: const Offset(0, 2)
                            )
                          ]
                      ),
                      child:  CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(AppMedia.driver1),
                      ),
                    ),
                    Text(name, style: const  TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),),
                    Text(email,style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500

                    ),),
                    const SizedBox(height: 24,),
                  ],
                )
              ],
            ),
            Expanded(child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Accounts", style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700
                      ),),
                      const SizedBox(height: 5,),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(10,0, 10, 20),
                            child: Column(
                              children: [
                                AccountMenu(
                                  label: "Dark mode",
                                  icon: Icons.shield_moon,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                                AccountMenu(
                                  label: "Notification",
                                  icon: Icons.notifications_outlined,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                                AccountMenu(
                                  label: "Data and Privacy",
                                  icon: Icons.home_outlined,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                              ],
                            ),


                          )
                        ],
                      ),
                      const SizedBox(height: 8,),
                      Text("Safety",style: const  TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700
                      ),),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(10,0, 10, 20),
                            child: Column(
                              children: [
                                AccountMenu(
                                  label: "Report technical problem",
                                  icon: Icons.warning_amber_outlined,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                                AccountMenu(
                                  label: "Help & support",
                                  icon: Icons.support_agent_outlined,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                                AccountMenu(
                                  label: "Legal & policies",
                                  icon: Icons.policy_outlined,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                                AccountMenu(
                                  label: "Log out",
                                  icon: Icons.logout_outlined,
                                  onTap: () {
                                    // navigate to profile
                                  },
                                ),
                              ],
                            ),


                          )
                        ],
                      ),




                    ],


                  ),

                )

              ],
            ))

          ],
        ),
      ),
    );
  }
}



class AccountMenu extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const AccountMenu({
    required this.label,
    this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,size: 20,color: AppColors.textPrimary,),
              ),
              const SizedBox(width: 10,),

              Expanded(child: Text(label,style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),),),
              const Icon(  Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,)
            ],
          ),)
    );
  }
}
