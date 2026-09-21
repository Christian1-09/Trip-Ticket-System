// features/head_driver/data/head_driver_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'head_driver_models.dart';

class HeadDriverRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  HeadDriverRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  List<HeadDriverTrip> _parseTrips(Map<String, dynamic> response) {
    final list = response['trips'] as List<dynamic>? ?? [];
    return list
        .map((e) => HeadDriverTrip.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Trips the Admin approved that now need the Head Driver's approval.
  Future<List<HeadDriverTrip>> getPendingApprovals() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/head-driver/trips/pending', accessToken: token);
    return _parseTrips(response);
  }

  /// Trips whose driver declined and that need a replacement.
  Future<List<HeadDriverTrip>> getDeclinedTrips() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/head-driver/trips/declined', accessToken: token);
    return _parseTrips(response);
  }

  Future<void> approveTrip(String tripId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post('/head-driver/trips/$tripId/approve', accessToken: token);
  }

  Future<void> rejectTrip(String tripId, String reason) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/head-driver/trips/$tripId/reject',
      body: {'reason': reason},
      accessToken: token,
    );
  }

  Future<List<ReplacementDriver>> getReplacementDrivers(String tripId) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get(
      '/head-driver/trips/$tripId/replacement-drivers',
      accessToken: token,
    );
    final list = response['drivers'] as List<dynamic>? ?? [];
    return list
        .map((e) => ReplacementDriver.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// May fail with 409 if the chosen driver was booked by another trip in
  /// the meantime — the message names the clashing ticket.
  Future<void> reassignDriver(String tripId, String driverId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/head-driver/trips/$tripId/reassign',
      body: {'driverId': driverId},
      accessToken: token,
    );
  }
}