// features/trip_ticket/data/reference_models.dart

/// The trips always start from base.
const String kBaseLocationName = 'Katipunan';

/// How the driver serves the trip. Must match the backend `ServiceMode` enum.
enum ServiceMode { wait, dropAndPickup }

extension ServiceModeX on ServiceMode {
  String get apiValue => this == ServiceMode.wait ? 'WAIT' : 'DROP_AND_PICKUP';

  String get label =>
      this == ServiceMode.wait ? 'Driver waits' : 'Drop off & pick up later';

  String get description => this == ServiceMode.wait
      ? 'The driver stays with the passengers for the whole trip.'
      : 'The driver drops off, returns to base, then comes back at pick-up time.';
}

class DepartmentModel {
  final String id;
  final String name;
  final String code;

  DepartmentModel({required this.id, required this.name, required this.code});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) => DepartmentModel(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String,
  );
}

/// A destination on the Admin-managed list, with its one-way travel time
/// from base. Used to work out how long the driver is on the road.
class LocationModel {
  final String id;
  final String name;
  final int travelMinutes;

  LocationModel({
    required this.id,
    required this.name,
    required this.travelMinutes,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json['id'] as String,
    name: json['name'] as String,
    travelMinutes: (json['travelMinutes'] as num).toInt(),
  );

  String get label => '$name (${travelMinutes}m away)';
}

/// One stop on the route. Either picked from the Location list
/// ([locationId] set) or typed by hand when the place is not listed yet
/// ([useCustom] true, travel time estimated by the requester).
///
/// [useCustom] is stored instead of being guessed from the address: right
/// after "Other" is chosen the address is still empty, and guessing would
/// hide the very fields the requester needs to fill in.
class TripStopEntry {
  final String? locationId;
  final String address;
  final int travelMinutes;
  final bool useCustom;

  const TripStopEntry({
    this.locationId,
    this.address = '',
    this.travelMinutes = 0,
    this.useCustom = false,
  });

  bool get isComplete =>
      (useCustom || locationId != null) &&
          address.trim().isNotEmpty &&
          travelMinutes > 0;

  TripStopEntry copyWith({
    String? locationId,
    String? address,
    int? travelMinutes,
    bool? useCustom,
    bool clearLocationId = false,
  }) {
    return TripStopEntry(
      locationId: clearLocationId ? null : (locationId ?? this.locationId),
      address: address ?? this.address,
      travelMinutes: travelMinutes ?? this.travelMinutes,
      useCustom: useCustom ?? this.useCustom,
    );
  }

  factory TripStopEntry.fromLocation(LocationModel location) => TripStopEntry(
    locationId: location.id,
    address: location.name,
    travelMinutes: location.travelMinutes,
    useCustom: false,
  );
}

class AvailableDriverModel {
  final String id;
  final String fullName;
  final String email;
  final String role;

  AvailableDriverModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AvailableDriverModel.fromJson(Map<String, dynamic> json) => AvailableDriverModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    role: json['role'] as String? ?? 'DRIVER',
  );

  bool get isHeadDriver => role == 'HEAD_DRIVER';

  String get label => isHeadDriver ? '$fullName (Head Driver)' : fullName;
}

class AvailableVehicleModel {
  final String id;
  final String model;
  final String plateNumber;

  AvailableVehicleModel({
    required this.id,
    required this.model,
    required this.plateNumber,
  });

  factory AvailableVehicleModel.fromJson(Map<String, dynamic> json) => AvailableVehicleModel(
    id: json['id'] as String,
    model: json['model'] as String,
    plateNumber: json['plateNumber'] as String,
  );

  String get label => '$model ($plateNumber)';
}

/// Builds the query string that asks the backend to hide drivers/vehicles
/// already booked for this time range. Returns an empty string while the
/// schedule is still incomplete — then every eligible option is shown.
String buildAvailabilityQuery({
  ServiceMode? serviceMode,
  DateTime? departureDateTime,
  DateTime? returnDateTime,
  DateTime? pickupDateTime,
  int travelMinutes = 0,
}) {
  if (serviceMode == null || departureDateTime == null) return '';

  final params = <String, String>{
    'serviceMode': serviceMode.apiValue,
    'departureTime': departureDateTime.toUtc().toIso8601String(),
    'travelMinutes': travelMinutes.toString(),
  };

  if (serviceMode == ServiceMode.wait) {
    if (returnDateTime == null) return '';
    params['returnTime'] = returnDateTime.toUtc().toIso8601String();
  } else {
    if (pickupDateTime == null) return '';
    params['pickupTime'] = pickupDateTime.toUtc().toIso8601String();
  }

  final query = params.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  return '?$query';
}