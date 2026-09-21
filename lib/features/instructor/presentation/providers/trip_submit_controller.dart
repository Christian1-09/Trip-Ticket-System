// features/instructor/presentation/providers/trip_submit_controller.dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;
import '../../trip_ticket/data/reference_models.dart';
import '../screens/steps/trip_request_repository.dart';

final tripRequestRepositoryProvider = Provider<TripRequestRepository>((ref) {
  return TripRequestRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

sealed class SubmitTripState {
  const SubmitTripState();
}

class SubmitTripIdle extends SubmitTripState {
  const SubmitTripIdle();
}

class SubmitTripLoading extends SubmitTripState {
  const SubmitTripLoading();
}

class SubmitTripSuccess extends SubmitTripState {
  const SubmitTripSuccess();
}

class SubmitTripError extends SubmitTripState {
  final String message;
  const SubmitTripError(this.message);
}

class TripSubmitController extends StateNotifier<SubmitTripState> {
  final TripRequestRepository _repository;

  TripSubmitController(this._repository) : super(const SubmitTripIdle());

  Future<void> submit({
    required String purpose,
    required DateTime date,
    required DateTime departureDateTime,
    required ServiceMode serviceMode,
    DateTime? returnDateTime,
    DateTime? pickupDateTime,
    required String departmentId,
    required String driverId,
    required String vehicleId,
    required List<String> passengerNames,
    required TripStopEntry destination,
    required List<TripStopEntry> additionalStops,
    required bool certifyOfficialBusiness,
    required bool certifyRecordCorrectness,
    required bool manualUrgent,
    String? urgentReason,
    Uint8List? authorizationLetterBytes,
    String? authorizationLetterFilename,
  }) async {
    state = const SubmitTripLoading();
    try {
      await _repository.submitTripRequest(
        purpose: purpose,
        date: date,
        departureDateTime: departureDateTime,
        serviceMode: serviceMode,
        returnDateTime: returnDateTime,
        pickupDateTime: pickupDateTime,
        departmentId: departmentId,
        driverId: driverId,
        vehicleId: vehicleId,
        passengerNames: passengerNames,
        destination: destination,
        additionalStops: additionalStops,
        certifyOfficialBusiness: certifyOfficialBusiness,
        certifyRecordCorrectness: certifyRecordCorrectness,
        manualUrgent: manualUrgent,
        urgentReason: urgentReason,
        authorizationLetterBytes: authorizationLetterBytes,
        authorizationLetterFilename: authorizationLetterFilename,
      );
      state = const SubmitTripSuccess();
    } on ApiException catch (e) {
      state = SubmitTripError(e.message);
    } catch (e) {
      state = const SubmitTripError('Something went wrong. Please try again.');
    }
  }

  void reset() => state = const SubmitTripIdle();
}

final tripSubmitControllerProvider =
StateNotifierProvider<TripSubmitController, SubmitTripState>((ref) {
  return TripSubmitController(ref.watch(tripRequestRepositoryProvider));
});