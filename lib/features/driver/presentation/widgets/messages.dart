import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

class Messages extends StatelessWidget {
  final String headerText;
  final String? imagePath;
  final String date;
  final String bodyText;

  /// When true, shows the "Quick review" star row + "Write review" pill
  /// (used for the "Trip Completed" variant).
  final bool showReview;

  /// Shows a small red dot next to [headerText] (unread indicator).
  final bool isUnread;

  final VoidCallback? onTap;
  final VoidCallback? onWriteReviewTap;

  const Messages({
    super.key,
    required this.headerText,
    required this.imagePath,
    required this.bodyText,
    this.date = 'Yesterday',
    this.showReview = false,
    this.isUnread = false,
    this.onTap,
    this.onWriteReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          border: Border.all(color: AppColors.statusBlue.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────────────
            _Avatar(imagePath: imagePath),
            const SizedBox(width: 12),

            // ── Header + body + optional review row ─────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        headerText,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        date,
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bodyText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if (showReview) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Quick review',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            5,
                                (_) => const Icon(
                              Icons.star_border_rounded,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _WriteReviewButton(onTap: onWriteReviewTap),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? imagePath;

  const _Avatar({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardDark,
        border: Border.all(color: AppColors.statusBlue.withOpacity(0.8), width: 1.5),
        image: imagePath != null
            ? DecorationImage(
          image: AssetImage(imagePath!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: imagePath == null
          ? const Icon(Icons.person_rounded, color: Colors.white38, size: 24)
          : null,
    );
  }
}

class _WriteReviewButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _WriteReviewButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.statusBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Write review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}