// features/trip_ticket/presentation/screens/trip_ticket_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/steps/details_step.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/steps/upload_step.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/widgets/TripTicketHeader.dart';

import '../providers/trip_ticket_provider.dart';


class TripTicketFlowScreen extends ConsumerWidget {
  const TripTicketFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(tripTicketProvider).currentStep;

    return Scaffold(
      backgroundColor: AppColors.cardDeepBlue,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const TripTicketHeader(),
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: const [
                  UploadStep(),
                  DetailsStep(),
                  Center(child: Text('Driver step', style: TextStyle(color: Colors.white))),
                  Center(child: Text('Complete step', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}