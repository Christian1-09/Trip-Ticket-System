// features/admin/presentation/providers/vehicle_provider.dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;
import '../../data/vehicle_repository.dart';
import '../../data/models/vehicle_model.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final vehicleListProvider = FutureProvider<List<VehicleModel>>((ref) {
  return ref.watch(vehicleRepositoryProvider).listAll();
});

/// Drivers the admin can assign. Loaded once and cached; the add and edit
/// dialogs share it, so opening either doesn't refetch.
final assignableDriversProvider = FutureProvider<List<VehicleDriver>>((ref) {
  return ref.watch(vehicleRepositoryProvider).listAssignableDrivers();
});

final vehicleFilterProvider = StateProvider<String>((ref) => 'All Vehicles');

/// True while an edit, status change or delete is running, so the screen
/// can dim and the card buttons can disable.
final vehicleActionBusyProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Add
// ─────────────────────────────────────────────────────────────────────────────

sealed class AddVehicleState {
  const AddVehicleState();
}

class AddVehicleIdle extends AddVehicleState {
  const AddVehicleIdle();
}

class AddVehicleLoading extends AddVehicleState {
  const AddVehicleLoading();
}

class AddVehicleSuccess extends AddVehicleState {
  const AddVehicleSuccess();
}

class AddVehicleError extends AddVehicleState {
  final String message;
  const AddVehicleError(this.message);
}

class AddVehicleController extends StateNotifier<AddVehicleState> {
  final VehicleRepository _repository;
  final Ref _ref;

  AddVehicleController(this._repository, this._ref) : super(const AddVehicleIdle());

  Future<void> create({
    required String model,
    required String type,
    required String plateNumber,
    required String capacity,
    required String year,
    required String odometerCurrent,
    Uint8List? imageBytes,
    String? imageFilename,
    List<VehicleAssignmentInput> assignments = const [],
  }) async {
    state = const AddVehicleLoading();
    try {
      await _repository.create(
        model: model,
        type: type,
        plateNumber: plateNumber,
        capacity: capacity,
        year: year,
        odometerCurrent: odometerCurrent,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
        assignments: assignments,
      );
      _ref.invalidate(vehicleListProvider);
      state = const AddVehicleSuccess();
    } catch (e) {
      state = AddVehicleError('$e');
    }
  }

  void reset() => state = const AddVehicleIdle();
}

final addVehicleControllerProvider =
StateNotifierProvider<AddVehicleController, AddVehicleState>((ref) {
  return AddVehicleController(ref.watch(vehicleRepositoryProvider), ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// Edit
// ─────────────────────────────────────────────────────────────────────────────

sealed class EditVehicleState {
  const EditVehicleState();
}

class EditVehicleIdle extends EditVehicleState {
  const EditVehicleIdle();
}

class EditVehicleLoading extends EditVehicleState {
  const EditVehicleLoading();
}

class EditVehicleSuccess extends EditVehicleState {
  const EditVehicleSuccess();
}

class EditVehicleError extends EditVehicleState {
  final String message;
  const EditVehicleError(this.message);
}

class EditVehicleController extends StateNotifier<EditVehicleState> {
  final VehicleRepository _repository;
  final Ref _ref;

  EditVehicleController(this._repository, this._ref) : super(const EditVehicleIdle());

  /// [assignments] is the complete desired driver list. Pass null to leave
  /// the current assignment untouched; pass an empty list to clear it.
  Future<void> save(
      String vehicleId, {
        required String model,
        required String type,
        required String plateNumber,
        required String capacity,
        required String year,
        String? fuelType,
        required String odometerCurrent,
        List<VehicleAssignmentInput>? assignments,
      }) async {
    state = const EditVehicleLoading();
    try {
      await _repository.update(
        vehicleId,
        model: model,
        type: type,
        plateNumber: plateNumber,
        capacity: capacity,
        year: year,
        fuelType: fuelType,
        odometerCurrent: odometerCurrent,
      );

      // Two calls, because the details PATCH takes JSON while assignments
      // have their own endpoint. Details go first: if the driver call then
      // fails, the admin sees the error with the details already saved and
      // can retry just the drivers, rather than losing both.
      if (assignments != null) {
        await _repository.setDrivers(vehicleId, assignments);
      }

      _ref.invalidate(vehicleListProvider);
      state = const EditVehicleSuccess();
    } catch (e) {
      // The list is refreshed even on failure, since the details update may
      // well have succeeded before the driver call threw.
      _ref.invalidate(vehicleListProvider);
      state = EditVehicleError('$e');
    }
  }

  void reset() => state = const EditVehicleIdle();
}

final editVehicleControllerProvider =
StateNotifierProvider<EditVehicleController, EditVehicleState>((ref) {
  return EditVehicleController(ref.watch(vehicleRepositoryProvider), ref);
});