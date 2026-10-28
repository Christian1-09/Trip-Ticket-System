// features/admin/data/location_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/location_model.dart';

/// Sentinel for "this argument was not passed", so the coordinate fields
/// can tell "leave it alone" apart from "clear it". Without it there'd be
/// no way to remove a geofence once set.
const Object _unset = Object();

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
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/admin/locations',
      body: {
        'name': name,
        'travelMinutes': travelMinutes,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusMeters != null) 'radiusMeters': radiusMeters,
      },
      accessToken: token,
    );
  }

  /// Send only what changed. Pass `null` explicitly for a coordinate to
  /// clear the geofence; omit it to leave the current value alone.
  Future<void> update(
      String id, {
        String? name,
        int? travelMinutes,
        bool? isActive,
        Object? latitude = _unset,
        Object? longitude = _unset,
        Object? radiusMeters = _unset,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch(
      '/admin/locations/$id',
      body: {
        if (name != null) 'name': name,
        if (travelMinutes != null) 'travelMinutes': travelMinutes,
        if (isActive != null) 'isActive': isActive,
        if (!identical(latitude, _unset)) 'latitude': latitude,
        if (!identical(longitude, _unset)) 'longitude': longitude,
        if (!identical(radiusMeters, _unset)) 'radiusMeters': radiusMeters,
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