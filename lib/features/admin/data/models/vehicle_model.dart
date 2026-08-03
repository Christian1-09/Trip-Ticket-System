// features/admin/data/models/vehicle_model.dart
enum VehicleStatus { available, onTrip, maintenance }

class VehicleModel {
  final String plateNumber;
  final String model;
  final String type;
  final int capacity;
  final int odometerKm;
  final int year;
  final int trips;
  final VehicleStatus status;
  final String imagePath;

  const VehicleModel({
    required this.plateNumber,
    required this.model,
    required this.type,
    required this.capacity,
    required this.odometerKm,
    required this.year,
    required this.trips,
    required this.status,
    required this.imagePath,
  });
}