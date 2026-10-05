// features/admin/data/vehicle_repository.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  VehicleRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<List<VehicleModel>> listAll() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/vehicles', accessToken: token);
    final list = response['vehicles'] as List<dynamic>;
    return list.map((e) => VehicleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Approved, active drivers the admin can assign to a vehicle.
  ///
  /// Reuses GET /admin/drivers, which already returns only approved drivers
  /// with their codes — no new endpoint needed for the picker.
  Future<List<VehicleDriver>> listAssignableDrivers() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/drivers', accessToken: token);
    final list = response['drivers'] as List<dynamic>;
    return list
        .map((e) => VehicleDriver.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String model,
    required String type,
    required String plateNumber,
    required String capacity,
    required String year,
    required String odometerCurrent,
    Uint8List? imageBytes,
    String? imageFilename,
    List<VehicleAssignmentInput> assignments = const [],
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final fields = <String, String>{
      'model': model,
      'type': type,
      'plateNumber': plateNumber,
      'capacity': capacity,
      'year': year,
      'odometerCurrent': odometerCurrent,
      // Multipart fields are strings, so the driver list travels as JSON.
      // Sent with the vehicle so it can't be saved with its drivers missing
      // because a follow-up call failed.
      if (assignments.isNotEmpty)
        'assignments': jsonEncode(assignments.map((a) => a.toJson()).toList()),
    };

    final files = <MultipartFilePart>[
      if (imageBytes != null && imageFilename != null)
        MultipartFilePart(
          fieldName: 'image',
          bytes: imageBytes,
          filename: imageFilename,
          mimeType: _guessMimeType(imageFilename),
        ),
    ];

    await _apiClient.postMultipart(
      '/admin/vehicles',
      fields: fields,
      files: files,
      accessToken: token,
    );
  }

  /// Edits the vehicle's details. The photo is not changed here — that
  /// needs a multipart upload, which only the create endpoint handles.
  /// Driver assignments go through [setDrivers].
  Future<void> update(
      String vehicleId, {
        String? model,
        String? type,
        String? plateNumber,
        String? capacity,
        String? year,
        String? fuelType,
        String? odometerCurrent,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch(
      '/admin/vehicles/$vehicleId',
      body: {
        if (model != null) 'model': model,
        if (type != null) 'type': type,
        if (plateNumber != null) 'plateNumber': plateNumber,
        if (capacity != null) 'capacity': capacity,
        if (year != null) 'year': year,
        if (fuelType != null) 'fuelType': fuelType,
        if (odometerCurrent != null) 'odometerCurrent': odometerCurrent,
      },
      accessToken: token,
    );
  }

  /// Replaces the vehicle's whole driver list.
  ///
  /// Send the complete set you want; anything not in it is unassigned. An
  /// empty list clears all assignments. At most one entry may be primary —
  /// the server answers 400 otherwise.
  Future<List<VehicleDriver>> setDrivers(
      String vehicleId,
      List<VehicleAssignmentInput> assignments,
      ) async {
    final token = await _tokenStorage.getAccessToken();
    // PATCH, not PUT: your ApiClient has no put() method, and adding one to
    // a shared class for a single call isn't worth it. The backend route
    // changes to router.patch — see the patch notes.
    final response = await _apiClient.patch(
      '/admin/vehicles/$vehicleId/drivers',
      body: {'assignments': assignments.map((a) => a.toJson()).toList()},
      accessToken: token,
    );
    final list = response['drivers'] as List<dynamic>? ?? const [];
    return list
        .map((e) => VehicleDriver.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ACTIVE, MAINTENANCE or INACTIVE. ON_TRIP is set by the system, and a
  /// vehicle currently out on the road is refused with a 409.
  ///
  /// Returns the upcoming trips still booked on this vehicle, so the caller
  /// can warn the admin — those trips are NOT cancelled automatically.
  Future<List<String>> setStatus(String vehicleId, String status) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.patch(
      '/admin/vehicles/$vehicleId/status',
      body: {'status': status},
      accessToken: token,
    );
    final affected = response['affectedTrips'] as List<dynamic>? ?? [];
    return affected
        .map((e) => (e as Map<String, dynamic>)['ticketNumber'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Only works for a vehicle that has never been used on a trip; the
  /// backend answers 409 otherwise and suggests deactivating it instead.
  Future<void> delete(String vehicleId) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.delete('/admin/vehicles/$vehicleId', accessToken: token);
  }

  String _guessMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }
}