// features/admin/presentation/providers/analysis_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/monthly_trip_mock_data.dart';
import '../../data/models/monthly_trip_model.dart';

final monthlyTripProvider = Provider<List<MonthlyTripModel>>((ref) => monthlyTripMockData);