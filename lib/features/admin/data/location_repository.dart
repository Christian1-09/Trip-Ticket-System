// features/admin/data/location_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/location_model.dart';

class AdminLocationRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AdminLocationRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// [status] is 'active', 'inactive', or empty for everything.
  Future<List<AdminLocationModel>> listAll({String status = ''}) async {
    final token = await _tokenStorage.getAccessToken();
    final query = status.isEmpty ? '' : '?status=$status';
    final response =
    await _apiClient.get('/admin/locations$query', accessToken: token);
    final list = response['locations'] as List<dynamic>;
    return list
        .map((e) => AdminLocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String name,
    required int travelMinutes,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/admin/locations',
      body: {'name': name, 'travelMinutes': travelMinutes},
      accessToken: token,
    );
  }

  /// Every field is optional; send only what changed. The backend rejects
  /// an empty body with a 400.
  Future<void> update(
      String id, {
        String? name,
        int? travelMinutes,
        bool? isActive,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch(
      '/admin/locations/$id',
      body: {
        if (name != null) 'name': name,
        if (travelMinutes != null) 'travelMinutes': travelMinutes,
        if (isActive != null) 'isActive': isActive,
      },
      accessToken: token,
    );
  }

  /// Only works for a location no trip has ever used. The backend answers
  /// 409 otherwise and says to deactivate it instead.
  Future<void> delete(String id) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.delete('/admin/locations/$id', accessToken: token);
  }
}