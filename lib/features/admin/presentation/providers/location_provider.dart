// features/admin/presentation/providers/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/location_repository.dart';
import '../../data/models/location_model.dart';

final adminLocationRepositoryProvider =
Provider<AdminLocationRepository>((ref) {
  return AdminLocationRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// '' (all), 'active' or 'inactive'.
final locationFilterProvider = StateProvider<String>((ref) => '');

final adminLocationListProvider =
FutureProvider<List<AdminLocationModel>>((ref) {
  final status = ref.watch(locationFilterProvider);
  return ref.watch(adminLocationRepositoryProvider).listAll(status: status);
});

/// True while a save, toggle or delete is in flight, so the screen can dim
/// and the menus can disable.
final locationBusyProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Save (create + edit share one controller — the only difference is whether
// an id is passed)
// ─────────────────────────────────────────────────────────────────────────────

sealed class SaveLocationState {
  const SaveLocationState();
}

class SaveLocationIdle extends SaveLocationState {
  const SaveLocationIdle();
}

class SaveLocationLoading extends SaveLocationState {
  const SaveLocationLoading();
}

class SaveLocationSuccess extends SaveLocationState {
  const SaveLocationSuccess();
}

class SaveLocationError extends SaveLocationState {
  final String message;
  const SaveLocationError(this.message);
}

class SaveLocationController extends StateNotifier<SaveLocationState> {
  final AdminLocationRepository _repository;
  final Ref _ref;

  SaveLocationController(this._repository, this._ref)
      : super(const SaveLocationIdle());

  /// [id] null creates, non-null edits.
  Future<void> save({
    String? id,
    required String name,
    required int travelMinutes,
  }) async {
    state = const SaveLocationLoading();
    try {
      if (id == null) {
        await _repository.create(name: name, travelMinutes: travelMinutes);
      } else {
        await _repository.update(id, name: name, travelMinutes: travelMinutes);
      }
      _ref.invalidate(adminLocationListProvider);
      state = const SaveLocationSuccess();
    } catch (e) {
      state = SaveLocationError('$e');
    }
  }

  void reset() => state = const SaveLocationIdle();
}

final saveLocationControllerProvider =
StateNotifierProvider<SaveLocationController, SaveLocationState>((ref) {
  return SaveLocationController(
      ref.watch(adminLocationRepositoryProvider), ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// Row actions
// ─────────────────────────────────────────────────────────────────────────────

/// Returns null on success, or the error message to show.
///
/// A plain return value rather than a state class: these actions have no UI
/// of their own, so the caller just needs to know whether to show a snackbar.
Future<String?> toggleLocationActive(
    WidgetRef ref,
    AdminLocationModel location,
    ) async {
  ref.read(locationBusyProvider.notifier).state = true;
  try {
    await ref
        .read(adminLocationRepositoryProvider)
        .update(location.id, isActive: !location.isActive);
    ref.invalidate(adminLocationListProvider);
    return null;
  } catch (e) {
    return '$e';
  } finally {
    ref.read(locationBusyProvider.notifier).state = false;
  }
}

Future<String?> deleteLocation(WidgetRef ref, String id) async {
  ref.read(locationBusyProvider.notifier).state = true;
  try {
    await ref.read(adminLocationRepositoryProvider).delete(id);
    ref.invalidate(adminLocationListProvider);
    return null;
  } catch (e) {
    return '$e';
  } finally {
    ref.read(locationBusyProvider.notifier).state = false;
  }
}