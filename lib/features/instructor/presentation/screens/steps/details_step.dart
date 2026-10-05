// features/instructor/presentation/screens/steps/details_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/features/instructor/presentation/providers/trip_ticket_provider.dart';

import '../../../trip_ticket/data/reference_models.dart';
import '../../../trip_ticket/data/reference_providers.dart';
import '../../providers/trip_submit_controller.dart';

/// Estimates offered when the place is not on the Admin location list.
const List<int> kCustomTravelOptions = [30, 60, 90, 120, 180, 240];

/// Light theme colors shared by the Trip Ticket steps.
class _Palette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1E6FE0);
  static const yellow = Color(0xFFFFC629);
  static const yellowTint = Color(0xFFFFF7DC);
  static const lightBlue = Color(0xFFE6F0FD);
  static const softFill = Color(0xFFF6F8FC);
  static const border = Color(0xFFDCE3EE);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFB7791F);
}

const _dropdownIcon = Icon(
  Icons.keyboard_arrow_down_rounded,
  color: _Palette.navy,
  size: 24,
);

const _fieldTextStyle = TextStyle(color: _Palette.textDark, fontSize: 14);

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
  void initState() {
    super.initState();
    final formData = ref.read(tripTicketProvider).formData;
    _purposeController.text = formData.purpose;
    _destinationOtherController.text = formData.destination?.address ?? '';
  }

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

  static InputDecoration _fieldDecoration(String hint, {Widget? prefixIcon}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _Palette.textMuted, fontSize: 14),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      counterStyle: const TextStyle(color: _Palette.textMuted, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: border(_Palette.border),
      enabledBorder: border(_Palette.border),
      focusedBorder: border(_Palette.blue, 1.5),
      errorBorder: border(_Palette.error),
      focusedErrorBorder: border(_Palette.error, 1.5),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 18),
    child: Text(
      text,
      style: const TextStyle(
        color: _Palette.textDark,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _helperText(String text, {Color color = _Palette.textMuted}) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(text, style: TextStyle(color: color, fontSize: 12, height: 1.35)),
  );

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _Palette.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _Palette.blue, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _Palette.textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _Palette.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Divider(color: _Palette.border, thickness: 1, height: 1),
  );

  /// Tappable box used for the date and time pickers.
  Widget _pickerBox({
    required IconData icon,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _Palette.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: _Palette.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    color: value == null ? _Palette.textMuted : _Palette.textDark,
                    fontSize: 14,
                    fontWeight: value == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _dropdownIcon,
            ],
          ),
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TRIP DETAILS =================
                  _sectionHeader(Icons.description_outlined, 'Trip Details',
                      'Provide the details for this trip request.'),

                  _sectionLabel('PURPOSE *'),
                  TextField(
                    controller: _purposeController,
                    maxLines: 4,
                    maxLength: 500,
                    style: _fieldTextStyle,
                    decoration: _fieldDecoration('Describe the purpose of this trip...'),
                    onChanged: (val) =>
                        notifier.updateFormData((d) => d.copyWith(purpose: val)),
                  ),

                  // ---------- DATE + DEPARTURE ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('DATE *'),
                            _pickerBox(
                              icon: Icons.calendar_month_outlined,
                              value: formData.date != null
                                  ? DateFormat('MM/dd/yyyy').format(formData.date!)
                                  : null,
                              hint: 'Select date',
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: formData.date ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  notifier.updateFormData((d) => d.copyWith(date: picked));
                                }
                              },
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
                            _pickerBox(
                              icon: Icons.access_time_rounded,
                              value: formData.departureTime,
                              hint: 'Select time',
                              onTap: () async {
                                final time = await _pickTime();
                                if (time != null) {
                                  notifier.updateFormData(
                                          (d) => d.copyWith(departureTime: time));
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
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ServiceModeCard(
                          title: mode.label,
                          description: mode.description,
                          selected: selected,
                          onTap: () =>
                              notifier.updateFormData((d) => d.copyWith(serviceMode: mode)),
                        ),
                      );
                    }).toList(),
                  ),

                  // ---------- RETURN OR PICK-UP TIME ----------
                  if (formData.serviceMode == ServiceMode.wait) ...[
                    _sectionLabel('RETURN TIME *'),
                    _pickerBox(
                      icon: Icons.access_time_rounded,
                      value: formData.returnTime,
                      hint: 'Select time',
                      onTap: () async {
                        final time = await _pickTime();
                        if (time != null) {
                          notifier.updateFormData((d) => d.copyWith(returnTime: time));
                        }
                      },
                    ),
                    _helperText('The driver stays with the passengers until this time.'),
                  ] else ...[
                    _sectionLabel('PICK-UP TIME *'),
                    _pickerBox(
                      icon: Icons.access_time_rounded,
                      value: formData.pickupTime,
                      hint: 'Select time',
                      onTap: () async {
                        final time = await _pickTime();
                        if (time != null) {
                          notifier.updateFormData((d) => d.copyWith(pickupTime: time));
                        }
                      },
                    ),
                    _helperText(
                        'The driver is free between drop-off and pick-up, so he can serve other trips.'),
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
                            isExpanded: true,
                            icon: _dropdownIcon,
                            decoration: _fieldDecoration(
                              'Select department',
                              prefixIcon: const Icon(Icons.apartment_rounded,
                                  color: _Palette.blue, size: 20),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            style: _fieldTextStyle,
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

                  // ================= ROUTE =================
                  _sectionDivider(),
                  _sectionHeader(Icons.route_outlined, 'Route & Destinations',
                      'Where is this trip going?'),

                  _sectionLabel('ORIGIN'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      color: _Palette.softFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _Palette.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.trip_origin_rounded, color: _Palette.blue, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$kBaseLocationName (base)',
                            style: TextStyle(
                              color: _Palette.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.lock_outline_rounded,
                            color: _Palette.textMuted, size: 16),
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

                  const SizedBox(height: 14),
                  ...List.generate(formData.additionalStops.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
                      decoration: BoxDecoration(
                        color: _Palette.softFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _Palette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'STOP ${index + 1}',
                                style: const TextStyle(
                                  color: _Palette.textDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Remove stop',
                                icon: const Icon(Icons.close_rounded,
                                    color: _Palette.textMuted, size: 20),
                                onPressed: () => notifier.removeStop(index),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _StopPicker(
                              stop: formData.additionalStops[index],
                              otherController: _stopControllers[index],
                              decorationBuilder: _fieldDecoration,
                              onChanged: (stop) =>
                                  notifier.updateStop(index, stop ?? const TripStopEntry()),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  Material(
                    color: _Palette.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => notifier.addStop(),
                      child: const SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, color: _Palette.blue, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Add another stop',
                              style: TextStyle(
                                color: _Palette.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ================= DRIVER + VEHICLE =================
                  _sectionDivider(),
                  _sectionHeader(Icons.directions_car_outlined, 'Vehicle & Personnel',
                      'Choose who drives and what vehicle to use.'),

                  _sectionLabel('DRIVER *'),
                  Consumer(
                    builder: (context, ref, _) {
                      final driversAsync = ref.watch(availableDriversProvider(availabilityQuery));
                      return driversAsync.when(
                        loading: () => const _DropdownLoadingPlaceholder(),
                        error: (err, _) => _DropdownErrorPlaceholder(
                          message: 'Could not load drivers',
                          onRetry: () =>
                              ref.invalidate(availableDriversProvider(availabilityQuery)),
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
                            isExpanded: true,
                            icon: _dropdownIcon,
                            decoration: _fieldDecoration(
                              'Select a driver',
                              prefixIcon: const Icon(Icons.badge_outlined,
                                  color: _Palette.blue, size: 20),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            style: _fieldTextStyle,
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
                  _helperText(
                    availabilityQuery.isEmpty
                        ? 'Pick the date and times first to see who is free.'
                        : 'Only drivers free at this date and time are shown.',
                  ),

                  _sectionLabel('VEHICLE *'),
                  Consumer(
                    builder: (context, ref, _) {
                      final vehiclesAsync =
                      ref.watch(availableVehiclesProvider(availabilityQuery));
                      return vehiclesAsync.when(
                        loading: () => const _DropdownLoadingPlaceholder(),
                        error: (err, _) => _DropdownErrorPlaceholder(
                          message: 'Could not load vehicles',
                          onRetry: () =>
                              ref.invalidate(availableVehiclesProvider(availabilityQuery)),
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
                            isExpanded: true,
                            icon: _dropdownIcon,
                            decoration: _fieldDecoration(
                              'Select a vehicle',
                              prefixIcon: const Icon(Icons.airport_shuttle_outlined,
                                  color: _Palette.blue, size: 20),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            style: _fieldTextStyle,
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
                  _sectionLabel('PASSENGERS'),
                  TextField(
                    controller: _passengerController,
                    style: _fieldTextStyle,
                    decoration: _fieldDecoration(
                      'Type a name and press done',
                      prefixIcon: const Icon(Icons.person_add_alt_1_outlined,
                          color: _Palette.blue, size: 20),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (val) {
                      notifier.addPassenger(val);
                      _passengerController.clear();
                    },
                  ),
                  if (formData.passengerNames.isNotEmpty) const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: formData.passengerNames.map((name) {
                      return Chip(
                        label: Text(
                          name,
                          style: const TextStyle(
                            color: _Palette.navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _Palette.lightBlue,
                        deleteIcon:
                        const Icon(Icons.close_rounded, size: 16, color: _Palette.blue),
                        onDeleted: () => notifier.removePassenger(name),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),

                  // ================= DECLARATIONS =================
                  _sectionDivider(),
                  _sectionHeader(Icons.verified_outlined, 'Declarations',
                      'Please confirm both statements.'),
                  const SizedBox(height: 14),
                  _DeclarationCard(
                    value: formData.certifyOfficialBusiness,
                    onTap: () => notifier.updateFormData((d) =>
                        d.copyWith(certifyOfficialBusiness: !formData.certifyOfficialBusiness)),
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'I hereby certify that I used this car for '),
                        TextSpan(
                          text: 'official business',
                          style: TextStyle(color: _Palette.blue, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' as stated above.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DeclarationCard(
                    value: formData.certifyRecordCorrectness,
                    onTap: () => notifier.updateFormData((d) =>
                        d.copyWith(certifyRecordCorrectness: !formData.certifyRecordCorrectness)),
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'I hereby certify to the correctness of the '),
                        TextSpan(
                          text: 'statement of record of travel',
                          style: TextStyle(color: _Palette.blue, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),
                  _SubmitButton(
                    enabled: !isSubmitting,
                    onTap: () => _handleSubmit(formData),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (isSubmitting)
              Container(
                color: Colors.white.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: _Palette.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// Small UI pieces
// ------------------------------------------------------

class _ServiceModeCard extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceModeCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _Palette.yellowTint : _Palette.softFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _Palette.yellow : _Palette.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: selected ? _Palette.navy : _Palette.textMuted,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _Palette.navy,
                    ),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _Palette.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _Palette.textMuted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeclarationCard extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final TextSpan text;

  const _DeclarationCard({
    required this.value,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: value ? _Palette.lightBlue.withOpacity(0.6) : _Palette.softFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? _Palette.blue.withOpacity(0.5) : _Palette.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? _Palette.navy : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? _Palette.navy : _Palette.navy.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: _Palette.textDark,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                    children: [text],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _SubmitButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
          BoxShadow(
            color: _Palette.yellow.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Palette.yellow,
          disabledBackgroundColor: _Palette.yellow.withOpacity(0.35),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Submit Trip Ticket',
              style: TextStyle(
                color: _Palette.textDark,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.send_rounded, color: _Palette.textDark, size: 22),
            ),
          ],
        ),
      ),
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
              icon: _dropdownIcon,
              decoration: decorationBuilder(
                'Select a place',
                prefixIcon: const Icon(Icons.location_on_rounded,
                    color: _Palette.error, size: 20),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: _fieldTextStyle,
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
                style: TextStyle(color: _Palette.warning, fontSize: 12),
              ),
            ],
            if (isOther) ...[
              const SizedBox(height: 10),
              TextField(
                controller: otherController,
                style: _fieldTextStyle,
                decoration: decorationBuilder(
                  'Type the place name *',
                  prefixIcon:
                  const Icon(Icons.edit_location_alt_outlined, color: _Palette.blue, size: 20),
                ),
                onChanged: (val) => onChanged(
                  (stop ?? const TripStopEntry())
                      .copyWith(address: val, useCustom: true, clearLocationId: true),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: (stop?.travelMinutes ?? 0) > 0 ? stop!.travelMinutes : null,
                isExpanded: true,
                icon: _dropdownIcon,
                decoration: decorationBuilder(
                  'One-way travel time from base *',
                  prefixIcon: const Icon(Icons.timer_outlined, color: _Palette.blue, size: 20),
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: _fieldTextStyle,
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
              const SizedBox(height: 6),
              const Text(
                'Roughly how long is the one-way drive from base? This is used to check '
                    'whether the driver is free.',
                style: TextStyle(color: _Palette.textMuted, fontSize: 12, height: 1.35),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Palette.yellowTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Palette.yellow),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _Palette.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _Palette.textDark, fontSize: 13),
            ),
          ),
        ],
      ),
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
        color: _Palette.softFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Palette.border),
      ),
      alignment: Alignment.centerLeft,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: _Palette.blue),
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
      padding: const EdgeInsets.only(left: 14, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Palette.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _Palette.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: _Palette.error, fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: _Palette.blue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}