// features/admin/presentation/screens/incident_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/incident/data/incident_model.dart';
import 'package:jtrips_app/features/incident/presentation/providers/incident_provider.dart';

import '../../../../core/theme/admin_colors.dart';

/// Same basemap as the live vehicle map. Worth lifting into one shared
/// constant the next time either file is touched — two copies is how a
/// tile source ends up changed in one place and not the other.
const _tileUrl =
    'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/'
    'World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}';

final _dateTime = DateFormat('d MMM y, h:mm a');

Color severityColor(IncidentSeverity severity) => switch (severity) {
  IncidentSeverity.major => const Color(0xFFDC2626),
  IncidentSeverity.moderate => const Color(0xFFF59E0B),
  IncidentSeverity.minor => const Color(0xFF64748B),
};

Color statusColor(IncidentStatus status) => switch (status) {
  IncidentStatus.open => const Color(0xFFDC2626),
  IncidentStatus.underReview => const Color(0xFFF59E0B),
  IncidentStatus.resolved => const Color(0xFF16A34A),
  IncidentStatus.dismissed => const Color(0xFF94A3B8),
};

class IncidentScreen extends ConsumerWidget {
  const IncidentScreen({super.key});

  static const _filters = <IncidentStatus?>[
    null,
    IncidentStatus.open,
    IncidentStatus.underReview,
    IncidentStatus.resolved,
    IncidentStatus.dismissed,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(incidentListProvider);
    final filter = ref.watch(incidentFilterProvider);
    final busy = ref.watch(incidentActionBusyProvider);
    final openCount = ref.watch(openIncidentCountProvider).valueOrNull ?? 0;

    return ColoredBox(
      color: AdminColors.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Incidents',
                              style: TextStyle(
                                  color: AdminColors.navy,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            openCount == 0
                                ? 'Nothing outstanding.'
                                : '$openCount report${openCount == 1 ? '' : 's'} still need attention.',
                            style: TextStyle(
                              color: openCount == 0
                                  ? AdminColors.textMuted
                                  : const Color(0xFFDC2626),
                              fontSize: 14,
                              fontWeight: openCount == 0
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () => ref.invalidate(incidentListProvider),
                      icon: const Icon(Icons.refresh,
                          color: AdminColors.navy, size: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filters
                      .map((status) => _FilterPill(
                    label: status?.label ?? 'All',
                    selected: status == filter,
                    onTap: () => ref
                        .read(incidentFilterProvider.notifier)
                        .state = status,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: incidentsAsync.when(
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _ErrorBlock(
                      message: '$err',
                      onRetry: () => ref.invalidate(incidentListProvider),
                    ),
                    data: (incidents) {
                      if (incidents.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield_outlined,
                                  size: 44, color: Color(0xFFC3CBDC)),
                              const SizedBox(height: 10),
                              Text(
                                filter == null
                                    ? 'No incidents have been reported.'
                                    : 'Nothing ${filter.label.toLowerCase()}.',
                                style: const TextStyle(
                                    color: AdminColors.textMuted),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: incidents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _IncidentCard(
                          incident: incidents[index],
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) =>
                                IncidentDetailDialog(incident: incidents[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const _IncidentCard({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final severity = severityColor(incident.severity);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: AdminColors.cardShadow,
            // A colour bar rather than a coloured card: the severity is
            // readable at a glance without the row shouting.
            border: Border(left: BorderSide(color: severity, width: 4)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: severity.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(incident.type), color: severity, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(incident.incidentNumber,
                            style: const TextStyle(
                                color: AdminColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        _Chip(
                          label: incident.severity.label,
                          color: severity,
                        ),
                        if (incident.locatedByGps) ...[
                          const SizedBox(width: 6),
                          const _Chip(
                            label: 'GPS',
                            color: AdminColors.blue,
                            icon: Icons.my_location_rounded,
                          ),
                        ],
                        if (incident.photoUrls.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _Chip(
                            label: '${incident.photoUrls.length}',
                            color: AdminColors.textMuted,
                            icon: Icons.photo_outlined,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${incident.typeLabel}  ·  ${incident.vehicle?.label ?? 'No vehicle'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AdminColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_dateTime.format(incident.occurredAt)}  ·  '
                          'reported by ${incident.reportedBy.fullName}'
                          '${incident.trip == null ? '' : '  ·  ${incident.trip!.ticketNumber}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AdminColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Chip(
                label: incident.status.label,
                color: statusColor(incident.status),
                filled: true,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AdminColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String type) => switch (type) {
    'BREAKDOWN' => Icons.car_repair,
    'ACCIDENT' => Icons.car_crash_outlined,
    'FLAT_TIRE' => Icons.tire_repair,
    'ROAD_BLOCKED' => Icons.block_outlined,
    'WEATHER' => Icons.thunderstorm_outlined,
    'MEDICAL' => Icons.medical_services_outlined,
    'LATE_PICKUP' => Icons.schedule_outlined,
    'DRIVER_CONDUCT' => Icons.person_off_outlined,
    'VEHICLE_CONDITION' => Icons.build_outlined,
    'SAFETY_CONCERN' => Icons.warning_amber_rounded,
    _ => Icons.report_outlined,
  };
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  const _Chip({
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.12) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminColors.amber : Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: selected ? 0 : 0.5,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: selected ? AdminColors.amber : AdminColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: AdminColors.navy,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
          const SizedBox(height: 8),
          const Text('Could not load incidents',
              style: TextStyle(
                  color: AdminColors.navy, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style:
              const TextStyle(color: AdminColors.textMuted, fontSize: 11)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail + review
// ---------------------------------------------------------------------------

class IncidentDetailDialog extends ConsumerStatefulWidget {
  final IncidentModel incident;

  const IncidentDetailDialog({required this.incident, super.key});

  @override
  ConsumerState<IncidentDetailDialog> createState() =>
      _IncidentDetailDialogState();
}

class _IncidentDetailDialogState extends ConsumerState<IncidentDetailDialog> {
  late IncidentModel _incident = widget.incident;

  final _resolutionController = TextEditingController();
  IncidentStatus _nextStatus = IncidentStatus.underReview;
  bool _countsAgainstDriver = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _resolutionController.text = _incident.resolution ?? '';
    if (_incident.status == IncidentStatus.underReview) {
      _nextStatus = IncidentStatus.resolved;
    }
    _countsAgainstDriver = _incident.countedAgainstDriverAt != null;
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<IncidentModel> Function() action) async {
    setState(() => _busy = true);
    ref.read(incidentActionBusyProvider.notifier).state = true;
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() => _incident = updated);
      ref.invalidate(incidentListProvider);
    } on ApiException catch (e) {
      _message(e.message, error: true);
    } catch (_) {
      _message('Something went wrong. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.read(incidentActionBusyProvider.notifier).state = false;
    }
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final severity = severityColor(_incident.severity);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: (size.width - 80).clamp(320.0, 820.0),
        height: size.height * 0.84,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 10, 14),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: severity, width: 5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_incident.incidentNumber,
                                style: const TextStyle(
                                    color: AdminColors.navy,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(width: 10),
                            _Chip(
                                label: _incident.severity.label,
                                color: severity),
                            const SizedBox(width: 6),
                            _Chip(
                                label: _incident.status.label,
                                color: statusColor(_incident.status),
                                filled: true),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_incident.typeLabel}  ·  ${_dateTime.format(_incident.occurredAt)}',
                          style: const TextStyle(
                              color: AdminColors.textMuted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AdminColors.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AdminColors.border),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Facts(incident: _incident),
                    const SizedBox(height: 18),

                    const _SectionLabel('What happened'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_incident.description,
                          style: const TextStyle(
                              color: AdminColors.navy,
                              fontSize: 13.5,
                              height: 1.5)),
                    ),

                    if (_incident.photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _SectionLabel('Photos (${_incident.photoUrls.length})'),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _incident.photoUrls.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) => _Photo(
                            url: _incident.photoUrls[index],
                          ),
                        ),
                      ),
                    ],

                    if (_incident.hasPosition) ...[
                      const SizedBox(height: 18),
                      _SectionLabel(
                        _incident.locatedByGps
                            ? 'Where it happened — from the tracker'
                            : 'Where it happened',
                      ),
                      _MiniMap(incident: _incident),
                    ],

                    if (_incident.locationText != null) ...[
                      const SizedBox(height: 8),
                      Text(_incident.locationText!,
                          style: const TextStyle(
                              color: AdminColors.textMuted, fontSize: 12.5)),
                    ],

                    const SizedBox(height: 22),
                    const Divider(color: AdminColors.border),
                    const SizedBox(height: 14),

                    _review(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _review() {
    final canFlag = _incident.vehicle != null &&
        _incident.vehicleFlaggedAt == null &&
        _incident.vehicle!.status != 'MAINTENANCE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Review'),

        if (_incident.reviewedBy != null && _incident.reviewedAt != null) ...[
          Text(
            'Last reviewed by ${_incident.reviewedBy!.fullName} on '
                '${_dateTime.format(_incident.reviewedAt!)}',
            style: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
        ],

        Wrap(
          spacing: 8,
          children: [
            IncidentStatus.underReview,
            IncidentStatus.resolved,
            IncidentStatus.dismissed,
          ]
              .map((status) => ChoiceChip(
            label: Text(status.label),
            selected: _nextStatus == status,
            onSelected: _busy
                ? null
                : (_) => setState(() => _nextStatus = status),
            selectedColor: AdminColors.amber,
            backgroundColor: const Color(0xFFF1F4FA),
            labelStyle: TextStyle(
              color: AdminColors.navy,
              fontSize: 12.5,
              fontWeight: _nextStatus == status
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
            side: const BorderSide(color: AdminColors.border),
          ))
              .toList(),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _resolutionController,
          enabled: !_busy,
          maxLines: 3,
          style: const TextStyle(color: AdminColors.navy, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'What was decided, and what was done about it?',
            hintStyle:
            const TextStyle(color: AdminColors.textMuted, fontSize: 12.5),
            filled: true,
            fillColor: const Color(0xFFF6F8FC),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminColors.blue),
            ),
          ),
        ),

        if (_incident.driver != null &&
            _nextStatus == IncidentStatus.resolved) ...[
          const SizedBox(height: 6),
          CheckboxListTile(
            value: _countsAgainstDriver,
            onChanged: _busy || _incident.countedAgainstDriverAt != null
                ? null
                : (value) =>
                setState(() => _countsAgainstDriver = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: AdminColors.navy,
            title: Text(
              'Count this against ${_incident.driver!.fullName}',
              style: const TextStyle(
                  color: AdminColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            // The reason this is a deliberate tick rather than automatic:
            // a driver who reports a pothole must not be marked like one
            // who caused a collision, or drivers stop reporting at all.
            subtitle: Text(
              _incident.countedAgainstDriverAt != null
                  ? 'Already recorded — it cannot be counted twice.'
                  : "Adds one to the driver's incident count. Only tick this "
                  'when they were at fault.',
              style:
              const TextStyle(color: AdminColors.textMuted, fontSize: 11.5),
            ),
          ),
        ],

        const SizedBox(height: 14),
        Row(
          children: [
            if (canFlag)
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() => ref
                    .read(incidentRepositoryProvider)
                    .flagVehicle(_incident.id)),
                icon: const Icon(Icons.build_circle_outlined, size: 18),
                label: const Text('Flag vehicle for maintenance'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            if (_incident.vehicleFlaggedAt != null)
              Text(
                'Vehicle taken out of service on '
                    '${_dateTime.format(_incident.vehicleFlaggedAt!)}',
                style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                final updated =
                await ref.read(incidentRepositoryProvider).review(
                  _incident.id,
                  status: _nextStatus.backendValue,
                  resolution: _resolutionController.text.trim(),
                  countsAgainstDriver: _countsAgainstDriver,
                );
                _message('${updated.incidentNumber} updated.');
                return updated;
              }),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AdminColors.blue,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _busy
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('Save review',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  final IncidentModel incident;

  const _Facts({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 28,
      runSpacing: 14,
      children: [
        _Fact(
            label: 'VEHICLE',
            value: incident.vehicle?.label ?? 'Not recorded'),
        _Fact(
            label: 'DRIVER',
            value: incident.driver?.fullName ?? 'Not recorded'),
        _Fact(
          label: 'REPORTED BY',
          value: '${incident.reportedBy.fullName}'
              '${incident.reportedBy.role == null ? '' : ' (${prettify(incident.reportedBy.role!)})'}',
        ),
        if (incident.trip != null)
          _Fact(label: 'TRIP', value: incident.trip!.ticketNumber),
        _Fact(label: 'FILED', value: _dateTime.format(incident.createdAt)),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: AdminColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AdminColors.navy,
                fontSize: 13.5,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AdminColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _Photo extends StatelessWidget {
  final String url;

  const _Photo({required this.url});

  @override
  Widget build(BuildContext context) {
    final full = ApiConfig.mediaUrl(url);

    return GestureDetector(
      onTap: full == null
          ? null
          : () => showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(24),
          child: InteractiveViewer(
            child: Image.network(full, fit: BoxFit.contain),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 170,
          height: 130,
          child: full == null
              ? const ColoredBox(color: Color(0xFFECEFF6))
              : Image.network(
            full,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFFECEFF6),
              child: Icon(Icons.broken_image_outlined,
                  color: Color(0xFFA0A8BC)),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small, non-interactive map showing exactly where the report was
/// filed. Dragging is off deliberately — it's a fact, not a tool.
class _MiniMap extends StatelessWidget {
  final IncidentModel incident;

  const _MiniMap({required this.incident});

  @override
  Widget build(BuildContext context) {
    final point = incident.position!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
                interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: _tileUrl,
                  userAgentPackageName: 'ph.edu.jrmsu.jtrips',
                  maxNativeZoom: 16,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: severityColor(incident.severity),
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                color: Colors.white70,
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const Text(
                  'Esri, HERE, Garmin, © OpenStreetMap contributors',
                  style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Text(
                  '${incident.latitude!.toStringAsFixed(5)}, '
                      '${incident.longitude!.toStringAsFixed(5)}',
                  style: const TextStyle(
                      color: AdminColors.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}