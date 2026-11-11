// features/admin/presentation/widgets/admin_top_bar.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/notifications/data/notification_model.dart';
import 'package:jtrips_app/features/notifications/presentation/notification_bell.dart';

import '../../../../core/theme/admin_colors.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final ValueChanged<String>? onSearch;

  /// Called when the admin taps a notification that points at something —
  /// a trip request, a pending driver, an incident. The shell decides
  /// which tab that means; the top bar doesn't know tabs exist.
  final void Function(AppNotification notification)? onOpenNotification;

  const AdminTopBar({
    super.key,
    required this.title,
    this.onSearch,
    this.onOpenNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  color: AdminColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          SizedBox(
            width: 270,
            height: 40,
            child: TextField(
              onSubmitted: onSearch,
              style: const TextStyle(fontSize: 13, color: AdminColors.navy),
              decoration: InputDecoration(
                hintText: 'Search trips...',
                hintStyle:
                const TextStyle(color: AdminColors.textMuted, fontSize: 13),
                prefixIcon:
                const Icon(Icons.search, size: 20, color: AdminColors.navy),
                filled: true,
                fillColor: AdminColors.background,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // The badge and the dropdown live inside the bell. The old
          // `hasUnread` flag is gone — it defaulted to true and nothing
          // ever passed it, so the red dot had been lit permanently since
          // the day this file was written.
          NotificationBell(onOpen: onOpenNotification),
        ],
      ),
    );
  }
}