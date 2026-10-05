// features/instructor/trip_ticket/data/fleet_models.dart

/// Mirrors the backend `DriverStatus` enum.
enum DriverDirectoryStatus { available, onTrip, offDuty }

extension DriverDirectoryStatusX on DriverDirectoryStatus {
  static DriverDirectoryStatus fromApi(String? value) {
    switch (value) {
      case 'AVAILABLE':
        return DriverDirectoryStatus.available;
      case 'ON_TRIP':
        return DriverDirectoryStatus.onTrip;
      case 'OFF_DUTY':
      default:
      // Unknown values fall back to off duty rather than available, so a
      // future enum value never invites a booking that would be rejected.
        return DriverDirectoryStatus.offDuty;
    }
  }

  String get label {
    switch (this) {
      case DriverDirectoryStatus.available:
        return 'Available';
      case DriverDirectoryStatus.onTrip:
        return 'On trip';
      case DriverDirectoryStatus.offDuty:
        return 'Off duty';
    }
  }
}

/// Mirrors the backend `VehicleStatus` enum.
enum VehicleDirectoryStatus { active, onTrip, maintenance, inactive }

extension VehicleDirectoryStatusX on VehicleDirectoryStatus {
  static VehicleDirectoryStatus fromApi(String? value) {
    switch (value) {
      case 'ACTIVE':
        return VehicleDirectoryStatus.active;
      case 'ON_TRIP':
        return VehicleDirectoryStatus.onTrip;
      case 'MAINTENANCE':
        return VehicleDirectoryStatus.maintenance;
      case 'INACTIVE':
      default:
        return VehicleDirectoryStatus.inactive;
    }
  }

  String get label {
    switch (this) {
      case VehicleDirectoryStatus.active:
        return 'Available';
      case VehicleDirectoryStatus.onTrip:
        return 'On trip';
      case VehicleDirectoryStatus.maintenance:
        return 'Maintenance';
      case VehicleDirectoryStatus.inactive:
        return 'Not in service';
    }
  }
}

/// One driver as shown on the requester's Vehicles tab.
///
/// Distinct from [AvailableDriverModel] in reference_models.dart on purpose:
/// that one is a dropdown option filtered by schedule, this one is the whole
/// roster with the numbers a requester wants before choosing.
class DriverDirectoryModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final String? driverCode;
  final DriverDirectoryStatus status;
  final int completedTrips;

  /// Null when nobody has rated this driver yet — deliberately not 0, which
  /// would render as an empty star row and read as a one-star driver.
  final double? averageRating;
  final int ratingCount;

  const DriverDirectoryModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.status,
    required this.completedTrips,
    required this.ratingCount,
    this.avatarUrl,
    this.driverCode,
    this.averageRating,
  });

  factory DriverDirectoryModel.fromJson(Map<String, dynamic> json) {
    return DriverDirectoryModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'DRIVER',
      driverCode: json['driverCode'] as String?,
      status: DriverDirectoryStatusX.fromApi(json['status'] as String?),
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isHeadDriver => role == 'HEAD_DRIVER';

  bool get hasRating => averageRating != null && ratingCount > 0;

  /// "4.5" — one decimal is enough; "4.47" implies a precision 8 ratings
  /// can't support.
  String get ratingLabel =>
      hasRating ? averageRating!.toStringAsFixed(1) : '—';

  String get ratingCountLabel {
    if (!hasRating) return 'No ratings yet';
    return ratingCount == 1 ? '1 rating' : '$ratingCount ratings';
  }

  String get tripsLabel =>
      completedTrips == 1 ? '1 completed trip' : '$completedTrips completed trips';

  /// Fallback for the avatar when the driver has never uploaded a photo.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// One vehicle in the fleet strip at the top of the Vehicles tab.
class VehicleDirectoryModel {
  final String id;
  final String model;
  final String plateNumber;
  final String type;
  final int capacity;
  final int? year;
  final String? fuelType;
  final String? imageUrl;
  final VehicleDirectoryStatus status;

  const VehicleDirectoryModel({
    required this.id,
    required this.model,
    required this.plateNumber,
    required this.type,
    required this.capacity,
    required this.status,
    this.year,
    this.fuelType,
    this.imageUrl,
  });

  factory VehicleDirectoryModel.fromJson(Map<String, dynamic> json) {
    return VehicleDirectoryModel(
      id: json['id'] as String,
      model: json['model'] as String,
      plateNumber: json['plateNumber'] as String,
      type: json['type'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt(),
      fuelType: json['fuelType'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: VehicleDirectoryStatusX.fromApi(json['status'] as String?),
    );
  }

  String get capacityLabel =>
      capacity == 1 ? '1 seat' : '$capacity seats';
}

/// The counts shown in the header strip. Computed on the client from the
/// lists that are already loaded — no extra request.
class FleetSummary {
  final int totalDrivers;
  final int availableDrivers;
  final int driversOnTrip;
  final int totalVehicles;
  final int availableVehicles;

  const FleetSummary({
    required this.totalDrivers,
    required this.availableDrivers,
    required this.driversOnTrip,
    required this.totalVehicles,
    required this.availableVehicles,
  });

  static const empty = FleetSummary(
    totalDrivers: 0,
    availableDrivers: 0,
    driversOnTrip: 0,
    totalVehicles: 0,
    availableVehicles: 0,
  );

  factory FleetSummary.from({
    required List<DriverDirectoryModel> drivers,
    required List<VehicleDirectoryModel> vehicles,
  }) {
    return FleetSummary(
      totalDrivers: drivers.length,
      availableDrivers: drivers
          .where((d) => d.status == DriverDirectoryStatus.available)
          .length,
      driversOnTrip:
      drivers.where((d) => d.status == DriverDirectoryStatus.onTrip).length,
      totalVehicles: vehicles.length,
      availableVehicles: vehicles
          .where((v) => v.status == VehicleDirectoryStatus.active)
          .length,
    );
  }
}