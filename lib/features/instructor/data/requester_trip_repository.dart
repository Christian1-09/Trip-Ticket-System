// features/instructor/data/requester_trip_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'requester_trip_models.dart';

class RequesterTripRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  RequesterTripRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// The requester's own trips, newest first.
  Future<List<RequesterTrip>> getMyTrips() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/trips/mine', accessToken: token);
    final list = response['trips'] as List<dynamic>? ?? [];
    return list
        .map((e) => RequesterTrip.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RequesterTrip> getTrip(String tripId) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/trips/$tripId', accessToken: token);
    return RequesterTrip.fromJson(response['trip'] as Map<String, dynamic>);
  }

  /// Only once, and only after the trip is completed — the backend enforces
  /// both and answers 409 on a second attempt.
  Future<void> rateDriver(String tripId, {required int score, String? comment}) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/trips/$tripId/rating',
      body: {
        'score': score,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      },
      accessToken: token,
    );
  }
}