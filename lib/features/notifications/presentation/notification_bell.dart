// features/notifications/presentation/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../../core/theme/admin_colors.dart';
import '../data/notification_model.dart';
import 'notification_providers.dart';

/// The bell, its badge, and the panel that drops out of it.
///
/// Built on the notifications feature that already exists — same
/// `AppNotification`, same repository, same `notificationsProvider` the
/// mobile NotificationsScreen uses. Nothing here is a second copy.
///
/// Owns its own overlay rather than living inside AdminTopBar, so the top
/// bar stays a layout widget and the bell can be dropped into the driver
/// or requester header later without dragging panel state along.
class NotificationBell extends ConsumerStatefulWidget {
  /// Called when an actionable notification is tapped. The shell decides
  /// where that leads — this widget has no idea what tabs exist.
  final void Function(AppNotification notification)? onOpen;

  const NotificationBell({super.key, this.onOpen});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Stack(
          children: [
            // A full-screen catcher, so clicking anywhere else closes the
            // panel — what everyone expects of a dropdown, and the thing
            // people complain about when it's missing.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _portal.hide,
              ),
            ),
            // The panel's top-right corner sits under the bell's
            // bottom-right corner, so it hangs down and to the left.
            //
            // There is deliberately no Align around the child. Align
            // without a widthFactor expands to fill its constraints, and
            // inside this Stack that is the whole window — the follower
            // would be screen-wide and the anchors would place it far off
            // one edge or the other. The follower has to size to the
            // panel itself for the anchors to mean anything.
            CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 10),
              child: _Panel(
                onClose: _portal.hide,
                onOpen: (notification) {
                  _portal.hide();
                  widget.onOpen?.call(notification);
                },
              ),
            ),
          ],
        ),
        child: IconButton(
          tooltip: unread == 0
              ? 'Notifications'
              : '$unread unread notification${unread == 1 ? '' : 's'}',
          onPressed: _portal.toggle,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, color: AdminColors.navy, size: 26),
              if (unread > 0)
                Positioned(
                  right: -5,
                  top: -4,
                  // A count, not a plain dot: "3" is a reason to click,
                  // "something happened" is not.
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17),
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Panel extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final void Function(AppNotification) onOpen;

  const _Panel({required this.onClose, required this.onOpen});

  @override
  ConsumerState<_Panel> createState() => _PanelState();
}

class _PanelState extends ConsumerState<_Panel> {
  bool _busy = false;

  Future<void> _markAllRead() async {
    setState(() => _busy = true);
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      ref.invalidate(notificationsProvider);
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Could not update. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tap(AppNotification notification) {
    // Fire and forget: the admin is already navigating away, and making
    // them wait on a write to mark something read would be absurd.
    if (!notification.isRead) {
      ref.read(notificationRepositoryProvider).markAsRead(notification.id).then(
            (_) => ref.invalidate(notificationsProvider),
        onError: (_) {},
      );
    }
    widget.onOpen(notification);
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationsProvider);
    final data = async.valueOrNull;

    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(data?.unreadCount ?? 0),
            const Divider(height: 1, color: AdminColors.border),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: _body(async, data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(int unread) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: AdminColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unread new',
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (unread > 0)
            TextButton(
              onPressed: _busy ? null : _markAllRead,
              style: TextButton.styleFrom(
                foregroundColor: AdminColors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _busy ? 'Marking…' : 'Mark all read',
                style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          IconButton(
            tooltip: 'Close',
            onPressed: widget.onClose,
            iconSize: 18,
            splashRadius: 18,
            icon: const Icon(Icons.close_rounded, color: AdminColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _body(
      AsyncValue<({List<AppNotification> items, int unreadCount})> async,
      ({List<AppNotification> items, int unreadCount})? data,
      ) {
    // Only on the very first load — a 30-second refresh keeps the list on
    // screen rather than flashing a spinner at someone reading it.
    if (data == null && async.isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (data == null) {
      return _empty(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load notifications',
        subtitle: async.error is ApiException
            ? (async.error as ApiException).message
            : 'Check your connection.',
      );
    }

    if (data.items.isEmpty) {
      return _empty(
        icon: Icons.notifications_none_rounded,
        title: 'Nothing new',
        subtitle: 'Trip requests, driver sign-ups and incidents show up here.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: data.items.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: AdminColors.border),
      itemBuilder: (context, index) => _Row(
        notification: data.items[index],
        onTap: () => _tap(data.items[index]),
      ),
    );
  }

  Widget _empty({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: const Color(0xFFC3CBDC)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AdminColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AdminColors.textMuted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Row extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _Row({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    // Icon and colour come from the model, so this panel and the mobile
    // NotificationsScreen can never disagree about what a trip rejection
    // looks like.
    final color = notification.color;

    return Material(
      // Unread rows get a faint blue wash. Subtle on purpose — a list
      // where half the rows shout is a list nobody scans.
      color: unread ? const Color(0xFFF4F8FF) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(notification.icon, size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AdminColors.navy,
                        fontSize: 13,
                        fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          notification.whenLabel,
                          style: const TextStyle(
                            color: Color(0xFF9AA4BC),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (notification.isActionable) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.open_in_new_rounded,
                              size: 11, color: Color(0xFF9AA4BC)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AdminColors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}