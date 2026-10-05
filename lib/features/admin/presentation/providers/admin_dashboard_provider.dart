// features/admin/presentation/providers/admin_dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/admin_dashboard_repository.dart';
import '../../data/models/dashboard_models.dart';

final adminDashboardRepositoryProvider = Provider<AdminDashboardRepository>((ref) {
  return AdminDashboardRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final adminDashboardProvider = FutureProvider<AdminDashboard>((ref) {
  return ref.watch(adminDashboardRepositoryProvider).getDashboard();
});

/// The four cards across the top. Empty while loading, so the row never
/// throws before the data lands.
final adminStatCardsProvider = Provider<List<AdminStatCardModel>>((ref) {
  return ref.watch(adminDashboardProvider).valueOrNull?.statCards ?? const [];
});

final departmentTripsProvider = Provider<List<DepartmentTripModel>>((ref) {
  return ref.watch(adminDashboardProvider).valueOrNull?.departmentTrips ?? const [];
});

final tripOverviewProvider = Provider<Map<String, int>>((ref) {
  final dashboard = ref.watch(adminDashboardProvider).valueOrNull;
  return {
    'total': dashboard?.todayTotal ?? 0,
    'pending': dashboard?.pendingToday ?? 0,
    'ongoing': dashboard?.ongoingNow ?? 0,
  };
});