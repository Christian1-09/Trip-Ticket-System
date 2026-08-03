// features/admin/presentation/providers/driver_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/driver_mock_data.dart';
import '../../data/models/driver_model.dart';

final driverListProvider = Provider<List<DriverModel>>((ref) => driverMockData);