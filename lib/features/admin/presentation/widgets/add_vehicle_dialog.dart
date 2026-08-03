// features/admin/presentation/widgets/add_vehicle_dialog.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddVehicleDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm; // placeholder for now — no data passed yet

  const AddVehicleDialog({
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dieselModelsController = TextEditingController();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _odometerController = TextEditingController();
  final _yearController = TextEditingController();

  PlatformFile? _pickedFile;

  @override
  void dispose() {
    _nameController.dispose();
    _dieselModelsController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    _odometerController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
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
        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
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
                  // Upload box
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1442),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF29B6F6).withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_upload_outlined, color: Color(0xFF29B6F6), size: 36),
                          const SizedBox(height: 8),
                          Text(
                            _pickedFile?.name ?? 'Upload File',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          if (_pickedFile == null) ...[
                            const SizedBox(height: 2),
                            const Text('Drag & drop your file here, or',
                                style: TextStyle(color: Colors.white38, fontSize: 11)),
                            const Text('click to browse',
                                style: TextStyle(color: Color(0xFF29B6F6), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            alignment: WrapAlignment.center,
                            children: ['PDF', '.JPG', '.PNG', '.DOCX']
                                .map((e) => Chip(
                              label: Text(e, style: const TextStyle(fontSize: 9, color: Colors.white54)),
                              backgroundColor: const Color(0xFF1E2761),
                              side: BorderSide(color: Colors.white.withOpacity(0.15)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                              controller: _dieselModelsController,
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: const Text('Trips',
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            TextFormField(
                              enabled: false,
                              initialValue: '0',
                              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                              decoration: _fieldDecoration('0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37474F),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onConfirm(); // placeholder — closes dialog only, no data saved yet
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Confirm',
                            style: TextStyle(color: Color(0xFF0A0F35), fontWeight: FontWeight.bold)),
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