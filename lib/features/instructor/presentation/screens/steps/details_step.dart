// features/trip_ticket/presentation/screens/steps/details_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/features/instructor/presentation/providers/trip_ticket_provider.dart';
import 'package:signature/signature.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';


class DetailsStep extends ConsumerStatefulWidget {
  const DetailsStep({super.key});

  @override
  ConsumerState<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends ConsumerState<DetailsStep> {
  final _purposeController = TextEditingController();
  final _passengerController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [];

  late final SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: Colors.white,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _passengerController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    for (final c in _stopControllers) {
      c.dispose();
    }
    _signatureController.dispose();
    super.dispose();
  }

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

  Widget _sectionHeader(IconData icon, String title, {Color iconColor = AppColors.accentYellow}) {
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

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(tripTicketProvider.notifier);
    final formData = ref.watch(tripTicketProvider).formData;

    // Keep stop controllers in sync with provider list length
    while (_stopControllers.length < formData.additionalStops.length) {
      final controller = TextEditingController(text: formData.additionalStops[_stopControllers.length]);
      _stopControllers.add(controller);
    }
    while (_stopControllers.length > formData.additionalStops.length) {
      _stopControllers.removeLast().dispose();
    }

    return SingleChildScrollView(
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
          const SizedBox(height: 4),
          const Text('Provide a clear reason for the trip request',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),

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
                            const Icon(Icons.calendar_today, color: AppColors.statusBlue, size: 15),
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
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          notifier.updateFormData(
                                  (d) => d.copyWith(departureTime: picked.format(context)));
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
                            const Icon(Icons.access_time, color: AppColors.statusBlue, size: 15),
                            const SizedBox(width: 8),
                            Text(
                              formData.departureTime ?? 'Select time',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _sectionLabel('DEPARTMENT *'),
          DropdownButtonFormField<String>(
            value: formData.department,
            decoration: _fieldDecoration('Select Department...'),
            dropdownColor: AppColors.cardDeepBlue,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: ['CCS', 'CTED', 'High School', 'CBA', 'CAP-SDE']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => notifier.updateFormData((d) => d.copyWith(department: val)),
          ),

          const SizedBox(height: 20),
          _sectionHeader(Icons.directions_car_outlined, 'Vehicle & Personnel'),

          _sectionLabel('DRIVER *'),
          DropdownButtonFormField<String>(
            value: formData.driver,
            decoration: _fieldDecoration('Select a driver...'),
            dropdownColor: AppColors.cardDeepBlue,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: ['Juan Dela Cruz', 'Steve P. Bareno']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => notifier.updateFormData((d) => d.copyWith(driver: val)),
          ),
          const SizedBox(height: 4),
          const Text('Only available drivers are shown',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),

          _sectionLabel('VEHICLE *'),
          DropdownButtonFormField<String>(
            value: formData.vehicle,
            decoration: _fieldDecoration('Select a vehicle...'),
            dropdownColor: AppColors.cardDeepBlue,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: ['JJS 963 Innova', 'SEM-832 Canter']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (val) => notifier.updateFormData((d) => d.copyWith(vehicle: val)),
          ),
          const SizedBox(height: 4),
          const Text('Only available vehicles are shown',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),

          // ---------- PASSENGER'S NAME ----------
          _sectionLabel('PASSENGER\'S NAME *'),
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

          const SizedBox(height: 20),
          _sectionHeader(Icons.location_on_outlined, 'Route & Destinations'),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardDeepBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.statusBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                      children: [
                        TextSpan(text: 'Enter your '),
                        TextSpan(
                          text: 'origin',
                          style: TextStyle(color: AppColors.statusBlue, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' and at least '),
                        TextSpan(
                          text: 'destination',
                          style: TextStyle(color: AppColors.statusBlue, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: '. Add multiple stops if needed'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _originController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _fieldDecoration(
              'Enter  Origin / Starting point...',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.circle, color: AppColors.statusBlue, size: 10),
              ),
            ),
            onChanged: (val) => notifier.updateFormData((d) => d.copyWith(origin: val)),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _destinationController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _fieldDecoration(
              'Enter Primary destination...',
              prefixIcon: const Icon(Icons.location_on, color: AppColors.accentYellow, size: 18),
            ),
            onChanged: (val) => notifier.updateFormData((d) => d.copyWith(destination: val)),
          ),
          const SizedBox(height: 10),

          // Dynamic additional stops
          ...List.generate(_stopControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _stopControllers[index],
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _fieldDecoration(
                  'Enter stop ${index + 1}...',
                  prefixIcon: const Icon(Icons.add_location_alt_outlined,
                      color: AppColors.statusBlue, size: 18),
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    onPressed: () => notifier.removeStop(index),
                  ),
                ),
                onChanged: (val) => notifier.updateStop(index, val),
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
                border: Border.all(
                  color: AppColors.statusBlue.withOpacity(0.4),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.statusBlue, size: 18),
                  SizedBox(width: 6),
                  Text('Add another stop',
                      style: TextStyle(color: AppColors.statusBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _sectionHeader(Icons.edit_outlined, 'Signatures & Approval', iconColor: AppColors.statusGreen),

          _sectionLabel('PASSENGER\'S SIGNATURE *'),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.cardDeepBlue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.statusBlue.withOpacity(0.4)),
            ),
            child: Stack(
              children: [
                Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.transparent,
                ),
                ValueListenableBuilder(
                  valueListenable: _signatureController,
                  builder: (context, value, _) {
                    if (_signatureController.isNotEmpty) return const SizedBox.shrink();
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, color: AppColors.statusBlue, size: 28),
                          SizedBox(height: 8),
                          Text('Tap to sign here',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text('Draw your signature with your finger',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
                    onPressed: () {
                      _signatureController.clear();
                      notifier.updateFormData((d) => d.copyWith(signatureBytes: null));
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('DECLARATIONS',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),

          _declarationCheckbox(
            value: formData.certifyOfficialBusiness,
            onChanged: (val) =>
                notifier.updateFormData((d) => d.copyWith(certifyOfficialBusiness: val ?? false)),
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
            onChanged: (val) =>
                notifier.updateFormData((d) => d.copyWith(certifyRecordCorrectness: val ?? false)),
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
              onPressed: () async {
                final signatureBytes = await _signatureController.toPngBytes();
                notifier.updateFormData((d) => d.copyWith(signatureBytes: signatureBytes));
                // TODO: proceed to Driver step / submit logic
                notifier.nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('SUBMIT',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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