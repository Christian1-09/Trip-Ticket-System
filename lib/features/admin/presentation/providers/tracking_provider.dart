// features/admin/presentation/providers/tracking_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/models/tracking_model.dart';
import '../../data/tracking_repository.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// How often the open map asks for a newer position.
///
/// Matched to the firmware: a device on a trip pings every 10 seconds
/// (`nextPingSeconds` in the ping response), so polling faster would just
/// fetch the same fix twice.
const _pollInterval = Duration(seconds: 10);

/// One vehicle's live position plus the track of its current trip.
///
/// `autoDispose` is what stops the polling: close the dialog, the last
/// listener goes, the provider is disposed and `onDispose` kills the timer.
/// Nothing keeps requesting in the background.
///
/// The timer calls `invalidateSelf` rather than the dialog running its own
/// `Timer.periodic`. That keeps the refresh with the data instead of the
/// widget, and Riverpod holds the previous value through the reload — so
/// the map never blanks to a spinner between fixes. Read it with
/// `.valueOrNull`, never `.value`.
final vehicleTrackProvider = FutureProvider.autoDispose
    .family<VehicleTrackView, String>((ref, vehicleId) async {
  final repository = ref.watch(trackingRepositoryProvider);

  // Schedule the next poll before awaiting anything, so a slow or failing
  // request doesn't stop the clock. A dead backend retries every 10s and
  // recovers on its own when it comes back.
  final timer = Timer(_pollInterval, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  final vehicles = await repository.listLive();

  LiveVehicle? live;
  for (final vehicle in vehicles) {
    if (vehicle.id == vehicleId) {
      live = vehicle;
      break;
    }
  }

  // A parked vehicle has no trip, so there's no track to draw — just its
  // last known position.
  final tripId = live?.trip?.id;
  if (tripId == null) {
    return VehicleTrackView(live: live);
  }

  final track = await repository.getTripTrack(tripId);
  return VehicleTrackView(live: live, track: track);
});

/// Every tracked vehicle at once. Not used by the card dialog, but this is
/// what a fleet-wide "Live Map" tab would watch.
final liveFleetProvider =
FutureProvider.autoDispose<List<LiveVehicle>>((ref) async {
  final timer = Timer(_pollInterval, ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  return ref.watch(trackingRepositoryProvider).listLive();
});