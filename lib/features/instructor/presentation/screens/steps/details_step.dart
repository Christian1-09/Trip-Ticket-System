// features/instructor/presentation/screens/steps/details_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/instructor/presentation/providers/trip_ticket_provider.dart';

import '../../../trip_ticket/data/reference_models.dart';
import '../../../trip_ticket/data/reference_providers.dart';
import '../../providers/trip_submit_controller.dart';

/// Estimates offered when the place is not on the Admin location list.
const List<int> kCustomTravelOptions = [30, 60, 90, 120, 180, 240];

class DetailsStep extends ConsumerStatefulWidget {
  const DetailsStep({super.key});

  @override
  ConsumerState<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends ConsumerState<DetailsStep> {
  final _purposeController = TextEditingController();
  final _passengerController = TextEditingController();
  final _destinationOtherController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];

  @override
  void dispose() {
    _purposeController.dispose();
    _passengerController.dispose();
    _destinationOtherController.dispose();
    for (final c in _stopControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------
  // Styling helpers
  // ------------------------------------------------------

  InputDecoration _fieldDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.cardDeepBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.statusBlue.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.statusBlue.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentYellow),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 16),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _sectionHeader(IconData icon, String title,
      {Color iconColor = AppColors.accentYellow}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const Divider(color: AppColors.textSecondary, height: 24),
      ],
    );
  }

  Widget _timeBox({required String? value, required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.statusBlue.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.statusBlue, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value ?? hint,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return null;
    if (!mounted) return null;
    return picked.format(context);
  }

  /// "3:30 PM" + a date -> one real DateTime in the phone's local time.
  /// The repository converts it to UTC before sending.
  DateTime? _combineDateAndTime(DateTime? date, String? timeStr) {
    if (date == null || timeStr == null) return null;

    final match =
    RegExp(r'(\d{1,2}):(\d{2})\s*([AP]M)', caseSensitive: false).firstMatch(timeStr);
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';

    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // ------------------------------------------------------
  // Submit
  // ------------------------------------------------------

  Future<void> _handleSubmit(TripTicketFormData formData) async {
    void warn(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    final departure = _combineDateAndTime(formData.date, formData.departureTime);
    final destination = formData.destination;

    if (formData.purpose.trim().isEmpty ||
        formData.date == null ||
        departure == null ||
        formData.department == null ||
        formData.driver == null ||
        formData.vehicle == null) {
      warn('Please fill in all required fields.');
      return;
    }

    if (destination == null || !destination.isComplete) {
      warn('Please choose a destination, including its travel time.');
      return;
    }

    for (final stop in formData.additionalStops) {
      if (!stop.isComplete) {
        warn('Please complete every stop, or remove the empty ones.');
        return;
      }
    }

    DateTime? returnDateTime;
    DateTime? pickupDateTime;

    if (formData.serviceMode == ServiceMode.wait) {
      returnDateTime = _combineDateAndTime(formData.date, formData.returnTime);
      if (returnDateTime == null) {
        warn('Please choose the return time.');
        return;
      }
      if (!returnDateTime.isAfter(departure)) {
        warn('The return time must be after the departure time.');
        return;
      }
    } else {
      pickupDateTime = _combineDateAndTime(formData.date, formData.pickupTime);
      if (pickupDateTime == null) {
        warn('Please choose the pick-up time.');
        return;
      }
      if (!pickupDateTime.isAfter(departure)) {
        warn('The pick-up time must be after the departure time.');
        return;
      }
    }

    if (!formData.certifyOfficialBusiness || !formData.certifyRecordCorrectness) {
      warn('Please check both declarations to continue.');
      return;
    }

    await ref.read(tripSubmitControllerProvider.notifier).submit(
      purpose: formData.purpose.trim(),
      date: formData.date!,
      departureDateTime: departure,
      serviceMode: formData.serviceMode,
      returnDateTime: returnDateTime,
      pickupDateTime: pickupDateTime,
      departmentId: formData.department!,
      driverId: formData.driver!,
      vehicleId: formData.vehicle!,
      passengerNames: formData.passengerNames,
      destination: destination,
      additionalStops: formData.additionalStops,
      certifyOfficialBusiness: formData.certifyOfficialBusiness,
      certifyRecordCorrectness: formData.certifyRecordCorrectness,
      manualUrgent: formData.manualUrgent,
      urgentReason: formData.manualUrgent ? formData.urgentReason?.trim() : null,
      authorizationLetterBytes: formData.uploadedFile?.bytes,
      authorizationLetterFilename: formData.uploadedFile?.name,
    );
  }

  // ------------------------------------------------------
  // Build
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(tripTicketProvider.notifier);
    final formData = ref.watch(tripTicketProvider).formData;

    // Keep the "Other" text controllers in step with the stop list.
    while (_stopControllers.length < formData.additionalStops.length) {
      _stopControllers.add(
        TextEditingController(text: formData.additionalStops[_stopControllers.length].address),
      );
    }
    while (_stopControllers.length > formData.additionalStops.length) {
      _stopControllers.removeLast().dispose();
    }

    final departure = _combineDateAndTime(formData.date, formData.departureTime);
    final availabilityQuery = buildAvailabilityQuery(
      serviceMode: formData.serviceMode,
      departureDateTime: departure,
      returnDateTime: formData.serviceMode == ServiceMode.wait
          ? _combineDateAndTime(formData.date, formData.returnTime)
          : null,
      pickupDateTime: formData.serviceMode == ServiceMode.dropAndPickup
          ? _combineDateAndTime(formData.date, formData.pickupTime)
          : null,
      travelMinutes: formData.maxTravelMinutes,
    );

    ref.listen<SubmitTripState>(tripSubmitControllerProvider, (previous, next) {
      if (next is SubmitTripError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.redAccent),
        );
      } else if (next is SubmitTripSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip ticket submitted! Waiting for admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        notifier.reset();
        ref.read(tripSubmitControllerProvider.notifier).reset();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          notifier.goToStep(0);
        }
      }
    });

    final isSubmitting = ref.watch(tripSubmitControllerProvider) is SubmitTripLoading;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.description_outlined, 'Trip Details'),

              _sectionLabel('PURPOSE *'),
              TextField(
                controller: _purposeController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _fieldDecoration('Describe the purpose of this trip...'),
                onChanged: (val) => notifier.updateFormData((d) => d.copyWith(purpose: val)),
              ),

              // ---------- DATE + DEPARTURE ----------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('DATE *'),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              notifier.updateFormData((d) => d.copyWith(date: picked));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.cardDeepBlue,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.statusBlue.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: AppColors.statusBlue, size: 15),
                                const SizedBox(width: 8),
                                Text(
                                  formData.date != null
                                      ? DateFormat('MM/dd/yyyy').format(formData.date!)
                                      : 'Select date',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('DEPARTURE *'),
                        _timeBox(
                          value: formData.departureTime,
                          hint: 'Select time',
                          onTap: () async {
                            final time = await _pickTime();
                            if (time != null) {
                              notifier.updateFormData((d) => d.copyWith(departureTime: time));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ---------- SERVICE MODE ----------
              _sectionLabel('HOW WILL THE DRIVER SERVE THIS TRIP? *'),
              Column(
                children: ServiceMode.values.map((mode) {
                  final selected = formData.serviceMode == mode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => notifier.updateFormData((d) => d.copyWith(serviceMode: mode)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardDeepBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.accentYellow
                                : AppColors.statusBlue.withOpacity(0.4),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selected ? AppColors.accentYellow : AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mode.label,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(mode.description,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ---------- RETURN OR PICK-UP TIME ----------
              if (formData.serviceMode == ServiceMode.wait) ...[
                _sectionLabel('RETURN TIME *'),
                _timeBox(
                  value: formData.returnTime,
                  hint: 'When will the trip finish?',
                  onTap: () async {
                    final time = await _pickTime();
                    if (time != null) {
                      notifier.updateFormData((d) => d.copyWith(returnTime: time));
                    }
                  },
                ),
                const SizedBox(height: 4),
                const Text('The driver stays with the passengers until this time.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ] else ...[
                _sectionLabel('PICK-UP TIME *'),
                _timeBox(
                  value: formData.pickupTime,
                  hint: 'When should the driver come back?',
                  onTap: () async {
                    final time = await _pickTime();
                    if (time != null) {
                      notifier.updateFormData((d) => d.copyWith(pickupTime: time));
                    }
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                    'The driver is free between drop-off and pick-up, so he can serve other trips.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],

              _sectionLabel('DEPARTMENT *'),
              Consumer(
                builder: (context, ref, _) {
                  final departmentsAsync = ref.watch(departmentsProvider);
                  return departmentsAsync.when(
                    loading: () => const _DropdownLoadingPlaceholder(),
                    error: (err, _) => _DropdownErrorPlaceholder(
                      message: 'Could not load departments',
                      onRetry: () => ref.invalidate(departmentsProvider),
                    ),
                    data: (departments) {
                      final selected = departments.any((d) => d.id == formData.department)
                          ? formData.department
                          : null;
                      return DropdownButtonFormField<String>(
                        value: selected,
                        decoration: _fieldDecoration('Select Department...'),
                        dropdownColor: AppColors.cardDeepBlue,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: departments
                            .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                            .toList(),
                        onChanged: (val) =>
                            notifier.updateFormData((d) => d.copyWith(department: val)),
                      );
                    },
                  );
                },
              ),

              // ---------- ROUTE ----------
              const SizedBox(height: 20),
              _sectionHeader(Icons.location_on_outlined, 'Route & Destinations'),

              _sectionLabel('ORIGIN'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardDeepBlue.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusBlue.withOpacity(0.25)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, color: AppColors.statusBlue, size: 10),
                    SizedBox(width: 10),
                    Text('$kBaseLocationName (base)',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    Spacer(),
                    Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 14),
                  ],
                ),
              ),

              _sectionLabel('DESTINATION *'),
              _StopPicker(
                stop: formData.destination,
                otherController: _destinationOtherController,
                decorationBuilder: _fieldDecoration,
                onChanged: notifier.setDestination,
              ),

              const SizedBox(height: 12),
              ...List.generate(formData.additionalStops.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('STOP ${index + 1}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textSecondary, size: 18),
                            onPressed: () => notifier.removeStop(index),
                          ),
                        ],
                      ),
                      _StopPicker(
                        stop: formData.additionalStops[index],
                        otherController: _stopControllers[index],
                        decorationBuilder: _fieldDecoration,
                        onChanged: (stop) => notifier.updateStop(index, stop ?? const TripStopEntry()),
                      ),
                    ],
                  ),
                );
              }),

              GestureDetector(
                onTap: () => notifier.addStop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardDeepBlue.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.statusBlue.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: AppColors.statusBlue, size: 18),
                      SizedBox(width: 6),
                      Text('Add another stop',
                          style: TextStyle(
                              color: AppColors.statusBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),

              // ---------- DRIVER + VEHICLE ----------
              const SizedBox(height: 20),
              _sectionHeader(Icons.directions_car_outlined, 'Vehicle & Personnel'),

              _sectionLabel('DRIVER *'),
              Consumer(
                builder: (context, ref, _) {
                  final driversAsync = ref.watch(availableDriversProvider(availabilityQuery));
                  return driversAsync.when(
                    loading: () => const _DropdownLoadingPlaceholder(),
                    error: (err, _) => _DropdownErrorPlaceholder(
                      message: 'Could not load drivers',
                      onRetry: () => ref.invalidate(availableDriversProvider(availabilityQuery)),
                    ),
                    data: (drivers) {
                      final selected =
                      drivers.any((d) => d.id == formData.driver) ? formData.driver : null;
                      if (drivers.isEmpty) {
                        return const _EmptyPlaceholder(
                          message: 'No driver is free for this schedule. Try another time.',
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: selected,
                        decoration: _fieldDecoration('Select a driver...'),
                        dropdownColor: AppColors.cardDeepBlue,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: drivers
                            .map((d) => DropdownMenuItem(value: d.id, child: Text(d.label)))
                            .toList(),
                        onChanged: (val) =>
                            notifier.updateFormData((d) => d.copyWith(driver: val)),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                availabilityQuery.isEmpty
                    ? 'Pick the date and times first to see who is free.'
                    : 'Only drivers free at this date and time are shown.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),

              _sectionLabel('VEHICLE *'),
              Consumer(
                builder: (context, ref, _) {
                  final vehiclesAsync = ref.watch(availableVehiclesProvider(availabilityQuery));
                  return vehiclesAsync.when(
                    loading: () => const _DropdownLoadingPlaceholder(),
                    error: (err, _) => _DropdownErrorPlaceholder(
                      message: 'Could not load vehicles',
                      onRetry: () => ref.invalidate(availableVehiclesProvider(availabilityQuery)),
                    ),
                    data: (vehicles) {
                      final selected = vehicles.any((v) => v.id == formData.vehicle)
                          ? formData.vehicle
                          : null;
                      if (vehicles.isEmpty) {
                        return const _EmptyPlaceholder(
                          message: 'No vehicle is free for this schedule. Try another time.',
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: selected,
                        decoration: _fieldDecoration('Select a vehicle...'),
                        dropdownColor: AppColors.cardDeepBlue,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: vehicles
                            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.label)))
                            .toList(),
                        onChanged: (val) =>
                            notifier.updateFormData((d) => d.copyWith(vehicle: val)),
                      );
                    },
                  );
                },
              ),

              // ---------- PASSENGERS ----------
              _sectionLabel('PASSENGER\'S NAME'),
              TextField(
                controller: _passengerController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _fieldDecoration('Enter passenger name...'),
                textInputAction: TextInputAction.done,
                onSubmitted: (val) {
                  notifier.addPassenger(val);
                  _passengerController.clear();
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: formData.passengerNames.map((name) {
                  return Chip(
                    label: Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: AppColors.statusBlue.withOpacity(0.25),
                    deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.statusBlue),
                    onDeleted: () => notifier.removePassenger(name),
                    side: BorderSide(color: AppColors.statusBlue.withOpacity(0.5)),
                  );
                }).toList(),
              ),

              // ---------- DECLARATIONS ----------
              const SizedBox(height: 20),
              const Text('DECLARATIONS',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              _declarationCheckbox(
                value: formData.certifyOfficialBusiness,
                onChanged: (val) => notifier
                    .updateFormData((d) => d.copyWith(certifyOfficialBusiness: val ?? false)),
                text: const TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  children: [
                    TextSpan(text: 'I hereby certify that I used this car for '),
                    TextSpan(
                      text: 'official business',
                      style: TextStyle(color: AppColors.statusBlue, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' as stated above.'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _declarationCheckbox(
                value: formData.certifyRecordCorrectness,
                onChanged: (val) => notifier
                    .updateFormData((d) => d.copyWith(certifyRecordCorrectness: val ?? false)),
                text: const TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  children: [
                    TextSpan(text: 'I hereby certify to the correctness of the '),
                    TextSpan(
                      text: 'statement of record of travel',
                      style: TextStyle(color: AppColors.statusBlue, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () => _handleSubmit(formData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusBlue,
                    disabledBackgroundColor: AppColors.statusBlue.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('SUBMIT',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (isSubmitting)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _declarationCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextSpan text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.statusBlue,
          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.6)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(text: text),
          ),
        ),
      ],
    );
  }
}

/// Location dropdown with an "Other" option. Picking a location copies its
/// travel time; "Other" asks the requester to type the place and estimate
/// the one-way travel time, which the backend needs for the overlap check.
class _StopPicker extends ConsumerWidget {
  final TripStopEntry? stop;
  final TextEditingController otherController;
  final InputDecoration Function(String hint, {Widget? prefixIcon}) decorationBuilder;
  final ValueChanged<TripStopEntry?> onChanged;

  static const String _otherValue = '__OTHER__';

  const _StopPicker({
    required this.stop,
    required this.otherController,
    required this.decorationBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsProvider);

    return locationsAsync.when(
      loading: () => const _DropdownLoadingPlaceholder(),
      error: (err, _) => _DropdownErrorPlaceholder(
        message: 'Could not load locations',
        onRetry: () => ref.invalidate(locationsProvider),
      ),
      data: (locations) {
        // "Other" is remembered by the useCustom flag, never guessed from
        // the typed text — otherwise the fields below would stay hidden.
        String? dropdownValue;
        if (stop != null) {
          if (stop!.useCustom) {
            dropdownValue = _otherValue;
          } else if (stop!.locationId != null &&
              locations.any((l) => l.id == stop!.locationId)) {
            dropdownValue = stop!.locationId;
          }
        }

        final isOther = dropdownValue == _otherValue;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: dropdownValue,
              isExpanded: true,
              decoration: decorationBuilder('Select a place...',
                  prefixIcon:
                  const Icon(Icons.location_on, color: AppColors.accentYellow, size: 18)),
              dropdownColor: AppColors.cardDeepBlue,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: [
                ...locations.map(
                      (l) => DropdownMenuItem(value: l.id, child: Text(l.label)),
                ),
                const DropdownMenuItem(
                  value: _otherValue,
                  child: Text('Other (not on the list)'),
                ),
              ],
              onChanged: (val) {
                if (val == null) return;
                if (val == _otherValue) {
                  onChanged(TripStopEntry(
                    useCustom: true,
                    address: otherController.text.trim(),
                  ));
                } else {
                  final location = locations.firstWhere((l) => l.id == val);
                  onChanged(TripStopEntry.fromLocation(location));
                }
              },
            ),
            if (locations.isEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'No places have been set up yet. Ask the admin to add them, '
                    'or use "Other" for now.',
                style: TextStyle(color: AppColors.accentYellow, fontSize: 11),
              ),
            ],
            if (isOther) ...[
              const SizedBox(height: 8),
              TextField(
                controller: otherController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: decorationBuilder('Type the place name... *'),
                onChanged: (val) => onChanged(
                  (stop ?? const TripStopEntry())
                      .copyWith(address: val, useCustom: true, clearLocationId: true),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: (stop?.travelMinutes ?? 0) > 0 ? stop!.travelMinutes : null,
                isExpanded: true,
                decoration: decorationBuilder('One-way travel time from base... *'),
                dropdownColor: AppColors.cardDeepBlue,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: kCustomTravelOptions
                    .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m < 60
                      ? '$m minutes'
                      : '${(m / 60).toStringAsFixed(m % 60 == 0 ? 0 : 1)} hour(s)'),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val == null) return;
                  onChanged((stop ?? const TripStopEntry())
                      .copyWith(travelMinutes: val, useCustom: true, clearLocationId: true));
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Roughly how long is the one-way drive from base? This is used to check '
                    'whether the driver is free.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final String message;
  const _EmptyPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDeepBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentYellow.withOpacity(0.5)),
      ),
      child: Text(message,
          style: const TextStyle(color: AppColors.accentYellow, fontSize: 12)),
    );
  }
}

class _DropdownLoadingPlaceholder extends StatelessWidget {
  const _DropdownLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDeepBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.statusBlue.withOpacity(0.4)),
      ),
      alignment: Alignment.centerLeft,
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _DropdownErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DropdownErrorPlaceholder({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDeepBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}