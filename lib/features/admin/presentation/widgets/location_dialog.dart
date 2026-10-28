// features/admin/presentation/widgets/location_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/admin_colors.dart';
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
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _radiusController;

  /// The geofence section starts open when there's already a fence, so an
  /// admin editing Dapitan doesn't have to hunt for the coordinates.
  late bool _showGeofence;

  bool get _isEdit => widget.location != null;

  @override
  void initState() {
    super.initState();
    final location = widget.location;

    _nameController = TextEditingController(text: location?.name ?? '');
    _minutesController = TextEditingController(
      text: location == null ? '' : '${location.travelMinutes}',
    );
    _latController = TextEditingController(
      text: location?.latitude?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: location?.longitude?.toString() ?? '',
    );
    _radiusController = TextEditingController(
      text: location?.radiusMeters?.toString() ?? '',
    );

    _showGeofence = location?.hasGeofence ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      suffixStyle: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
      hintStyle: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFFF6F8FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AdminColors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
    );
  }

  Widget _label(String text, {bool required = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(
            color: AdminColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
                text: ' *', style: TextStyle(color: AdminColors.amber)),
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

  /// Coordinates are optional, but a latitude without a longitude is
  /// meaningless — so if either is filled, both must be.
  String? _coordinateValidator(String? value, {required bool isLatitude}) {
    if (!_showGeofence) return null;

    final other =
    (isLatitude ? _lngController.text : _latController.text).trim();
    final mine = (value ?? '').trim();

    if (mine.isEmpty && other.isEmpty) return null; // no fence, fine
    if (mine.isEmpty) return 'Required';

    final number = double.tryParse(mine);
    if (number == null) return 'Numbers only';

    if (isLatitude && (number < -90 || number > 90)) return '-90 to 90';
    if (!isLatitude && (number < -180 || number > 180)) return '-180 to 180';
    return null;
  }

  String? _radiusValidator(String? value) {
    if (!_showGeofence) return null;
    final text = (value ?? '').trim();
    if (text.isEmpty) return null; // backend defaults to 150 m
    final radius = int.tryParse(text);
    if (radius == null) return 'Whole numbers only';
    // Below ~20 m the GPS noise is bigger than the fence; above 2 km it
    // would trigger on the highway passing the town.
    if (radius < 20) return 'At least 20 m';
    if (radius > 2000) return 'At most 2000 m';
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = _showGeofence ? double.tryParse(_latController.text.trim()) : null;
    final lng = _showGeofence ? double.tryParse(_lngController.text.trim()) : null;
    final radius =
    _showGeofence ? int.tryParse(_radiusController.text.trim()) : null;

    await ref.read(saveLocationControllerProvider.notifier).save(
      id: widget.location?.id,
      name: _nameController.text.trim(),
      travelMinutes: int.parse(_minutesController.text.trim()),
      latitude: lat,
      longitude: lng,
      radiusMeters: radius,
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
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
                      _isEdit
                          ? Icons.edit_location_alt_outlined
                          : Icons.add_location_alt_outlined,
                      color: AdminColors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit destination' : 'Add destination',
                        style: const TextStyle(
                          color: AdminColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // The dialog can now outgrow a phone-height window, so the
                // body scrolls while the header and buttons stay put.
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('DESTINATION NAME'),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                              color: AdminColors.navy, fontSize: 13),
                          decoration: _fieldDecoration('e.g. Dapitan City'),
                          validator: _nameValidator,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 14),

                        _label('ONE-WAY TRAVEL TIME'),
                        TextFormField(
                          controller: _minutesController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: AdminColors.navy, fontSize: 13),
                          decoration:
                          _fieldDecoration('e.g. 90', suffix: 'minutes'),
                          validator: _minutesValidator,
                        ),
                        const SizedBox(height: 8),
                        _InfoBox(
                          text:
                          'Driving time one way from Katipunan. This decides '
                              'how long a driver counts as busy, so an estimate '
                              'that is too short will let two trips overlap.',
                        ),

                        if (_isEdit && widget.location!.usedInStops > 0) ...[
                          const SizedBox(height: 10),
                          _WarningRow(
                            text: 'Changing the time will not alter the '
                                '${widget.location!.usedInStops} trip(s) already '
                                'booked — those keep the time they were created with.',
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(color: AdminColors.border, height: 1),
                        const SizedBox(height: 12),

                        // ── Geofence ──────────────────────────────
                        Row(
                          children: [
                            const Icon(Icons.my_location,
                                size: 16, color: AdminColors.blue),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'GPS GEOFENCE',
                                style: TextStyle(
                                  color: AdminColors.navy,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: _showGeofence,
                              activeThumbColor: AdminColors.blue,
                              onChanged: (value) =>
                                  setState(() => _showGeofence = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Optional. With coordinates set, a tracked vehicle '
                              'arriving here records its own arrival and departure '
                              'times — the driver stops typing them.',
                          style: TextStyle(
                              color: AdminColors.textMuted,
                              fontSize: 11,
                              height: 1.4),
                        ),

                        if (_showGeofence) ...[
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('LATITUDE', required: false),
                                    TextFormField(
                                      controller: _latController,
                                      keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true, signed: true),
                                      style: const TextStyle(
                                          color: AdminColors.navy, fontSize: 13),
                                      decoration: _fieldDecoration('8.5058'),
                                      validator: (v) => _coordinateValidator(v,
                                          isLatitude: true),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('LONGITUDE', required: false),
                                    TextFormField(
                                      controller: _lngController,
                                      keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true, signed: true),
                                      style: const TextStyle(
                                          color: AdminColors.navy, fontSize: 13),
                                      decoration: _fieldDecoration('123.0631'),
                                      validator: (v) => _coordinateValidator(v,
                                          isLatitude: false),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _label('RADIUS', required: false),
                          TextFormField(
                            controller: _radiusController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: AdminColors.navy, fontSize: 13),
                            decoration: _fieldDecoration('150',
                                suffix: 'metres'),
                            validator: _radiusValidator,
                          ),
                          const SizedBox(height: 8),
                          _InfoBox(
                            text:
                            'How close counts as "arrived". 150 m suits a '
                                'campus gate or town plaza. Too small and GPS '
                                'noise misses the arrival; too large and the '
                                'highway passing by triggers it.\n\n'
                                'To get coordinates: open Google Maps, '
                                'long-press the spot, and copy the two numbers '
                                'it shows.',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed:
                      isSaving ? null : () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFECEFF6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: AdminColors.navy,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.amber,
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
                            strokeWidth: 2, color: AdminColors.navy),
                      )
                          : Text(
                        _isEdit ? 'Save changes' : 'Add destination',
                        style: const TextStyle(
                            color: AdminColors.navy,
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

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AdminColors.blue, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: AdminColors.textMuted, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  final String text;
  const _WarningRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.history, color: Color(0xFFB45309), size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                color: Color(0xFFB45309), fontSize: 11, height: 1.3),
          ),
        ),
      ],
    );
  }
}