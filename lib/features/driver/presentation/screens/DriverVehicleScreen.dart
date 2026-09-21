// features/driver/presentation/screens/DriverVehicleScreen.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// Normal drivers' Vehicle tab. It used to show mock approval cards, which
/// belong to the Head Driver (see HeadDriverApprovalsScreen). It will show
/// the vehicle for the driver's accepted trips once the driver workflow
/// (accept / decline / departure / return) is built.
class DriverVehicleScreen extends StatelessWidget {
  const DriverVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car_filled_rounded,
                    size: 56, color: AppColors.statusBlue.withOpacity(0.7)),
                const SizedBox(height: 16),
                const Text(
                  'No vehicle assigned right now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'The vehicle for your next accepted trip will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}