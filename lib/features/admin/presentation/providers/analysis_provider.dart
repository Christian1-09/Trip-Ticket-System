// features/admin/presentation/providers/analysis_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dashboard_models.dart';
import 'admin_dashboard_provider.dart';

/// How many months the Analysis charts cover. Changing it refetches.
final analysisMonthsProvider = StateProvider<int>((ref) => 6);

final adminAnalyticsProvider = FutureProvider<AdminAnalytics>((ref) {
  final months = ref.watch(analysisMonthsProvider);
  return ref.watch(adminDashboardRepositoryProvider).getAnalytics(months: months);
});

final monthlyTripProvider = Provider<List<MonthlyTripModel>>((ref) {
  return ref.watch(adminAnalyticsProvider).valueOrNull?.tripsByMonth ?? const [];
});