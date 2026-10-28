// features/admin/presentation/widgets/admin_top_bar.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/admin_colors.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onNotifications;
  final bool hasUnread;

  const AdminTopBar({
    super.key,
    required this.title,
    this.onSearch,
    this.onNotifications,
    this.hasUnread = true,
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
                hintStyle: const TextStyle(color: AdminColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20, color: AdminColors.navy),
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
          IconButton(
            onPressed: onNotifications,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications, color: AdminColors.navy, size: 26),
                if (hasUnread)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}