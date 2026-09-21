// features/trip_ticket/data/reference_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'reference_models.dart';

class ReferenceRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ReferenceRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<List<DepartmentModel>> getDepartments() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/trips/departments', accessToken: token);
    final list = response['departments'] as List<dynamic>;
    return list.map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Active destinations with their travel time from base.
  Future<List<LocationModel>> getLocations() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/trips/locations', accessToken: token);
    final list = response['locations'] as List<dynamic>;
    return list.map((e) => LocationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [query] comes from buildAvailabilityQuery(). When it is empty the
  /// backend returns every eligible driver instead of filtering by time.
  Future<List<AvailableDriverModel>> getAvailableDrivers([String query = '']) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/trips/drivers/available$query', accessToken: token);
    final list = response['drivers'] as List<dynamic>;
    return list.map((e) => AvailableDriverModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AvailableVehicleModel>> getAvailableVehicles([String query = '']) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/trips/vehicles/available$query', accessToken: token);
    final list = response['vehicles'] as List<dynamic>;
    return list.map((e) => AvailableVehicleModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}