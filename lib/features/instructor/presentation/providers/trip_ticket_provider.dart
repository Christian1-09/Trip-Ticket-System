// features/instructor/presentation/providers/trip_ticket_provider.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../trip_ticket/data/reference_models.dart';


/// Marker for "this argument was not passed", so copyWith can tell the
/// difference between "keep the old value" and "set it to null".
/// Without this, a removed file or a cleared time could never be cleared.
const Object _unset = Object();

class TripTicketFormData {
  final PlatformFile? uploadedFile;
  final String purpose;
  final DateTime? date;

  /// Display strings like "3:30 PM" (from TimeOfDay.format), parsed back
  /// into a real DateTime just before submitting.
  final String? departureTime;
  final String? returnTime; // used when serviceMode = wait
  final String? pickupTime; // used when serviceMode = dropAndPickup
  final ServiceMode serviceMode;

  final String? department;
  final String? driver;
  final String? vehicle;

  final List<String> passengerNames;

  /// The origin is always base (Katipunan), so it is not editable.
  final TripStopEntry? destination;
  final List<TripStopEntry> additionalStops;

  final bool certifyOfficialBusiness;
  final bool certifyRecordCorrectness;

  /// Urgent is now chosen on the Upload step: either upload an
  /// authorization letter, or mark the trip urgent and give a reason.
  final bool manualUrgent;
  final String? urgentReason;

  const TripTicketFormData({
    this.uploadedFile,
    this.purpose = '',
    this.date,
    this.departureTime,
    this.returnTime,
    this.pickupTime,
    this.serviceMode = ServiceMode.wait,
    this.department,
    this.driver,
    this.vehicle,
    this.passengerNames = const [],
    this.destination,
    this.additionalStops = const [],
    this.certifyOfficialBusiness = false,
    this.certifyRecordCorrectness = false,
    this.manualUrgent = false,
    this.urgentReason,
  });

  /// True when the Upload step's rule is satisfied.
  bool get uploadStepComplete =>
      uploadedFile != null || (manualUrgent && (urgentReason ?? '').trim().isNotEmpty);

  /// The farthest stop decides how long the driver is on the road.
  int get maxTravelMinutes {
    var max = destination?.travelMinutes ?? 0;
    for (final stop in additionalStops) {
      if (stop.travelMinutes > max) max = stop.travelMinutes;
    }
    return max;
  }

  TripTicketFormData copyWith({
    Object? uploadedFile = _unset,
    String? purpose,
    Object? date = _unset,
    Object? departureTime = _unset,
    Object? returnTime = _unset,
    Object? pickupTime = _unset,
    ServiceMode? serviceMode,
    Object? department = _unset,
    Object? driver = _unset,
    Object? vehicle = _unset,
    List<String>? passengerNames,
    Object? destination = _unset,
    List<TripStopEntry>? additionalStops,
    bool? certifyOfficialBusiness,
    bool? certifyRecordCorrectness,
    bool? manualUrgent,
    Object? urgentReason = _unset,
  }) {
    return TripTicketFormData(
      uploadedFile: identical(uploadedFile, _unset)
          ? this.uploadedFile
          : uploadedFile as PlatformFile?,
      purpose: purpose ?? this.purpose,
      date: identical(date, _unset) ? this.date : date as DateTime?,
      departureTime:
      identical(departureTime, _unset) ? this.departureTime : departureTime as String?,
      returnTime: identical(returnTime, _unset) ? this.returnTime : returnTime as String?,
      pickupTime: identical(pickupTime, _unset) ? this.pickupTime : pickupTime as String?,
      serviceMode: serviceMode ?? this.serviceMode,
      department: identical(department, _unset) ? this.department : department as String?,
      driver: identical(driver, _unset) ? this.driver : driver as String?,
      vehicle: identical(vehicle, _unset) ? this.vehicle : vehicle as String?,
      passengerNames: passengerNames ?? this.passengerNames,
      destination:
      identical(destination, _unset) ? this.destination : destination as TripStopEntry?,
      additionalStops: additionalStops ?? this.additionalStops,
      certifyOfficialBusiness: certifyOfficialBusiness ?? this.certifyOfficialBusiness,
      certifyRecordCorrectness: certifyRecordCorrectness ?? this.certifyRecordCorrectness,
      manualUrgent: manualUrgent ?? this.manualUrgent,
      urgentReason:
      identical(urgentReason, _unset) ? this.urgentReason : urgentReason as String?,
    );
  }
}

class TripTicketState {
  final int currentStep; // 0=upload, 1=details, 2=driver, 3=complete
  final TripTicketFormData formData;
  final String ticketNumber;

  const TripTicketState({
    this.currentStep = 0,
    this.formData = const TripTicketFormData(),
    this.ticketNumber = 'TKT-2026-001',
  });

  TripTicketState copyWith({int? currentStep, TripTicketFormData? formData}) {
    return TripTicketState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      ticketNumber: ticketNumber,
    );
  }
}

class TripTicketNotifier extends StateNotifier<TripTicketState> {
  TripTicketNotifier() : super(const TripTicketState());

  void goToStep(int step) => state = state.copyWith(currentStep: step);
  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateFormData(TripTicketFormData Function(TripTicketFormData) update) {
    state = state.copyWith(formData: update(state.formData));
  }

  void reset() => state = const TripTicketState();

  // ----- Upload step -----
  void setUploadedFile(PlatformFile? file) {
    updateFormData((d) => d.copyWith(uploadedFile: file));
  }

  void setManualUrgent(bool value) {
    updateFormData((d) => d.copyWith(
      manualUrgent: value,
      urgentReason: value ? d.urgentReason : null,
    ));
  }

  // ----- Passengers -----
  void addPassenger(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final current = state.formData.passengerNames;
    if (current.contains(trimmed)) return;
    updateFormData((d) => d.copyWith(passengerNames: [...current, trimmed]));
  }

  void removePassenger(String name) {
    final updated = state.formData.passengerNames.where((p) => p != name).toList();
    updateFormData((d) => d.copyWith(passengerNames: updated));
  }

  // ----- Stops -----
  void setDestination(TripStopEntry? stop) {
    updateFormData((d) => d.copyWith(destination: stop));
  }

  void addStop() {
    updateFormData((d) => d.copyWith(
      additionalStops: [...d.additionalStops, const TripStopEntry()],
    ));
  }

  void updateStop(int index, TripStopEntry stop) {
    final updated = [...state.formData.additionalStops];
    if (index < 0 || index >= updated.length) return;
    updated[index] = stop;
    updateFormData((d) => d.copyWith(additionalStops: updated));
  }

  void removeStop(int index) {
    final updated = [...state.formData.additionalStops];
    if (index < 0 || index >= updated.length) return;
    updated.removeAt(index);
    updateFormData((d) => d.copyWith(additionalStops: updated));
  }
}

final tripTicketProvider =
StateNotifierProvider<TripTicketNotifier, TripTicketState>(
      (ref) => TripTicketNotifier(),
);