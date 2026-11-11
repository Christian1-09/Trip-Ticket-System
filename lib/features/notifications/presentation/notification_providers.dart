// features/notifications/presentation/notification_providers.dart
import 'dart:async';

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

/// How often the list refetches itself.
///
/// Thirty seconds, not ten. A trip request sitting unseen for half a
/// minute costs nobody anything, and the vehicle map already polls every
/// ten — two fast pollers on one screen is a lot of traffic for a campus
/// server to carry all day.
const _pollInterval = Duration(seconds: 30);

/// The list plus its unread count, fetched in one call.
///
/// Now refreshes on a timer. Without it the bell could only ever show
/// whatever was true when the admin first opened the panel, which is not
/// a notification system — it's a page of history.
final notificationsProvider =
FutureProvider<({List<AppNotification> items, int unreadCount})>((ref) {
  // Scheduled before the request, so a slow or failing call doesn't stop
  // the clock. A dead backend retries every 30s and recovers by itself.
  final timer = Timer(_pollInterval, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return ref.watch(notificationRepositoryProvider).getNotifications();
});

/// Drives the badge on the bell icon. Falls back to 0 while loading or on
/// error, so a network hiccup never breaks the header.
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0;
});