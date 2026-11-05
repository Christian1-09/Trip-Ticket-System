// features/incident/presentation/providers/incident_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/incident_model.dart';
import '../../data/incident_repository.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return IncidentRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Which pill is selected on the admin screen. Null means "All".
final incidentFilterProvider = StateProvider<IncidentStatus?>((ref) => null);

/// True while a review or a flag is in flight, so the screen can dim and
/// the buttons can disable — same shape as vehicleActionBusyProvider.
final incidentActionBusyProvider = StateProvider<bool>((ref) => false);

/// Every incident this user is allowed to see, already filtered.
///
/// Watches the filter, so changing a pill refetches rather than filtering
/// a stale list on the client. On a campus fleet the lists are small and
/// the server is the only thing that knows the real counts.
final incidentListProvider = FutureProvider<List<IncidentModel>>((ref) {
  final filter = ref.watch(incidentFilterProvider);
  return ref.watch(incidentRepositoryProvider).list(
    status: filter?.backendValue,
  );
});

/// Drives the badge on the Incidents nav item.
final openIncidentCountProvider = FutureProvider<int>((ref) {
  // Rebuilt whenever the list is invalidated, so filing or resolving one
  // moves the badge without a second refresh call.
  ref.watch(incidentListProvider);
  return ref.watch(incidentRepositoryProvider).countOpen();
});

/// The types the signed-in user may report. Loaded once and cached: the
/// list depends on their role, which doesn't change mid-session.
final incidentOptionsProvider = FutureProvider<IncidentOptions>((ref) {
  return ref.watch(incidentRepositoryProvider).fetchOptions();
});

/// Incidents already filed against one trip — so the driver's trip screen
/// can show "1 incident reported" instead of letting them file the same
/// breakdown three times.
final tripIncidentsProvider =
FutureProvider.family<List<IncidentModel>, String>((ref, tripRequestId) {
  return ref
      .watch(incidentRepositoryProvider)
      .list(tripRequestId: tripRequestId);
});