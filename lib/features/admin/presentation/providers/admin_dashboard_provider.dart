// presentation/providers/admin_dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/admin_mock_data.dart';
import '../../data/models/stat_card_model.dart';
import '../../data/models/department_trip_model.dart';

final adminStatCardsProvider = Provider<List<AdminStatCardModel>>((ref) {
  return adminStatCards; // later: ref.read(adminRepositoryProvider).fetchStats()
});

final departmentTripsProvider = Provider<List<DepartmentTripModel>>((ref) {
  return departmentTripData;
});

final tripOverviewProvider = Provider<Map<String, int>>((ref) {
  return {'total': 10, 'pending': 9, 'ongoing': 3};
});