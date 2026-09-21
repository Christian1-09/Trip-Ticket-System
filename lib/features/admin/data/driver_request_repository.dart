// features/admin/data/driver_request_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/request_model.dart';

class DriverRequestRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  DriverRequestRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<List<RequestModel>> listPending() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/drivers/pending', accessToken: token);
    final list = response['drivers'] as List<dynamic>;
    return list.map((e) => RequestModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approve(String driverId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post('/admin/drivers/$driverId/approve', accessToken: token);
  }

  /// Permanently deletes the driver's account.
  Future<void> reject(String driverId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post('/admin/drivers/$driverId/reject', accessToken: token);
  }
}