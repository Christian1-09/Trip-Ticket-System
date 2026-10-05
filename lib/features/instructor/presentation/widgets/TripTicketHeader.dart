// features/instructor/presentation/widgets/trip_ticket_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// TODO: adjust this import to wherever your AppMedia class lives.

import '../../../../core/theme/media.dart';
import '../screens/steps/step_indicator.dart';

/// Steps shown in the Trip Ticket flow (Driver step removed).
const tripTicketSteps = [
  StepInfo('Upload'),
  StepInfo('Details'),
  StepInfo('Complete'),
];

/// Full-page layout: blue photo header on top, white rounded sheet
/// ([child]) overlapping its bottom edge.
///
/// Usage in your trip ticket screen:
/// ```dart
/// TripTicketLayout(
///   ticketNo: 'TKT-2026-001',
///   currentStep: state.currentStep,
///   onBack: () => Navigator.pop(context),
///   child: const UploadStep(),
/// )
/// ```
class TripTicketLayout extends StatelessWidget {
  final String ticketNo;
  final int currentStep;
  final VoidCallback? onBack;
  final Widget child;
  final List<StepInfo> steps;

  const TripTicketLayout({
    super.key,
    required this.ticketNo,
    required this.currentStep,
    required this.child,
    this.onBack,
    this.steps = tripTicketSteps,
  });

  static const _overlap = 24.0;

  @override
  Widget build(BuildContext context) {
    final headerHeight = TripTicketHeader.heightFor(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TripTicketHeader(
                ticketNo: ticketNo,
                currentStep: currentStep,
                onBack: onBack,
                steps: steps,
              ),
            ),
            Positioned(
              top: headerHeight - _overlap,
              left: 0,
              right: 0,
              bottom: 0,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class TripTicketHeader extends StatelessWidget {
  final String ticketNo;
  final int currentStep;
  final VoidCallback? onBack;
  final List<StepInfo> steps;

  const TripTicketHeader({
    super.key,
    required this.ticketNo,
    required this.currentStep,
    this.onBack,
    this.steps = tripTicketSteps,
  });

  static const _yellow = Color(0xFFFFC629);
  static const _contentHeight = 290.0;

  static double heightFor(BuildContext context) =>
      MediaQuery.of(context).padding.top + _contentHeight;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: heightFor(context),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppMedia.scheduleHeaderImage,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF0B5ED7).withOpacity(0.95),
                  const Color(0xFF1E88E5).withOpacity(0.70),
                  const Color(0xFF1E88E5).withOpacity(0.10),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Darker band behind the step indicator for legibility.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0B5ED7).withOpacity(0.55),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 24 + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BackButton(onTap: onBack ?? () => Navigator.maybePop(context)),
                    const Spacer(),
                    const _MiniLogo(),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'New Request',
                  style: TextStyle(
                    color: _yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Trip Ticket!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'NO.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1E5B).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _yellow, width: 1.5),
                      ),
                      child: Text(
                        ticketNo,
                        style: const TextStyle(
                          color: _yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                StepIndicator(steps: steps, currentIndex: currentStep),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.22),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _MiniLogo extends StatelessWidget {
  const _MiniLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'JTRIPS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
        Transform.rotate(
          angle: -0.5,
          child: const Icon(Icons.send_rounded,
              color: TripTicketHeader._yellow, size: 20),
        ),
      ],
    );
  }
}