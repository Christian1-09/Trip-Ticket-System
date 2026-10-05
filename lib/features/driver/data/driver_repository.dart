// features/driver/data/driver_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'driver_models.dart';

class DriverRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  DriverRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<DriverProfileSummary> getProfile() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/driver/profile', accessToken: token);
    return DriverProfileSummary.fromJson(response['profile'] as Map<String, dynamic>);
  }

  /// [scope] is "active" (awaiting / accepted / ongoing) or "history".
  Future<List<DriverTrip>> getTrips({String scope = 'active'}) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/driver/trips?scope=$scope', accessToken: token);
    final list = response['trips'] as List<dynamic>? ?? [];
    return list.map((e) => DriverTrip.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DriverTrip> getTrip(String tripId) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/driver/trips/$tripId', accessToken: token);
    return DriverTrip.fromJson(response['trip'] as Map<String, dynamic>);
  }

  Future<void> acceptTrip(String tripId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post('/driver/trips/$tripId/accept', accessToken: token);
  }

  Future<void> declineTrip(String tripId, String reason) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/driver/trips/$tripId/decline',
      body: {'reason': reason},
      accessToken: token,
    );
  }

  Future<void> recordDeparture(
      String tripId, {
        required int odometerStart,
        required double fuelBalanceInTank,
        required double fuelIssuedByOffice,
        required double fuelPurchasedDuring,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/driver/trips/$tripId/depart',
      body: {
        'odometerStart': odometerStart,
        'fuelBalanceInTank': fuelBalanceInTank,
        'fuelIssuedByOffice': fuelIssuedByOffice,
        'fuelPurchasedDuring': fuelPurchasedDuring,
      },
      accessToken: token,
    );
  }

  Future<void> recordReturn(
      String tripId, {
        required int odometerEnd,
        required double balanceInTankLiters,
        required DateTime arrivedAtDestination,
        required DateTime departedFromDestination,
        double? gearOilUsedLiters,
        double? lubricatingOilUsedLiters,
        double? greaseIssuedLiters,
        String? remarks,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/driver/trips/$tripId/return',
      body: {
        'odometerEnd': odometerEnd,
        'balanceInTankLiters': balanceInTankLiters,
        // .toUtc() so the ISO string carries a timezone, like every other
        // time the app sends.
        'arrivedAtDestination': arrivedAtDestination.toUtc().toIso8601String(),
        'departedFromDestination': departedFromDestination.toUtc().toIso8601String(),
        if (gearOilUsedLiters != null) 'gearOilUsedLiters': gearOilUsedLiters,
        if (lubricatingOilUsedLiters != null)
          'lubricatingOilUsedLiters': lubricatingOilUsedLiters,
        if (greaseIssuedLiters != null) 'greaseIssuedLiters': greaseIssuedLiters,
        if (remarks != null && remarks.trim().isNotEmpty) 'remarks': remarks.trim(),
      },
      accessToken: token,
    );
  }
}