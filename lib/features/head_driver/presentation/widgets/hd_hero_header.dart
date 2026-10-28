// features/head_driver/presentation/widgets/hd_hero_header.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/media.dart';

/// Hero banner with greeting, notification bell and a floating search bar
/// that overlaps the bottom edge of the image.
class HdHeroHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final int notificationCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool filterActive;
  final VoidCallback onFilterTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const HdHeroHeader({
    super.key,
    required this.name,
    required this.subtitle,
    required this.notificationCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.filterActive,
    required this.onFilterTap,
    this.onMenuTap,
    this.onNotificationTap,
  });

  static const double _imageHeight = 230;
  static const double _searchHeight = 56;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: top + _imageHeight + _searchHeight / 2,
      child: Stack(
        children: [
          // ---------- Banner ----------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + _imageHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppMedia.scheduleHeaderImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.homeNavy),
                  ),
                  // Darken the left side so the white text stays readable.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0, 0.55, 1],
                        colors: [
                          AppColors.homeNavyDark.withOpacity(0.85),
                          AppColors.homeNavy.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, top + 8, 16, _searchHeight / 2 + 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (onMenuTap != null)
                              IconButton(
                                onPressed: onMenuTap,
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                                icon: const Icon(Icons.menu_rounded,
                                    color: Colors.white, size: 28),
                              ),
                            const Spacer(),
                            _Bell(count: notificationCount, onTap: onNotificationTap),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${_greeting()},',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$name!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 210,
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12.5, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- Floating search bar ----------
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            height: _searchHeight,
            child: _SearchBar(
              controller: searchController,
              onChanged: onSearchChanged,
              filterActive: filterActive,
              onFilterTap: onFilterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  const _Bell({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.homeNavy.withOpacity(0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.notifications_rounded, color: Colors.white),
          ),
          if (count > 0)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.homeNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool filterActive;
  final VoidCallback onFilterTap;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.filterActive,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.homeIconBlue.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeNavy.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppColors.homeTextDark),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: AppColors.homeTextDark, fontSize: 14),
              decoration: const InputDecoration.collapsed(
                hintText: 'Search schedule trips...',
                hintStyle: TextStyle(color: AppColors.homeTextMuted, fontSize: 13),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.homeTextMuted),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
          ),
          Tooltip(
            message: 'Urgent trips only',
            child: GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: 46,
                height: 36,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  // Yellow like the mockup; turns navy while "urgent only" is on.
                  color: filterActive ? AppColors.homeNavy : AppColors.accentYellow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: filterActive ? AppColors.accentYellow : AppColors.homeNavyDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}