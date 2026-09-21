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

final vehicleFilterProvider = StateProvider<String>((ref) => 'All Vehicles');

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