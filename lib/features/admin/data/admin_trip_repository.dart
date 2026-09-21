// features/admin/data/admin_trip_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/admin_trip_model.dart';

class AdminTripRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AdminTripRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<List<AdminTripModel>> getPendingTrips() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/trips/pending', accessToken: token);
    final list = response['trips'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdminTripModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// May fail with 409 when the driver or vehicle was taken by another trip
  /// that was approved first — the message explains which ticket clashes.
  Future<void> approveTrip(String tripId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post('/admin/trips/$tripId/approve', accessToken: token);
  }

  Future<void> rejectTrip(String tripId, String reason) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/admin/trips/$tripId/reject',
      body: {'reason': reason},
      accessToken: token,
    );
  }
}