// core/widgets/step_indicator.dart
import 'package:flutter/material.dart';

class StepInfo {
  final String label;
  const StepInfo(this.label);
}

/// Step indicator styled for the blue Trip Ticket header:
/// active = yellow circle, completed = yellow circle with a check,
/// upcoming = translucent white circle. Labels are white, active is yellow.
class StepIndicator extends StatelessWidget {
  final List<StepInfo> steps;
  final int currentIndex; // 0-based

  const StepIndicator({
    required this.steps,
    required this.currentIndex,
    super.key,
  });

  static const _yellow = Color(0xFFFFC629);
  static const _navy = Color(0xFF0B1E5B);
  static const _circleSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connecting line between circle (i-1)/2 and (i+1)/2,
          // vertically centred on the circles (not on circle + label).
          final leftIndex = (i - 1) ~/ 2;
          final isCompleted = leftIndex < currentIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: _circleSize / 2 - 1.5),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? _yellow
                      : Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final isCompleted = stepIndex < currentIndex;
        final isActive = stepIndex == currentIndex;
        final highlighted = isActive || isCompleted;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _circleSize,
              height: _circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted ? _yellow : Colors.white.withOpacity(0.18),
                border: Border.all(
                  color: highlighted ? Colors.white : Colors.white.withOpacity(0.9),
                  width: 2,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: _yellow.withOpacity(0.6),
                    blurRadius: 10,
                  ),
                ]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: _navy, size: 18)
                  : Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  color: isActive ? _navy : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex].label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? _yellow : Colors.white,
              ),
            ),
          ],
        );
      }),
    );
  }
}