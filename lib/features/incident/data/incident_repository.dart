// features/incident/data/incident_repository.dart
import 'dart:typed_data';

import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';

import 'incident_model.dart';

/// One repository for every role.
///
/// The backend scopes what each caller is allowed to see, so there is no
/// "my incidents" method here alongside a "list all" — both would hit the
/// same endpoint and one of them would eventually drift.
class IncidentRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  IncidentRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// The types this user is allowed to report. A driver and a passenger
  /// get different lists; the form renders whatever comes back rather
  /// than hard-coding either.
  Future<IncidentOptions> fetchOptions() async {
    final token = await _tokenStorage.getAccessToken();
    final response =
    await _apiClient.get('/incidents/options', accessToken: token);
    return IncidentOptions.fromJson(response);
  }

  Future<List<IncidentModel>> list({
    String? status,
    String? severity,
    String? vehicleId,
    String? tripRequestId,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final query = <String, String>{
      if (status != null) 'status': status,
      if (severity != null) 'severity': severity,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (tripRequestId != null) 'tripRequestId': tripRequestId,
    };

    final suffix = query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    final response =
    await _apiClient.get('/incidents$suffix', accessToken: token);
    final list = response['incidents'] as List<dynamic>? ?? const [];
    return list
        .map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<IncidentModel> getById(String id) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/incidents/$id', accessToken: token);
    return IncidentModel.fromJson(response['incident'] as Map<String, dynamic>);
  }

  /// Files a report.
  ///
  /// Multipart because of the photos. Every field travels as a string —
  /// that is simply how multipart works — and the server parses them
  /// back, which is also how your vehicle create already behaves.
  ///
  /// Leave [latitude] and [longitude] null on an ongoing trip and the
  /// server fills them from the vehicle's last tracker fix.
  Future<IncidentModel> create({
    required String type,
    required String severity,
    required String description,
    String? tripRequestId,
    String? vehicleId,
    String? locationText,
    double? latitude,
    double? longitude,
    DateTime? occurredAt,
    List<IncidentPhoto> photos = const [],
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final fields = <String, String>{
      'type': type,
      'severity': severity,
      'description': description,
      if (tripRequestId != null) 'tripRequestId': tripRequestId,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (locationText != null && locationText.trim().isNotEmpty)
        'locationText': locationText.trim(),
      if (latitude != null) 'latitude': '$latitude',
      if (longitude != null) 'longitude': '$longitude',
      if (occurredAt != null) 'occurredAt': occurredAt.toUtc().toIso8601String(),
    };

    final files = photos
        .map((photo) => MultipartFilePart(
      fieldName: 'photos',
      bytes: photo.bytes,
      filename: photo.filename,
      mimeType: photo.mimeType,
    ))
        .toList();

    final response = await _apiClient.postMultipart(
      '/incidents',
      fields: fields,
      files: files,
      accessToken: token,
    );

    return IncidentModel.fromJson(response['incident'] as Map<String, dynamic>);
  }

  // ---- Admin only -------------------------------------------------------

  Future<int> countOpen() async {
    final token = await _tokenStorage.getAccessToken();
    final response =
    await _apiClient.get('/admin/incidents/count', accessToken: token);
    return (response['open'] as num?)?.toInt() ?? 0;
  }

  /// [countsAgainstDriver] is sent only when true, and only ever matters
  /// on RESOLVED. The server records it once and ignores it afterwards,
  /// so re-saving a review can't double-count a driver.
  Future<IncidentModel> review(
      String id, {
        required String status,
        required String resolution,
        bool countsAgainstDriver = false,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.patch(
      '/admin/incidents/$id',
      body: {
        'status': status,
        'resolution': resolution,
        'countsAgainstDriver': countsAgainstDriver,
      },
      accessToken: token,
    );
    return IncidentModel.fromJson(response['incident'] as Map<String, dynamic>);
  }

  /// Takes the vehicle out of service, with this incident as the reason.
  /// Refused with a 409 while the vehicle is still ON_TRIP.
  Future<IncidentModel> flagVehicle(String id) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.post(
      '/admin/incidents/$id/flag-vehicle',
      accessToken: token,
    );
    return IncidentModel.fromJson(response['incident'] as Map<String, dynamic>);
  }
}

/// A picked photo, already in memory.
///
/// file_picker is used with `withData: true` everywhere in this app,
/// because without it `.bytes` is null on web and the upload fails
/// silently with nothing to send.
class IncidentPhoto {
  final Uint8List bytes;
  final String filename;

  const IncidentPhoto({required this.bytes, required this.filename});

  String get mimeType {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}