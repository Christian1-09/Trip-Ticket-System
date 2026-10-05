import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

import 'home_section_card.dart';

class QuickAction {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color valueColor;

  /// Filled navy tile (like "Book Trip" in the design).
  final bool highlighted;
  final VoidCallback? onTap;

  const QuickAction({
    required this.label,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.highlighted = false,
    this.valueColor = AppColors.homeIconBlue,
  });
}

/// "Quick Actions" white section + row of tiles.
class QuickActions extends StatelessWidget {
  final List<QuickAction> actions;
  final VoidCallback? onSeeAll;

  const QuickActions({super.key, required this.actions, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return HomeSectionCard(
      title: 'Quick Actions',
      actionLabel: onSeeAll == null ? null : 'See All',
      onAction: onSeeAll,
      child: Row(
        children: List.generate(actions.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == actions.length - 1 ? 0 : 10,
              ),
              child: _ActionTile(action: actions[index]),
            ),
          );
        }),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final QuickAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final hi = action.highlighted;

    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          gradient: hi
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.homeNavy, AppColors.homeNavyDark],
          )
              : null,
          color: hi ? null : AppColors.homeTileBlue,
          borderRadius: BorderRadius.circular(14),
          border: hi
              ? null
              : Border.all(color: AppColors.homeIconBlue.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: hi ? Colors.white.withOpacity(0.15) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                color: hi ? Colors.white : action.valueColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hi ? Colors.white : AppColors.homeTextDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (action.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                action.subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: hi ? Colors.white70 : AppColors.homeTextMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}