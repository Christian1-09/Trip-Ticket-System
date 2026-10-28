// features/admin/data/tracking_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';

import 'models/tracking_model.dart';

/// Admin-side reads of the GPS data.
///
/// Nothing here writes. Positions only ever arrive from a paired device
/// posting to /api/tracking/ping with its own token, never from the panel.
class TrackingRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  TrackingRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Last known position of every trackable vehicle, with its ongoing trip
  /// attached when it has one.
  Future<List<LiveVehicle>> listLive() async {
    final token = await _tokenStorage.getAccessToken();
    final response =
    await _apiClient.get('/admin/tracking/live', accessToken: token);
    final list = response['vehicles'] as List<dynamic>? ?? const [];
    return list
        .map((e) => LiveVehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The full track for one trip, oldest fix first.
  Future<TripTrack> getTripTrack(String tripRequestId) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get(
      '/admin/tracking/trips/$tripRequestId/track',
      accessToken: token,
    );
    return TripTrack.fromJson(response);
  }

  /// Issues a device token for a vehicle. The token comes back exactly
  /// once — it is not retrievable afterwards, so losing it means pairing
  /// again. Used by the pairing screen, not the map.
  Future<String> pairDevice(String vehicleId, {String? deviceName}) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.post(
      '/admin/vehicles/$vehicleId/device',
      body: {if (deviceName != null) 'deviceName': deviceName},
      accessToken: token,
    );
    final device = response['device'] as Map<String, dynamic>;
    return device['deviceToken'] as String;
  }

  Future<void> unpairDevice(String vehicleId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.delete(
      '/admin/vehicles/$vehicleId/device',
      accessToken: token,
    );
  }
}