// features/head_driver/presentation/providers/head_driver_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/head_driver_models.dart';
import '../../data/head_driver_repository.dart';

final headDriverRepositoryProvider = Provider<HeadDriverRepository>((ref) {
  return HeadDriverRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// "Needs your approval" — call ref.invalidate(...) after approve/reject.
final hdPendingTripsProvider = FutureProvider<List<HeadDriverTrip>>((ref) {
  return ref.watch(headDriverRepositoryProvider).getPendingApprovals();
});

/// "Needs a new driver" — call ref.invalidate(...) after reassigning.
final hdDeclinedTripsProvider = FutureProvider<List<HeadDriverTrip>>((ref) {
  return ref.watch(headDriverRepositoryProvider).getDeclinedTrips();
});

/// Free drivers for one declined trip.
final hdReplacementDriversProvider =
FutureProvider.family<List<ReplacementDriver>, String>((ref, tripId) {
  return ref.watch(headDriverRepositoryProvider).getReplacementDrivers(tripId);
});

/// Total items waiting for the Head Driver — drives the tab badge.
final hdWaitingCountProvider = Provider<int>((ref) {
  final pending = ref.watch(hdPendingTripsProvider).value?.length ?? 0;
  final declined = ref.watch(hdDeclinedTripsProvider).value?.length ?? 0;
  return pending + declined;
});