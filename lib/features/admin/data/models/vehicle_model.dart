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
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
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
    );
  }
}