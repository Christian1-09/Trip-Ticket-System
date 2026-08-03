// core/widgets/step_indicator.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

class StepInfo {
  final String label;
  const StepInfo(this.label);
}

class StepIndicator extends StatelessWidget {
  final List<StepInfo> steps;
  final int currentIndex; // 0-based

  const StepIndicator({
    required this.steps,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connecting line between circle (i-1)/2 and (i+1)/2
          final leftIndex = (i - 1) ~/ 2;
          final isCompleted = leftIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? AppColors.statusBlue
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final isCompleted = stepIndex < currentIndex;
        final isActive = stepIndex == currentIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.statusBlue
                    : isActive
                    ? AppColors.accentYellow
                    : Colors.transparent,
                border: Border.all(
                  color: isActive || isCompleted
                      ? Colors.transparent
                      : AppColors.textSecondary.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: AppColors.accentYellow.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  color: isActive ? AppColors.cardDeepBlue : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex].label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.accentYellow : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}