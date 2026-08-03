// features/admin/data/mock/driver_mock_data.dart
import '../models/driver_model.dart';

final driverMockData = [
  const DriverModel(id: 1, name: 'Christian T. Gonzaga', date: 'March 23,2026', totalTrips: 33, status: DriverStatus.offDuty),
  const DriverModel(id: 2, name: 'Christian T. Gonzaga', date: 'March 23,2026', totalTrips: 0, status: DriverStatus.onTrip),
  const DriverModel(id: 3, name: 'Christian T. Gonzaga', date: 'March 3,2026', totalTrips: 12, status: DriverStatus.available),
  const DriverModel(id: 4, name: 'Christian T. Gonzaga', date: 'March 3,2026', totalTrips: 24, status: DriverStatus.onTrip),
  const DriverModel(id: 5, name: 'Christian T. Gonzaga', date: 'March 23,2026', totalTrips: 3, status: DriverStatus.available),
];