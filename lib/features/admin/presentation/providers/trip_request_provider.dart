// features/admin/presentation/providers/trip_request_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/trip_request_mock_data.dart';
import '../../data/models/trip_request_model.dart';


final tripRequestListProvider = Provider<List<TripRequestModel>>((ref) {
  return tripRequestMockData;
});

final tripRequestSearchProvider = StateProvider<String>((ref) => '');
final tripRequestStatusFilterProvider = StateProvider<String>((ref) => 'Status');
final tripRequestDepartmentFilterProvider = StateProvider<String>((ref) => 'All Department');