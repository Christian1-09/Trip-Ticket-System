// features/admin/presentation/widgets/edit_vehicle_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';
import 'driver_assignment_field.dart';

/// Edits a vehicle's details. The photo is not changed here — replacing it
/// needs a multipart upload, which only the create endpoint handles.
class EditVehicleDialog extends ConsumerStatefulWidget {
  final VehicleModel vehicle;
  const EditVehicleDialog({required this.vehicle, super.key});

  @override
  ConsumerState<EditVehicleDialog> createState() => _EditVehicleDialogState();
}

class _EditVehicleDialogState extends ConsumerState<EditVehicleDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _plateController;
  late final TextEditingController _capacityController;
  late final TextEditingController _odometerController;
  late final TextEditingController _yearController;
  late List<VehicleAssignmentInput> _assignments;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameController = TextEditingController(text: v.model);
    _assignments = v.toAssignmentInputs();
    _typeController = TextEditingController(text: v.type);
    _plateController = TextEditingController(text: v.plateNumber);
    _capacityController = TextEditingController(text: '${v.capacity}');
    _odometerController = TextEditingController(text: '${v.odometerCurrent ?? 0}');
    _yearController = TextEditingController(text: v.year == null ? '' : '${v.year}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    _odometerController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0D1442),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF29B6F6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(
            color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: text),
          const TextSpan(text: ' *', style: TextStyle(color: Colors.amber)),
        ],
      ),
    ),
  );

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (int.tryParse(value.trim()) == null) return 'Numbers only';
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(editVehicleControllerProvider.notifier).save(
      widget.vehicle.id,
      model: _nameController.text.trim(),
      type: _typeController.text.trim(),
      plateNumber: _plateController.text.trim(),
      capacity: _capacityController.text.trim(),
      year: _yearController.text.trim(),
      odometerCurrent: _odometerController.text.trim(),
      assignments: _assignments,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EditVehicleState>(editVehicleControllerProvider, (previous, next) {
      if (next is EditVehicleError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 6),
          ),
        );
      } else if (next is EditVehicleSuccess) {
        ref.read(editVehicleControllerProvider.notifier).reset();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated.'), backgroundColor: Colors.green),
        );
      }
    });

    final isSaving = ref.watch(editVehicleControllerProvider) is EditVehicleLoading;

    return Dialog(
      backgroundColor: const Color(0xFF141B4D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF29B6F6), width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_rounded, color: Color(0xFF29B6F6), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Edit ${widget.vehicle.plateNumber}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('The vehicle photo cannot be changed here.',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 18),

                  _label('VEHICLE NAME'),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _fieldDecoration('Enter vehicle name'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('DIESEL MODELS'),
                            TextFormField(
                              controller: _typeController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _fieldDecoration('Enter Diesel Models'),
                              validator: _requiredValidator,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('PLATE NO'),
                            TextFormField(
                              controller: _plateController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _fieldDecoration('Enter plate no'),
                              validator: _requiredValidator,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Capacity'),
                            TextFormField(
                              controller: _capacityController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _fieldDecoration('Enter capacity'),
                              validator: _numberValidator,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Odometer'),
                            TextFormField(
                              controller: _odometerController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _fieldDecoration('Enter odometer'),
                              validator: _numberValidator,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Year'),
                            TextFormField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _fieldDecoration('Enter year'),
                              validator: _numberValidator,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text('Trips',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                            TextFormField(
                              enabled: false,
                              initialValue: '${widget.vehicle.trips}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4), fontSize: 13),
                              decoration: _fieldDecoration('0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DriverAssignmentField(
                    initial: _assignments,
                    onChanged: (value) => _assignments = value,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37474F),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isSaving
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF0A0F35)),
                        )
                            : const Text('Save changes',
                            style: TextStyle(
                                color: Color(0xFF0A0F35),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}