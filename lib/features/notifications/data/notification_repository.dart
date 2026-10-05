// features/notifications/data/notification_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  NotificationRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Newest first. The response also carries unreadCount for the bell badge.
  Future<({List<AppNotification> items, int unreadCount})> getNotifications() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/notifications?limit=50', accessToken: token);
    final list = response['notifications'] as List<dynamic>? ?? [];
    return (
    items: list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList(),
    unreadCount: (response['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<int> getUnreadCount() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/notifications/unread-count', accessToken: token);
    return (response['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch('/notifications/$id/read', accessToken: token);
  }

  Future<void> markAllAsRead() async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post('/notifications/read-all', accessToken: token);
  }
}