// features/admin/presentation/widgets/location_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/location_model.dart';
import '../providers/location_provider.dart';

/// Add or edit a destination. Pass [location] to edit, omit it to add.
class LocationDialog extends ConsumerStatefulWidget {
  final AdminLocationModel? location;
  const LocationDialog({super.key, this.location});

  @override
  ConsumerState<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends ConsumerState<LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _minutesController;

  bool get _isEdit => widget.location != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _minutesController = TextEditingController(
      text: widget.location == null ? '' : '${widget.location!.travelMinutes}',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white38, fontSize: 12),
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

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (value.trim().length > 100) return '100 characters or less';
    return null;
  }

  /// Mirrors the backend's rule (1–1440) so the admin sees the problem
  /// before the request goes out.
  String? _minutesValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final minutes = int.tryParse(value.trim());
    if (minutes == null) return 'Whole numbers only';
    if (minutes < 1) return 'Must be at least 1';
    if (minutes > 1440) return 'Cannot exceed 1440 (24 hours)';
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(saveLocationControllerProvider.notifier).save(
      id: widget.location?.id,
      name: _nameController.text.trim(),
      travelMinutes: int.parse(_minutesController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SaveLocationState>(saveLocationControllerProvider,
            (previous, next) {
          if (next is SaveLocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 6),
              ),
            );
          } else if (next is SaveLocationSuccess) {
            ref.read(saveLocationControllerProvider.notifier).reset();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEdit ? 'Location updated.' : 'Location added.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });

    final isSaving =
    ref.watch(saveLocationControllerProvider) is SaveLocationLoading;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isEdit ? Icons.edit_location_alt_outlined
                          : Icons.add_location_alt_outlined,
                      color: const Color(0xFF29B6F6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit destination' : 'Add destination',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _label('DESTINATION NAME'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _fieldDecoration('e.g. Dapitan City'),
                  validator: _nameValidator,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),

                _label('ONE-WAY TRAVEL TIME'),
                TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration:
                  _fieldDecoration('e.g. 90', suffix: 'minutes'),
                  validator: _minutesValidator,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1442),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF29B6F6), size: 15),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Driving time one way from Katipunan. This decides '
                              'how long a driver counts as busy, so an estimate '
                              'that is too short will let two trips overlap.',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 10, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isEdit && widget.location!.usedInStops > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.history, color: Colors.amber, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Changing the time will not alter the '
                              '${widget.location!.usedInStops} trip(s) already '
                              'booked — those keep the time they were created with.',
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 10, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed:
                      isSaving ? null : () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37474F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
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
                          : Text(
                        _isEdit ? 'Save changes' : 'Add destination',
                        style: const TextStyle(
                            color: Color(0xFF0A0F35),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}