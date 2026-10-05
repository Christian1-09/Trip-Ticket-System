// features/notifications/presentation/notification_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../data/notification_model.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// The list plus its unread count, fetched in one call.
final notificationsProvider =
FutureProvider<({List<AppNotification> items, int unreadCount})>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

/// Drives the badge on the bell icon. Falls back to 0 while loading or on
/// error, so a network hiccup never breaks the header.
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0;
});