// features/driver/presentation/providers/driver_trip_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/driver_models.dart';
import '../../data/driver_repository.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final driverProfileProvider = FutureProvider<DriverProfileSummary>((ref) {
  return ref.watch(driverRepositoryProvider).getProfile();
});

/// Awaiting an answer, accepted, or on the road — soonest first.
final driverActiveTripsProvider = FutureProvider<List<DriverTrip>>((ref) {
  return ref.watch(driverRepositoryProvider).getTrips(scope: 'active');
});

/// Completed trips — most recent first.
final driverHistoryTripsProvider = FutureProvider<List<DriverTrip>>((ref) {
  return ref.watch(driverRepositoryProvider).getTrips(scope: 'history');
});

final driverTripProvider = FutureProvider.family<DriverTrip, String>((ref, tripId) {
  return ref.watch(driverRepositoryProvider).getTrip(tripId);
});

/// Call after any accept / decline / departure / return so every list,
/// the stats and the open trip all refresh together.
void refreshDriverData(WidgetRef ref, {String? tripId}) {
  ref.invalidate(driverProfileProvider);
  ref.invalidate(driverActiveTripsProvider);
  ref.invalidate(driverHistoryTripsProvider);
  if (tripId != null) ref.invalidate(driverTripProvider(tripId));
}