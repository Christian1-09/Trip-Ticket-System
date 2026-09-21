// features/instructor/presentation/screens/steps/trip_request_repository.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';

import '../../../trip_ticket/data/reference_models.dart';

class TripRequestRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  TripRequestRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Submits a trip ticket. [departmentId], [driverId] and [vehicleId] must be
  /// real backend IDs from the dropdowns — not display names.
  ///
  /// IMPORTANT: every DateTime is sent with .toUtc() so the ISO string ends
  /// with "Z". A local DateTime's toIso8601String() has no timezone marker,
  /// and Node would read it as UTC — storing 3:30 PM Manila as 11:30 PM.
  Future<void> submitTripRequest({
    required String purpose,
    required DateTime date,
    required DateTime departureDateTime,
    required ServiceMode serviceMode,
    DateTime? returnDateTime, // required when serviceMode = wait
    DateTime? pickupDateTime, // required when serviceMode = dropAndPickup
    required String departmentId,
    required String driverId,
    required String vehicleId,
    required List<String> passengerNames,
    required TripStopEntry destination,
    required List<TripStopEntry> additionalStops,
    required bool certifyOfficialBusiness,
    required bool certifyRecordCorrectness,
    required bool manualUrgent,
    String? urgentReason,
    Uint8List? authorizationLetterBytes,
    String? authorizationLetterFilename,
  }) async {
    final token = await _tokenStorage.getAccessToken();

    // Ordered route: base -> extra stops -> destination.
    final stops = <Map<String, dynamic>>[
      {
        'type': 'ORIGIN',
        'address': kBaseLocationName,
        'order': 0,
        'travelMinutes': 0,
      },
      for (var i = 0; i < additionalStops.length; i++)
        {
          'type': 'STOP',
          'address': additionalStops[i].address,
          'order': i + 1,
          if (additionalStops[i].locationId != null)
            'locationId': additionalStops[i].locationId,
          'travelMinutes': additionalStops[i].travelMinutes,
        },
      {
        'type': 'DESTINATION',
        'address': destination.address,
        'order': additionalStops.length + 1,
        if (destination.locationId != null) 'locationId': destination.locationId,
        'travelMinutes': destination.travelMinutes,
      },
    ];

    final fields = <String, String>{
      'purpose': purpose,
      'date': date.toUtc().toIso8601String(),
      'departureTime': departureDateTime.toUtc().toIso8601String(),
      'serviceMode': serviceMode.apiValue,
      if (returnDateTime != null) 'returnTime': returnDateTime.toUtc().toIso8601String(),
      if (pickupDateTime != null) 'pickupTime': pickupDateTime.toUtc().toIso8601String(),
      'departmentId': departmentId,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'passengerNames': jsonEncode(passengerNames),
      'stops': jsonEncode(stops),
      'certifyOfficialBusiness': certifyOfficialBusiness.toString(),
      'certifyRecordCorrectness': certifyRecordCorrectness.toString(),
      'manualUrgent': manualUrgent.toString(),
      if (urgentReason != null) 'urgentReason': urgentReason,
    };

    final files = <MultipartFilePart>[
      if (authorizationLetterBytes != null && authorizationLetterFilename != null)
        MultipartFilePart(
          fieldName: 'authorizationLetter',
          bytes: authorizationLetterBytes,
          filename: authorizationLetterFilename,
          mimeType: _guessMimeType(authorizationLetterFilename),
        ),
    ];

    await _apiClient.postMultipart(
      '/trips',
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
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }
}