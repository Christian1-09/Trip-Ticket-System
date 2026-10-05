// features/instructor/presentation/providers/requester_trip_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/requester_trip_models.dart';
import '../../data/requester_trip_repository.dart';

final requesterTripRepositoryProvider = Provider<RequesterTripRepository>((ref) {
  return RequesterTripRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Every trip this requester has submitted, newest first.
final myTripsProvider = FutureProvider<List<RequesterTrip>>((ref) {
  return ref.watch(requesterTripRepositoryProvider).getMyTrips();
});

final myTripProvider = FutureProvider.family<RequesterTrip, String>((ref, tripId) {
  return ref.watch(requesterTripRepositoryProvider).getTrip(tripId);
});

/// Trips still moving through the system — what the requester is waiting on.
final myActiveTripsProvider = Provider<List<RequesterTrip>>((ref) {
  final trips = ref.watch(myTripsProvider).valueOrNull ?? [];
  return trips
      .where((t) => t.status != AdminTripStatus.completed &&
      t.status != AdminTripStatus.rejected)
      .toList();
});

/// Counts for the stats row on the requester's home screen. All derived
/// from the list, never stored.
final myTripStatsProvider = Provider<({int total, int pending, int onTrip, int completed})>((ref) {
  final trips = ref.watch(myTripsProvider).valueOrNull ?? [];
  return (
  total: trips.length,
  pending: trips
      .where((t) =>
  t.status == AdminTripStatus.pending ||
      t.status == AdminTripStatus.adminApproved ||
      t.status == AdminTripStatus.headDriverApproved ||
      t.status == AdminTripStatus.driverDeclined)
      .length,
  onTrip: trips.where((t) => t.status == AdminTripStatus.ongoing).length,
  completed: trips.where((t) => t.status == AdminTripStatus.completed).length,
  );
});

void refreshMyTrips(WidgetRef ref, {String? tripId}) {
  ref.invalidate(myTripsProvider);
  if (tripId != null) ref.invalidate(myTripProvider(tripId));
}