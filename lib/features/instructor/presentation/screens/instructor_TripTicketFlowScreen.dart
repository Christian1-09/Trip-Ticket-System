// features/trip_ticket/presentation/screens/trip_ticket_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/steps/details_step.dart';
import 'package:jtrips_app/features/instructor/presentation/screens/steps/upload_step.dart';
import 'package:jtrips_app/features/instructor/presentation/widgets/TripTicketHeader.dart';

import '../providers/trip_ticket_provider.dart';

class TripTicketFlowScreen extends ConsumerWidget {
  const TripTicketFlowScreen({super.key});

  // Upload, Details, Complete — the Driver step has been removed.
  static const _steps = <Widget>[
    UploadStep(),
    DetailsStep(),
    Center(
      child: Text(
        'Complete step',
        style: TextStyle(color: Color(0xFF0F1B3D)),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripTicketProvider);

    // Guard so a leftover 4-step provider can never point past the last step.
    final stepIndex = state.currentStep.clamp(0, _steps.length - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: TripTicketLayout(
        // TODO: replace with the real ticket number from your state/backend.
        ticketNo: 'TKT-${DateTime.now().year}-001',
        currentStep: stepIndex,
        child: IndexedStack(
          // Changing this key rebuilds all steps from scratch,
          // which is exactly what should happen after a submit.
          key: ValueKey(state.formVersion),
          index: stepIndex,
          children: _steps,
        ),
      ),
    );
  }
}