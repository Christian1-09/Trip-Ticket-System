// features/trip_ticket/presentation/providers/trip_ticket_provider.dart
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripTicketFormData {
  final PlatformFile? uploadedFile;
  final String purpose;
  final DateTime? date;
  final String? departureTime;
  final String? department;
  final String? driver;
  final String? vehicle;

  // New fields
  final List<String> passengerNames;
  final String origin;
  final String destination;
  final List<String> additionalStops;
  final Uint8List? signatureBytes;
  final bool certifyOfficialBusiness;
  final bool certifyRecordCorrectness;

  const TripTicketFormData({
    this.uploadedFile,
    this.purpose = '',
    this.date,
    this.departureTime,
    this.department,
    this.driver,
    this.vehicle,
    this.passengerNames = const [],
    this.origin = '',
    this.destination = '',
    this.additionalStops = const [],
    this.signatureBytes,
    this.certifyOfficialBusiness = false,
    this.certifyRecordCorrectness = false,
  });

  TripTicketFormData copyWith({
    PlatformFile? uploadedFile,
    String? purpose,
    DateTime? date,
    String? departureTime,
    String? department,
    String? driver,
    String? vehicle,
    List<String>? passengerNames,
    String? origin,
    String? destination,
    List<String>? additionalStops,
    Uint8List? signatureBytes,
    bool? certifyOfficialBusiness,
    bool? certifyRecordCorrectness,
  }) {
    return TripTicketFormData(
      uploadedFile: uploadedFile ?? this.uploadedFile,
      purpose: purpose ?? this.purpose,
      date: date ?? this.date,
      departureTime: departureTime ?? this.departureTime,
      department: department ?? this.department,
      driver: driver ?? this.driver,
      vehicle: vehicle ?? this.vehicle,
      passengerNames: passengerNames ?? this.passengerNames,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      additionalStops: additionalStops ?? this.additionalStops,
      signatureBytes: signatureBytes ?? this.signatureBytes,
      certifyOfficialBusiness: certifyOfficialBusiness ?? this.certifyOfficialBusiness,
      certifyRecordCorrectness: certifyRecordCorrectness ?? this.certifyRecordCorrectness,
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

  // Passenger helpers
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

  // Stops helpers
  void addStop() {
    updateFormData((d) => d.copyWith(additionalStops: [...d.additionalStops, '']));
  }

  void updateStop(int index, String value) {
    final updated = [...state.formData.additionalStops];
    updated[index] = value;
    updateFormData((d) => d.copyWith(additionalStops: updated));
  }

  void removeStop(int index) {
    final updated = [...state.formData.additionalStops]..removeAt(index);
    updateFormData((d) => d.copyWith(additionalStops: updated));
  }
}

final tripTicketProvider =
StateNotifierProvider<TripTicketNotifier, TripTicketState>(
      (ref) => TripTicketNotifier(),
);