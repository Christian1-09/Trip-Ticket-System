// features/admin/presentation/providers/trip_ticket_log_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/trip_ticket_log_mock_data.dart';
import '../../data/models/trip_ticket_log_model.dart';

final tripTicketLogProvider = Provider<List<TripTicketLogModel>>((ref) => tripTicketLogMockData);