// features/admin/data/models/vehicle_model.dart

enum VehicleStatus { active, onTrip, maintenance, inactive }

extension VehicleStatusX on VehicleStatus {
  static VehicleStatus fromBackend(String value) {
    switch (value) {
      case 'ACTIVE':
        return VehicleStatus.active;
      case 'ON_TRIP':
        return VehicleStatus.onTrip;
      case 'MAINTENANCE':
        return VehicleStatus.maintenance;
      case 'INACTIVE':
        return VehicleStatus.inactive;
      default:
        return VehicleStatus.active;
    }
  }

  String get filterLabel {
    switch (this) {
      case VehicleStatus.active:
        return 'Available';
      case VehicleStatus.onTrip:
        return 'On Trip';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.inactive:
        return 'Inactive';
    }
  }
}

/// A driver assigned to a vehicle, and also one that *could* be assigned —
/// the picker and the assignment list show the same fields, so one class
/// serves both. `isPrimary` is false for an unassigned candidate.
class VehicleDriver {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? driverCode;
  final bool isPrimary;

  const VehicleDriver({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.driverCode,
    this.isPrimary = false,
  });

  factory VehicleDriver.fromJson(Map<String, dynamic> json) {
    return VehicleDriver(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      driverCode: json['driverCode'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// What gets sent back when saving. Kept separate from [VehicleDriver] so
/// the request body carries only what the server needs.
class VehicleAssignmentInput {
  final String driverId;
  final bool isPrimary;

  const VehicleAssignmentInput({required this.driverId, this.isPrimary = false});

  Map<String, dynamic> toJson() => {
    'driverId': driverId,
    'isPrimary': isPrimary,
  };
}

class VehicleModel {
  final String id;
  final String plateNumber;
  final String model;
  final String type;
  final int capacity;
  final int? odometerCurrent;
  final int? year;
  final int trips; // computed by the backend, not stored
  final VehicleStatus status;
  final String? imageUrl;

  /// Assigned drivers, primary first. A vehicle may have none.
  final List<VehicleDriver> drivers;

  const VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.type,
    required this.capacity,
    required this.trips,
    required this.status,
    this.odometerCurrent,
    this.year,
    this.imageUrl,
    this.drivers = const [],
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final rawDrivers = json['drivers'] as List<dynamic>? ?? const [];

    return VehicleModel(
      id: json['id'] as String,
      plateNumber: json['plateNumber'] as String,
      model: json['model'] as String,
      type: json['type'] as String,
      capacity: json['capacity'] as int,
      odometerCurrent: json['odometerCurrent'] as int?,
      year: json['year'] as int?,
      trips: json['trips'] as int? ?? 0,
      status: VehicleStatusX.fromBackend(json['status'] as String),
      imageUrl: json['imageUrl'] as String?,
      drivers: rawDrivers
          .map((e) => VehicleDriver.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The backend orders primary first, but this doesn't rely on that.
  VehicleDriver? get primaryDriver {
    for (final driver in drivers) {
      if (driver.isPrimary) return driver;
    }
    return null;
  }

  String get driversLabel {
    if (drivers.isEmpty) return 'No driver assigned';
    if (drivers.length == 1) return drivers.first.fullName;
    final primary = primaryDriver ?? drivers.first;
    return '${primary.fullName} +${drivers.length - 1}';
  }

  /// Turns the current assignment back into the shape the edit dialog
  /// starts from.
  List<VehicleAssignmentInput> toAssignmentInputs() => drivers
      .map((d) => VehicleAssignmentInput(driverId: d.id, isPrimary: d.isPrimary))
      .toList();
}