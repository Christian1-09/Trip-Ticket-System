// features/incident/presentation/screens/report_incident_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../../../../core/theme/driver_colors.dart';
import '../../../data/incident_model.dart';
import '../../../data/incident_repository.dart';

import '../../providers/incident_provider.dart';


/// Files an incident report.
///
/// The same screen serves drivers and requesters — the only thing that
/// differs is the list of types, and that comes from the server
/// (`GET /api/incidents/options`) rather than from a copy here that would
/// drift the first time a type is added.
///
/// Pops `true` when a report was filed.
class ReportIncidentScreen extends ConsumerStatefulWidget {
  /// Null is allowed for a driver reporting a fault with no trip
  /// involved. A requester must always supply one — the server refuses
  /// otherwise, since a passenger reporting on no particular trip gives
  /// the admin nothing to investigate.
  final String? tripRequestId;

  /// Shown at the top so the reporter can see what they're reporting on.
  final String? tripLabel;
  final String? vehicleLabel;

  /// True while the trip is ONGOING. Decides whether the screen promises
  /// that the location will come from the tracker.
  final bool tripIsOngoing;

  const ReportIncidentScreen({
    super.key,
    this.tripRequestId,
    this.tripLabel,
    this.vehicleLabel,
    this.tripIsOngoing = false,
  });

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _locationText = TextEditingController();

  String? _type;
  IncidentSeverity _severity = IncidentSeverity.minor;
  final List<IncidentPhoto> _photos = [];
  bool _busy = false;

  static const _maxPhotos = 3;

  @override
  void dispose() {
    _description.dispose();
    _locationText.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
      // Without this, .bytes is null on web and the upload sends nothing
      // while appearing to succeed. Same reason add_vehicle_dialog sets it.
      withData: true,
    );
    if (result == null || !mounted) return;

    setState(() {
      for (final file in result.files) {
        if (_photos.length >= _maxPhotos) break;
        if (file.bytes == null) continue;
        _photos.add(IncidentPhoto(bytes: file.bytes!, filename: file.name));
      }
    });
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? DriverColors.red : DriverColors.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_type == null) {
      _message('Choose what happened.', error: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);

    try {
      final incident = await ref.read(incidentRepositoryProvider).create(
        type: _type!,
        severity: _severity.backendValue,
        description: _description.text.trim(),
        tripRequestId: widget.tripRequestId,
        locationText: _locationText.text,
        // Deliberately not sending coordinates: on an ongoing trip the
        // server fills them from the vehicle's last tracker fix, which
        // is more accurate than anything a phone could offer about
        // where the *vehicle* is.
        photos: _photos,
      );

      if (!mounted) return;
      ref.invalidate(incidentListProvider);
      if (widget.tripRequestId != null) {
        ref.invalidate(tripIncidentsProvider(widget.tripRequestId!));
      }

      await _showFiled(incident);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _message(e.message, error: true);
    } catch (_) {
      _message('Could not file the report. Check your connection.',
          error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showFiled(IncidentModel incident) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DriverColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: DriverColors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: DriverColors.green, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              incident.incidentNumber,
              style: const TextStyle(
                  color: DriverColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Reported. The admin and the head driver have been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: DriverColors.textMuted, fontSize: 13.5, height: 1.5),
            ),
            if (incident.locatedByGps) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: DriverColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location_rounded,
                        size: 14, color: DriverColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Location taken from the tracker',
                      style: TextStyle(
                          color: DriverColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: DriverColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(incidentOptionsProvider);

    return Scaffold(
      backgroundColor: DriverColors.bg,
      appBar: AppBar(
        backgroundColor: DriverColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: DriverColors.textDark),
        titleSpacing: 0,
        title: const Text(
          'Report an Incident',
          style: TextStyle(
              color: DriverColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: _SubmitBar(
        busy: _busy,
        onPressed: _busy ? null : _submit,
      ),
      body: optionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 44, color: DriverColors.textMuted),
                const SizedBox(height: 10),
                Text(
                  err is ApiException
                      ? err.message
                      : 'Could not load the report form.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: DriverColors.textMuted),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(incidentOptionsProvider),
                  style:
                  FilledButton.styleFrom(backgroundColor: DriverColors.primary),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (options) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              if (widget.tripLabel != null || widget.vehicleLabel != null)
                _ContextStrip(
                  tripLabel: widget.tripLabel,
                  vehicleLabel: widget.vehicleLabel,
                ),
              if (widget.tripLabel != null || widget.vehicleLabel != null)
                const SizedBox(height: 12),

              _Card(
                icon: Icons.report_problem_outlined,
                title: 'What happened?',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options.types
                      .map((type) => ChoiceChip(
                    label: Text(prettify(type)),
                    selected: _type == type,
                    onSelected: _busy
                        ? null
                        : (_) => setState(() => _type = type),
                    selectedColor: DriverColors.primary,
                    backgroundColor: DriverColors.field,
                    labelStyle: TextStyle(
                      color: _type == type
                          ? Colors.white
                          : DriverColors.textDark,
                      fontSize: 13,
                      fontWeight: _type == type
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: _type == type
                          ? DriverColors.primary
                          : DriverColors.border,
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),

              _Card(
                icon: Icons.priority_high_rounded,
                title: 'How serious is it?',
                subtitle: 'The admin and head driver are told either way.',
                child: Row(
                  children: IncidentSeverity.values.map((severity) {
                    final selected = _severity == severity;
                    final color = switch (severity) {
                      IncidentSeverity.major => DriverColors.red,
                      IncidentSeverity.moderate => DriverColors.orange,
                      IncidentSeverity.minor => DriverColors.textMuted,
                    };

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _busy
                              ? null
                              : () => setState(() => _severity = severity),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.10)
                                  : DriverColors.field,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                selected ? color : DriverColors.border,
                                width: selected ? 1.6 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  switch (severity) {
                                    IncidentSeverity.major =>
                                    Icons.dangerous_outlined,
                                    IncidentSeverity.moderate =>
                                    Icons.warning_amber_rounded,
                                    IncidentSeverity.minor =>
                                    Icons.info_outline_rounded,
                                  },
                                  size: 20,
                                  color: selected
                                      ? color
                                      : DriverColors.textMuted,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  severity.label,
                                  style: TextStyle(
                                    color: selected
                                        ? color
                                        : DriverColors.textMuted,
                                    fontSize: 12.5,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              _Card(
                icon: Icons.edit_note_rounded,
                title: 'Describe it',
                subtitle: 'What happened, and what you did about it.',
                child: TextFormField(
                  controller: _description,
                  enabled: !_busy,
                  maxLines: 5,
                  style: const TextStyle(
                      color: DriverColors.textDark,
                      fontSize: 14.5,
                      height: 1.5),
                  decoration: _decoration(
                    'Required',
                    helper: 'At least 10 characters.',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Required';
                    if (text.length < 10) {
                      return 'Please write a little more — at least 10 characters.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),

              _Card(
                icon: Icons.photo_camera_outlined,
                title: 'Photos',
                subtitle:
                'Optional, up to $_maxPhotos. Strongly recommended for a collision.',
                child: _PhotoRow(
                  photos: _photos,
                  max: _maxPhotos,
                  enabled: !_busy,
                  onAdd: _addPhotos,
                  onRemove: (index) => setState(() => _photos.removeAt(index)),
                ),
              ),
              const SizedBox(height: 12),

              _Card(
                icon: Icons.place_outlined,
                title: 'Where',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.tripIsOngoing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: DriverColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.my_location_rounded,
                                size: 16, color: DriverColors.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The tracker will record exactly where the '
                                    'vehicle is. You only need to add a landmark '
                                    'if it helps.',
                                style: TextStyle(
                                    color: DriverColors.primary,
                                    fontSize: 12.5,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.tripIsOngoing) const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationText,
                      enabled: !_busy,
                      style: const TextStyle(
                          color: DriverColors.textDark, fontSize: 14.5),
                      decoration: _decoration(
                        'Landmark or nearest place (optional)',
                        icon: Icons.signpost_outlined,
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

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

InputDecoration _decoration(String label, {String? helper, IconData? icon}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );

  return InputDecoration(
    labelText: label,
    helperText: helper,
    helperMaxLines: 2,
    alignLabelWithHint: true,
    prefixIcon: icon == null
        ? null
        : Icon(icon, size: 20, color: DriverColors.primary),
    labelStyle: const TextStyle(color: DriverColors.textMuted, fontSize: 14),
    floatingLabelStyle: const TextStyle(
        color: DriverColors.primary, fontWeight: FontWeight.w600),
    helperStyle: const TextStyle(color: DriverColors.textMuted, fontSize: 11.5),
    filled: true,
    fillColor: DriverColors.field,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: border(DriverColors.border),
    enabledBorder: border(DriverColors.border),
    disabledBorder: border(DriverColors.border),
    focusedBorder: border(DriverColors.primary, 1.5),
    errorBorder: border(DriverColors.red),
    focusedErrorBorder: border(DriverColors.red, 1.5),
  );
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _Card({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DriverColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DriverColors.border),
        boxShadow: [
          BoxShadow(
            color: DriverColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: DriverColors.headerTint,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: DriverColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: DriverColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(title,
                            style: const TextStyle(
                                color: DriverColors.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(subtitle!,
                            style: const TextStyle(
                                color: DriverColors.textMuted, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: DriverColors.border),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _ContextStrip extends StatelessWidget {
  final String? tripLabel;
  final String? vehicleLabel;

  const _ContextStrip({this.tripLabel, this.vehicleLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A9E), Color(0xFF3461E0)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.report_problem_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vehicleLabel != null)
                  Text(vehicleLabel!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                if (tripLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(tripLabel!,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  final List<IncidentPhoto> photos;
  final int max;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoRow({
    required this.photos,
    required this.max,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < photos.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      photos[i].bytes,
                      width: 110,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: enabled ? () => onRemove(i) : null,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (photos.length < max)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: enabled ? onAdd : null,
              child: Container(
                width: 110,
                height: 96,
                decoration: BoxDecoration(
                  color: DriverColors.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: DriverColors.primary.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined,
                        color: DriverColors.primary, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      '${photos.length} of $max',
                      style: const TextStyle(
                          color: DriverColors.textMuted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final bool busy;
  final VoidCallback? onPressed;

  const _SubmitBar({required this.busy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DriverColors.card,
        border: const Border(top: BorderSide(color: DriverColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: busy
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.send_rounded),
              label: Text(busy ? 'Sending…' : 'File Report',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: DriverColors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: DriverColors.red.withOpacity(0.5),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}