// features/admin/presentation/providers/request_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;
import '../../data/driver_request_repository.dart';
import '../../data/models/request_model.dart';

final driverRequestRepositoryProvider = Provider<DriverRequestRepository>((ref) {
  return DriverRequestRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Replaces the old mock requestListProvider — fetches real pending
/// drivers from the backend. Call ref.invalidate(requestListProvider)
/// after approve/reject to refresh the list.
final requestListProvider = FutureProvider<List<RequestModel>>((ref) {
  return ref.watch(driverRequestRepositoryProvider).listPending();
});

final requestSearchProvider = StateProvider<String>((ref) => '');

sealed class DriverActionState {
  const DriverActionState();
}

class DriverActionIdle extends DriverActionState {
  const DriverActionIdle();
}

class DriverActionLoading extends DriverActionState {
  const DriverActionLoading();
}

class DriverActionError extends DriverActionState {
  final String message;
  const DriverActionError(this.message);
}

class DriverActionController extends StateNotifier<DriverActionState> {
  final DriverRequestRepository _repository;
  final Ref _ref;

  DriverActionController(this._repository, this._ref) : super(const DriverActionIdle());

  Future<void> approve(String driverId) async {
    state = const DriverActionLoading();
    try {
      await _repository.approve(driverId);
      _ref.invalidate(requestListProvider);
      state = const DriverActionIdle();
    } catch (e) {
      state = DriverActionError('Failed to approve: $e');
    }
  }

  Future<void> reject(String driverId) async {
    state = const DriverActionLoading();
    try {
      await _repository.reject(driverId);
      _ref.invalidate(requestListProvider);
      state = const DriverActionIdle();
    } catch (e) {
      state = DriverActionError('Failed to reject: $e');
    }
  }
}

final driverActionControllerProvider =
StateNotifierProvider<DriverActionController, DriverActionState>((ref) {
  return DriverActionController(ref.watch(driverRequestRepositoryProvider), ref);
});