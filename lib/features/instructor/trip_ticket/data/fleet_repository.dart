// features/instructor/trip_ticket/data/fleet_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import '../../data/driver_detail_model.dart';
import 'fleet_models.dart';

/// Read-only roster for the requester's Vehicles tab.
///
/// Deliberately separate from ReferenceRepository: that one answers "who is
/// free for THIS schedule" for the booking dropdowns, this one answers
/// "who works here" for browsing. Same style, different question.
class FleetRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  FleetRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Every approved, active driver with their status, trip count and rating.
  Future<List<DriverDirectoryModel>> getDriverDirectory() async {
    final token = await _tokenStorage.getAccessToken();
    final response =
    await _apiClient.get('/trips/drivers/directory', accessToken: token);
    final list = response['drivers'] as List<dynamic>;
    return list
        .map((e) => DriverDirectoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The fleet, minus retired vehicles.
  Future<List<VehicleDirectoryModel>> getVehicleDirectory() async {
    final token = await _tokenStorage.getAccessToken();
    final response =
    await _apiClient.get('/trips/vehicles/directory', accessToken: token);
    final list = response['vehicles'] as List<dynamic>;
    return list
        .map((e) => VehicleDirectoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  /// The full record for one driver. Everything the detail screen needs,
  /// in one request.
  Future<DriverDetailModel> getDriverDetail(String driverId) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get(
      '/trips/drivers/$driverId',
      accessToken: token,
    );
    return DriverDetailModel.fromJson(
      response['driver'] as Map<String, dynamic>,
    );
  }

}