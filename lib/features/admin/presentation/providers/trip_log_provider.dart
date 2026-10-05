// features/admin/presentation/providers/trip_log_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/trip_log_repository.dart';

final tripLogRepositoryProvider = Provider<TripLogRepository>((ref) {
  return TripLogRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// The current filter. Changing it refetches, because the page provider
/// watches it as its family argument.
final tripLogFilterProvider =
StateProvider<TripLogFilter>((ref) => const TripLogFilter());

final tripLogPageProvider =
FutureProvider.family<TripLogPage, TripLogFilter>((ref, filter) {
  return ref.watch(tripLogRepositoryProvider).getTrips(filter);
});