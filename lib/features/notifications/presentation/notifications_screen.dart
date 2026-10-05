// features/notifications/presentation/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../data/notification_model.dart';
import 'notification_providers.dart';

// ─────────────────────────────────────────────────────────── light palette

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _pageBg = Color(0xFFF2F5FA);
const _unreadBg = Color(0xFFE7F0FD);
const _chipBg = Color(0xFFE3ECFC);
const _divider = Color(0xFFE9EDF4);
const _red = Color(0xFFE5394A);

enum _NotifFilter { all, unread }

/// Shared by every role — each user only ever gets their own notifications.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _NotifFilter _filter = _NotifFilter.all;

  Future<void> _markAll() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      ref.invalidate(notificationsProvider);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _open(AppNotification item) async {
    if (!item.isRead) {
      // Fire and forget — a failed mark-as-read should not block the sheet.
      ref.read(notificationRepositoryProvider).markAsRead(item.id).then(
            (_) => ref.invalidate(notificationsProvider),
        onError: (_) {},
      );
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationSheet(item: item),
    );
  }

  void _showMenu(BuildContext anchorContext, int unread) async {
    final box = anchorContext.findRenderObject() as RenderBox;
    final overlay =
    Overlay.of(anchorContext).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(box.size.bottomLeft(Offset.zero), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final choice = await showMenu<String>(
      context: anchorContext,
      position: position,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        _menuItem('all', Icons.notifications_outlined, 'All notifications',
            _filter == _NotifFilter.all),
        _menuItem('unread', Icons.mark_email_unread_outlined, 'Unread only',
            _filter == _NotifFilter.unread),
        if (unread > 0) const PopupMenuDivider(),
        if (unread > 0)
          _menuItem('markAll', Icons.done_all_rounded, 'Mark all as read', false),
      ],
    );

    switch (choice) {
      case 'all':
        setState(() => _filter = _NotifFilter.all);
      case 'unread':
        setState(() => _filter = _NotifFilter.unread);
      case 'markAll':
        _markAll();
    }
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, bool selected) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 19, color: selected ? _blue : _navy),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? _blue : _navy,
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (selected) const Icon(Icons.check, size: 17, color: _blue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationsProvider);
    final unread = async.valueOrNull?.unreadCount ?? 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: _pageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: _navy),
          titleSpacing: 4,
          title: Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            Builder(
              builder: (btnContext) => IconButton(
                tooltip: 'Filter',
                icon: Icon(
                  Icons.tune_rounded,
                  color: _filter == _NotifFilter.unread ? _blue : _navy,
                ),
                onPressed: () => _showMenu(btnContext, unread),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: RefreshIndicator(
          color: _blue,
          onRefresh: () async {
            ref.invalidate(notificationsProvider);
            await ref.read(notificationsProvider.future);
          },
          child: async.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: _blue),
            ),
            error: (err, _) => ListView(
              padding: const EdgeInsets.all(32),
              children: [
                const Icon(Icons.error_outline, color: _red, size: 38),
                const SizedBox(height: 10),
                Text(
                  err is ApiException
                      ? err.message
                      : 'Could not load notifications.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _navy, fontSize: 13.5),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(notificationsProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
            data: (result) {
              final items = _filter == _NotifFilter.unread
                  ? result.items.where((n) => !n.isRead).toList()
                  : result.items;

              if (items.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(40, 80, 40, 40),
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: const BoxDecoration(
                          color: _chipBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none_rounded,
                            size: 42, color: _blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _filter == _NotifFilter.unread
                          ? "You're all caught up."
                          : 'No notifications yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Updates about your trips will show up here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 12.5),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                itemCount: items.length,
                itemBuilder: (_, index) => _NotificationTile(
                  item: items[index],
                  onTap: () => _open(items[index]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── list tile

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: unread ? _unreadBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unread ? _blue.withOpacity(0.25) : Colors.transparent,
              ),
              boxShadow: unread
                  ? null
                  : [
                BoxShadow(
                  color: _navy.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotifIcon(item: item, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _navy,
                                fontSize: 14.5,
                                fontWeight:
                                unread ? FontWeight.w800 : FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.whenLabel,
                              style: const TextStyle(
                                  color: _muted, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      if (item.ticketNumber != null) ...[
                        const SizedBox(height: 8),
                        _TicketChip(ticket: item.ticketNumber!),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: Column(
                    children: [
                      const Icon(Icons.chevron_right, color: _muted, size: 22),
                      if (unread) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round icon: soft tinted ring with a solid inner circle, like the design.
class _NotifIcon extends StatelessWidget {
  final AppNotification item;
  final double size;

  const _NotifIcon({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.17),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        child: Icon(item.icon, color: Colors.white, size: size * 0.38),
      ),
    );
  }
}

class _TicketChip extends StatelessWidget {
  final String ticket;
  const _TicketChip({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description, size: 14, color: _blue),
          const SizedBox(width: 6),
          Text(
            ticket,
            style: const TextStyle(
              color: _blue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── detail sheet

class _NotificationSheet extends StatelessWidget {
  final AppNotification item;
  const _NotificationSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DBE6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NotifIcon(item: item, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.whenLabel,
                          style: const TextStyle(color: _muted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: _pageBg,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(Icons.close_rounded, size: 19, color: _navy),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: _divider),
              const SizedBox(height: 16),
              Text(
                item.message,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              if (item.ticketNumber != null) ...[
                const SizedBox(height: 16),
                _TicketChip(ticket: item.ticketNumber!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}