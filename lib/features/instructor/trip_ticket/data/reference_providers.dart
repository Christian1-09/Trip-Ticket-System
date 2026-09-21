// features/trip_ticket/data/reference_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;
import 'reference_models.dart';
import 'reference_repository.dart';

final referenceRepositoryProvider = Provider<ReferenceRepository>((ref) {
  return ReferenceRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final departmentsProvider = FutureProvider<List<DepartmentModel>>((ref) {
  return ref.watch(referenceRepositoryProvider).getDepartments();
});

final locationsProvider = FutureProvider<List<LocationModel>>((ref) {
  return ref.watch(referenceRepositoryProvider).getLocations();
});

/// The family argument is the availability query string from
/// buildAvailabilityQuery(). An empty string means "no schedule chosen yet",
/// so every eligible driver is returned. Riverpod caches per query, so
/// changing the time refetches automatically.
final availableDriversProvider =
FutureProvider.family<List<AvailableDriverModel>, String>((ref, query) {
  return ref.watch(referenceRepositoryProvider).getAvailableDrivers(query);
});

final availableVehiclesProvider =
FutureProvider.family<List<AvailableVehicleModel>, String>((ref, query) {
  return ref.watch(referenceRepositoryProvider).getAvailableVehicles(query);
});