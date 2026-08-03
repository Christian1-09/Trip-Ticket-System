import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final Color valueColor;
  final VoidCallback? onTap;

  const QuickAction({required this.label, required this.icon, this.onTap,this.valueColor = AppColors.textPrimary});
}

/// "Quick Actions" section title + row of icon-label buttons.
class QuickActions extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(actions.length, (index) {
            final action = actions[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == actions.length - 1 ? 0 : 12,
                ),
                child: _ActionTile(action: action),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final QuickAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.quickActions,
          borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.statusBlue.withOpacity(0.4),width: 1.5)
        ),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.statusBlue.withOpacity(0.2),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(action.icon, color: action.valueColor, size: 25),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}