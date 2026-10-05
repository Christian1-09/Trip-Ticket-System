// features/instructor/presentation/providers/fleet_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/driver_detail_model.dart';
import '../../trip_ticket/data/fleet_models.dart';
import '../../trip_ticket/data/fleet_repository.dart';

const int kRecommendedVehicleCount = 6;

final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  return FleetRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final driverDirectoryProvider =
FutureProvider<List<DriverDirectoryModel>>((ref) {
  return ref.watch(fleetRepositoryProvider).getDriverDirectory();
});
/// One driver's full record, keyed by id.
///
/// `.family` caches per driver, so going back and reopening the same driver
/// doesn't refetch. `.autoDispose` clears it once the screen is closed —
/// without that, every driver a requester ever opened would stay in memory
/// for the session.
final driverDetailProvider =
FutureProvider.autoDispose.family<DriverDetailModel, String>((ref, driverId) {
  return ref.watch(fleetRepositoryProvider).getDriverDetail(driverId);
});


final vehicleDirectoryProvider =
FutureProvider<List<VehicleDirectoryModel>>((ref) {
  return ref.watch(fleetRepositoryProvider).getVehicleDirectory();
});

/// Header counts, derived from the two lists already in memory.
///
/// `.valueOrNull` rather than `.value`: `.value` RE-THROWS when the provider
/// is in an error state, which turns one failed request into a full red
/// screen instead of an error message inside the section. That bug cost us
/// time in head_driver_providers and driver_provider — don't reintroduce it.
final fleetSummaryProvider = Provider<FleetSummary>((ref) {
  final drivers = ref.watch(driverDirectoryProvider).valueOrNull;
  final vehicles = ref.watch(vehicleDirectoryProvider).valueOrNull;

  if (drivers == null && vehicles == null) return FleetSummary.empty;

  return FleetSummary.from(
    drivers: drivers ?? const [],
    vehicles: vehicles ?? const [],
  );
});

/// Pull-to-refresh on the Vehicles tab.
void refreshFleet(WidgetRef ref) {
  ref.invalidate(driverDirectoryProvider);
  ref.invalidate(vehicleDirectoryProvider);
}
/// How many vehicles the home carousel shows before "See all".

/// Sort rank: available first, then on-trip, then maintenance.
int _statusRank(VehicleDirectoryStatus status) {
  switch (status) {
    case VehicleDirectoryStatus.active:
      return 0;
    case VehicleDirectoryStatus.onTrip:
      return 1;
    case VehicleDirectoryStatus.maintenance:
      return 2;
    case VehicleDirectoryStatus.inactive:
      return 3;
  }
}

/// "Recommended" = what a requester is most likely to be able to book:
/// available vehicles first, and within each group the roomiest first,
/// since a bigger vehicle covers more trips than a smaller one.
///
/// Derived from the list already in memory — no extra request, and it
/// re-sorts automatically when the directory refreshes.
final recommendedVehiclesProvider =
Provider<List<VehicleDirectoryModel>>((ref) {
  // .valueOrNull, not .value: .value re-throws while the directory is
  // loading or errored, which would take the whole home screen down over
  // one failed request.
  final vehicles = ref.watch(vehicleDirectoryProvider).valueOrNull;
  if (vehicles == null || vehicles.isEmpty) return const [];

  // Sort a copy — sorting the provider's own list in place would mutate
  // what the Vehicles tab is rendering.
  final sorted = [...vehicles]..sort((a, b) {
    final byStatus = _statusRank(a.status).compareTo(_statusRank(b.status));
    if (byStatus != 0) return byStatus;
    return b.capacity.compareTo(a.capacity);
  });

  return sorted.take(kRecommendedVehicleCount).toList();
});