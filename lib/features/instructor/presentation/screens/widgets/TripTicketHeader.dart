// features/trip_ticket/presentation/widgets/trip_ticket_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../../providers/trip_ticket_provider.dart';
import '../steps/step_indicator.dart';

class TripTicketHeader extends ConsumerWidget {
  const TripTicketHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripTicketProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (state.currentStep == 0) {
                    Navigator.of(context).pop();
                  } else {
                    ref.read(tripTicketProvider.notifier).previousStep();
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'New Request',
            style: TextStyle(
              color: AppColors.statusGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Trip Ticket!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'NO. ',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentYellow.withOpacity(0.6)),
                ),
                child: Text(
                  state.ticketNumber,
                  style: const TextStyle(
                    color: AppColors.accentYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StepIndicator(
            steps: const [
              StepInfo('UPLOAD'),
              StepInfo('DETAILS'),
              StepInfo('Driver'),
              StepInfo('Complete'),
            ],
            currentIndex: state.currentStep,
          ),
        ],
      ),
    );
  }
}
