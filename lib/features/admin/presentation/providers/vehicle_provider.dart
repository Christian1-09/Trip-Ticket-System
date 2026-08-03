// features/admin/presentation/providers/vehicle_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/vehicle_mock_data.dart';
import '../../data/models/vehicle_model.dart';

final vehicleListProvider = Provider<List<VehicleModel>>((ref) => vehicleMockData);
final vehicleFilterProvider = StateProvider<String>((ref) => 'All Vehicles');