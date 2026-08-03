// features/admin/data/mock/vehicle_mock_data.dart
import '../models/vehicle_model.dart';

final vehicleMockData = [
  const VehicleModel(
    plateNumber: 'JJJ 963',
    model: 'SJJ963 INNOVA',
    type: 'MPV 7 Seater Diesel',
    capacity: 7,
    odometerKm: 32500,
    year: 2022,
    trips: 23,
    status: VehicleStatus.available,
    imagePath: 'assets/images/INNOVA.jpg',
  ),
  const VehicleModel(
    plateNumber: 'JJJ 963',
    model: '100TQ HI-ACE VAN',
    type: 'MPV 8 Seater Diesel',
    capacity: 8,
    odometerKm: 32500,
    year: 2024,
    trips: 23,
    status: VehicleStatus.onTrip,
    imagePath: 'assets/images/HIACE.png',
  ),
  const VehicleModel(
    plateNumber: 'JJJ 963',
    model: 'JBA1985 FOTON',
    type: 'MPV 7 Seater Diesel',
    capacity: 7,
    odometerKm: 32900,
    year: 2019,
    trips: 23,
    status: VehicleStatus.maintenance,
    imagePath: 'assets/images/Canter.png',
  ),
];