// features/admin/data/admin_dashboard_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/dashboard_models.dart';

class AdminDashboardRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AdminDashboardRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<AdminDashboard> getDashboard() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/dashboard', accessToken: token);
    return AdminDashboard.fromJson(response['dashboard'] as Map<String, dynamic>);
  }

  /// [months] is how far back the monthly chart reaches, 1 to 24.
  Future<AdminAnalytics> getAnalytics({int months = 6}) async {
    final token = await _tokenStorage.getAccessToken();
    final response =
    await _apiClient.get('/admin/analytics?months=$months', accessToken: token);
    return AdminAnalytics.fromJson(response['analytics'] as Map<String, dynamic>);
  }
}