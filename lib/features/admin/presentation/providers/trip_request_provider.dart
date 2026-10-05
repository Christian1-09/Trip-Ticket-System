// features/admin/presentation/providers/trip_request_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/admin_trip_repository.dart';
import '../../data/models/admin_trip_model.dart';

final adminTripRepositoryProvider = Provider<AdminTripRepository>((ref) {
  return AdminTripRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Pending trips straight from the backend, urgent ones first.
/// Call ref.invalidate(pendingTripsProvider) after approving or rejecting.
final pendingTripsProvider = FutureProvider<List<AdminTripModel>>((ref) {
  return ref.watch(adminTripRepositoryProvider).getPendingTrips();
});

final tripRequestSearchProvider = StateProvider<String>((ref) => '');
final tripRequestUrgencyFilterProvider = StateProvider<String>((ref) => 'All');
final tripRequestDepartmentFilterProvider =
StateProvider<String>((ref) => 'All Department');

/// The department list comes from the trips themselves, so it always
/// matches the real data instead of a hard-coded list.
final tripRequestDepartmentOptionsProvider = Provider<List<String>>((ref) {
  final trips = ref.watch(pendingTripsProvider).valueOrNull ?? [];
  final codes = trips.map((t) => t.departmentCode).toSet().toList()..sort();
  return ['All Department', ...codes];
});

/// Search + filters applied to the pending list.
final filteredPendingTripsProvider = Provider<List<AdminTripModel>>((ref) {
  final trips = ref.watch(pendingTripsProvider).valueOrNull ?? [];
  final search = ref.watch(tripRequestSearchProvider).trim().toLowerCase();
  final urgency = ref.watch(tripRequestUrgencyFilterProvider);
  final department = ref.watch(tripRequestDepartmentFilterProvider);

  return trips.where((trip) {
    if (urgency == 'Urgent' && !trip.isUrgent) return false;
    if (urgency == 'Normal' && trip.isUrgent) return false;

    if (department != 'All Department' && trip.departmentCode != department) {
      return false;
    }

    if (search.isEmpty) return true;

    final haystack = [
      trip.ticketNumber,
      trip.requester.fullName,
      trip.departmentName,
      trip.departmentCode,
      trip.driver.fullName,
      trip.destinationLabel,
      trip.purpose,
    ].join(' ').toLowerCase();

    return haystack.contains(search);
  }).toList();
});

/// Tracks an approve/reject call so the screen can show a spinner and
/// surface the backend's message (for example a 409 double-booking).
sealed class TripActionState {
  const TripActionState();
}

class TripActionIdle extends TripActionState {
  const TripActionIdle();
}

class TripActionLoading extends TripActionState {
  const TripActionLoading();
}

class TripActionSuccess extends TripActionState {
  final String message;
  const TripActionSuccess(this.message);
}

class TripActionError extends TripActionState {
  final String message;
  const TripActionError(this.message);
}