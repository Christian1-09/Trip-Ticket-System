// features/admin/data/vehicle_repository.dart
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

  Future<void> create({
    required String model,
    required String type,
    required String plateNumber,
    required String capacity,
    required String year,
    required String odometerCurrent,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    final fields = <String, String>{
      'model': model,
      'type': type,
      'plateNumber': plateNumber,
      'capacity': capacity,
      'year': year,
      'odometerCurrent': odometerCurrent,
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

  String _guessMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }
}