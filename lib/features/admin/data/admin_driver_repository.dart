// features/admin/data/admin_driver_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/driver_model.dart';

class AdminDriverRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AdminDriverRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Approved drivers and the head driver. [status] optionally filters by
  /// AVAILABLE, ON_TRIP or OFF_DUTY.
  Future<List<AdminDriverModel>> getDrivers({String? status}) async {
    final token = await _tokenStorage.getAccessToken();
    final query = (status == null || status.isEmpty) ? '' : '?status=$status';
    final response = await _apiClient.get('/admin/drivers$query', accessToken: token);
    final list = response['drivers'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminDriverModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Only AVAILABLE or OFF_DUTY — ON_TRIP is set by the system. Fails with
  /// 409 if the driver is currently out on a trip.
  Future<void> setStatus(String driverId, String status) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch(
      '/admin/drivers/$driverId/status',
      body: {'status': status},
      accessToken: token,
    );
  }

  /// Promote to HEAD_DRIVER or demote to DRIVER. Fails with 409 when a
  /// head driver already exists — only one is allowed at a time.
  Future<void> updateRole(String driverId, String role) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch(
      '/admin/users/$driverId/role',
      body: {'role': role},
      accessToken: token,
    );
  }
}