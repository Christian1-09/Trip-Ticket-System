import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/media.dart';
import '../../../../core/theme/app_colors.dart';

/// A rounded card container used for every section on the screen.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.statusCard, width: 1),
      ),
      child: child,
    );
  }
}

/// Section header with a small icon chip, title, and optional trailing widget.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = AppColors.statusBlue,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small rounded pill used for statuses like "Available", "Requester", etc.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final bool withDot;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.textColor,
    this.withDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor ?? color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single stat block: big colored value on top, small grey label below.
/// Used for the Departure / Return / Duration / Distance row and the
/// Fuel Used / Odometer / Distance row.
class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final CrossAxisAlignment alignment;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.textPrimary,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Circular avatar with a fallback to initials if no image is provided.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color color;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.color = AppColors.statusBlue,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(AppMedia.driver1),

    );
  }
}

/// Vertical dashed/solid connector dot used in the route (origin/destination)
/// and timeline sections.
class TimelineDot extends StatelessWidget {
  final Color color;
  final bool filled;

  const TimelineDot({super.key, required this.color, this.filled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}