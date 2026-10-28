// features/driver/presentation/NavigateRoutePage/TripInformation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/printing/print_trip_ticket.dart';
import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';
import 'trip_log_forms.dart';

final DateFormat _fullDate = DateFormat('EEEE, MMMM d, yyyy');
final DateFormat _time = DateFormat('h:mm a');
final DateFormat _dateTime = DateFormat('MMM d, h:mm a');
final DateFormat _submitted = DateFormat('MMM d, yyyy h:mm a');

String _durationLabel(Duration? d) {
  if (d == null || d.isNegative) return '—';
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}M';
  return minutes == 0 ? '${hours}H' : '${hours}H ${minutes}M';
}

/// Light theme palette for this screen (matches the Home / Assigned Trips look).
class _C {
  static const bg = Color(0xFFF2F5FB);
  static const card = Colors.white;
  static const headerTint = Color(0xFFF6F8FE);
  static const primary = Color(0xFF2448B8);
  static const primaryLight = Color(0xFFE8EEFF);
  static const navy = Color(0xFF1E2A5A);
  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E9F2);
  static const yellow = Color(0xFFF5B400);
  static const yellowBg = Color(0xFFFFF7E0);
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF2E7D32);
  static const red = Color(0xFFDC2626);
  static const orange = Color(0xFFF59E0B);
}

/// Full details of one of the driver's trips, plus the action for its
/// current stage: Accept/Decline → Record Departure → Record Return.
class TripInformation extends ConsumerWidget {
  final String tripId;
  const TripInformation({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(driverTripProvider(tripId));
    final ticket = tripAsync.valueOrNull?.trip.ticketNumber;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: _C.textDark),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Details',
              style: TextStyle(
                  color: _C.textDark, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (ticket != null)
              Text(
                ticket,
                style: const TextStyle(color: _C.textMuted, fontSize: 12),
              ),
          ],
        ),
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 44, color: _C.textMuted),
                const SizedBox(height: 10),
                Text(
                  err is ApiException ? err.message : 'Could not load this trip.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _C.textMuted),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => ref.invalidate(driverTripProvider(tripId)),
                  style: FilledButton.styleFrom(backgroundColor: _C.primary),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (item) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(driverTripProvider(tripId));
            await ref.read(driverTripProvider(tripId).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.trip.isUrgent) ...[
                  _UrgentBanner(reason: item.trip.urgentReason),
                  const SizedBox(height: 12),
                ],
                _RequesterSection(item: item),
                const SizedBox(height: 12),
                _ScheduleSection(item: item),
                const SizedBox(height: 12),
                _RouteSection(trip: item.trip),
                const SizedBox(height: 12),
                _TripDetailsSection(item: item),
                const SizedBox(height: 12),
                _VehicleSection(item: item),
                const SizedBox(height: 12),
                _PassengersSection(trip: item.trip),
                if (item.departure != null) ...[
                  const SizedBox(height: 12),
                  _LogsSection(item: item),
                ],
                const SizedBox(height: 12),
                _TimelineSection(item: item),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: tripAsync.valueOrNull == null
          ? null
          : _ActionBar(item: tripAsync.valueOrNull!),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared light building blocks
// ─────────────────────────────────────────────────────────────────────────────

/// White card with a tinted header row: [icon] Title ........ trailing
class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  const _Card({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withOpacity(0.05),
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
            color: _C.headerTint,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: _C.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: _C.textDark, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: _C.border),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final bool withDot;
  const _Pill({required this.text, required this.color, this.withDot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}

/// Icon · label · value row used in the details table.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final bool last;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _C.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Text(label,
                style: const TextStyle(color: _C.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: _C.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700)),
                if (subValue != null) ...[
                  const SizedBox(height: 2),
                  Text(subValue!,
                      style: const TextStyle(color: _C.textMuted, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon over value over label, used in the schedule and vehicle stats.
class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              maxLines: 1,
              style: const TextStyle(
                  color: _C.textDark, fontSize: 14.5, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _C.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      ],
    );
  }
}

Widget _vDivider() => Container(width: 1, height: 46, color: _C.border);

// ─────────────────────────────────────────────────────────────────────────────
// Action bar
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  final DriverTrip item;
  const _ActionBar({required this.item});

  void _message(BuildContext context, String text, {bool error = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? _C.red : _C.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  Future<void> _run(
      BuildContext context,
      WidgetRef ref,
      Future<void> Function() action,
      String success,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await action();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      refreshDriverData(ref, tripId: item.id);
      _message(context, success);
    } on ApiException catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      _message(context, e.message, error: true);
    } catch (_) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      _message(context, 'Something went wrong. Please try again.', error: true);
    }
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final trip = item.trip;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _C.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept this trip?',
            style: TextStyle(color: _C.textDark, fontWeight: FontWeight.w800)),
        content: Text(
          '${trip.dateLabel}, ${trip.departureLabel} to ${trip.destinationLabel} '
              'using ${trip.vehicleModel} (${trip.vehiclePlate}).',
          style: const TextStyle(color: _C.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: _C.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: _C.greenDark),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      ref,
          () => ref.read(driverRepositoryProvider).acceptTrip(item.id),
      'Trip accepted.',
    );
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeclineDialog(
        alreadyAccepted: item.status == AdminTripStatus.driverAccepted,
      ),
    );
    if (reason == null || !context.mounted) return;
    await _run(
      context,
      ref,
          () => ref.read(driverRepositoryProvider).declineTrip(item.id, reason),
      'Trip declined. The head driver will assign someone else.',
    );
    if (context.mounted) Navigator.of(context).pop(); // no longer his trip
  }

  Future<void> _depart(BuildContext context, WidgetRef ref) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DepartureLogScreen(item: item)),
    );
    if (ok == true) {
      refreshDriverData(ref, tripId: item.id);
      _message(context, 'Departure recorded. Drive safely!');
    }
  }

  Future<void> _return(BuildContext context, WidgetRef ref) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ReturnLogScreen(item: item)),
    );
    if (ok == true) {
      refreshDriverData(ref, tripId: item.id);
      _message(context, 'Trip completed.');
    }
  }

  ButtonStyle _filled(Color color) => ElevatedButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    disabledBackgroundColor: color.withOpacity(0.35),
    disabledForegroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  ButtonStyle get _outlinedRed => OutlinedButton.styleFrom(
    foregroundColor: _C.red,
    side: const BorderSide(color: _C.red, width: 1.4),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _label(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w700));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget? content;

    if (item.canAccept) {
      content = Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _decline(context, ref),
              style: _outlinedRed,
              child: _label('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _accept(context, ref),
              style: _filled(_C.greenDark),
              child: _label('Accept'),
            ),
          ),
        ],
      );
    } else if (item.canDepart) {
      final tooEarly = item.isTooEarlyToDepart;
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tooEarly)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: _C.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can record the departure from '
                          '${_dateTime.format(item.departWindowOpensAt)}.',
                      style: const TextStyle(color: _C.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _decline(context, ref),
                style: _outlinedRed,
                child: _label("Can't make it"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: tooEarly ? null : () => _depart(context, ref),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: _label('Record Departure'),
                  style: _filled(_C.primary),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (item.canReturn) {
      content = SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _return(context, ref),
          icon: const Icon(Icons.flag_rounded),
          label: _label('Record Return'),
          style: _filled(_C.greenDark),
        ),
      );
    } else if (item.status == AdminTripStatus.completed) {
      // The driver, the requester and the admin may all print a completed
      // ticket. printTripTicket records the first print, builds the PDF and
      // opens the system print / share sheet.
      content = SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => printTripTicket(context, ref, item.id),
          icon: const Icon(Icons.print_rounded),
          label: _label('Print Trip Ticket'),
          style: _filled(_C.primary),
        ),
      );
    }

    if (content == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        border: const Border(top: BorderSide(color: _C.border)),
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
          child: content,
        ),
      ),
    );
  }
}

class _DeclineDialog extends StatefulWidget {
  final bool alreadyAccepted;
  const _DeclineDialog({required this.alreadyAccepted});

  @override
  State<_DeclineDialog> createState() => _DeclineDialogState();
}

class _DeclineDialogState extends State<_DeclineDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _C.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.alreadyAccepted ? "Can't make this trip?" : 'Decline this trip?',
        style: const TextStyle(color: _C.textDark, fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The head driver will assign another driver. Please say why.',
            style: TextStyle(color: _C.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            autofocus: true,
            style: const TextStyle(color: _C.textDark),
            decoration: InputDecoration(
              hintText: 'Reason *',
              hintStyle: const TextStyle(color: _C.textMuted),
              errorText: _error,
              filled: true,
              fillColor: _C.bg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _C.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _C.primary, width: 1.4),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: _C.textMuted)),
        ),
        FilledButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = 'A reason is required.');
              return;
            }
            Navigator.pop(context, reason);
          },
          style: FilledButton.styleFrom(backgroundColor: _C.red),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sections
// ─────────────────────────────────────────────────────────────────────────────

class _UrgentBanner extends StatelessWidget {
  final String? reason;
  const _UrgentBanner({this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _C.yellowBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.yellow.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _C.yellow, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Urgent trip',
                    style: TextStyle(
                        color: Color(0xFF7A5600),
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(reason ?? 'No reason given',
                    style: const TextStyle(color: Color(0xFF7A5600), fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequesterSection extends StatelessWidget {
  final DriverTrip item;
  const _RequesterSection({required this.item});

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final contact = trip.requester.contact;
    final hasContact = contact.trim().isNotEmpty;

    return _Card(
      icon: Icons.person_rounded,
      title: 'Requester Information',
      child: Row(
        children: [
          InitialsAvatar(name: trip.requester.fullName, radius: 26, color: _C.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.requester.fullName,
                  style: const TextStyle(
                      color: _C.textDark, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(trip.departmentName,
                    style: const TextStyle(color: _C.textMuted, fontSize: 12.5)),
                if (hasContact)
                  Text(contact,
                      style: const TextStyle(color: _C.textMuted, fontSize: 12.5)),
              ],
            ),
          ),
          if (hasContact)
            Material(
              color: _C.primaryLight,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _call(context, contact),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Icon(Icons.call_rounded, color: _C.primary, size: 20),
                      SizedBox(height: 2),
                      Text('Call',
                          style: TextStyle(
                              color: _C.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final DriverTrip item;
  const _ScheduleSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final end = item.plannedEnd;
    final distance = item.arrival == null
        ? '—'
        : '${item.arrival!.distanceTraveledKm.toStringAsFixed(0)} km';

    return _Card(
      icon: Icons.schedule_rounded,
      title: 'Schedule & Distance',
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
                icon: Icons.access_time_rounded,
                color: _C.yellow,
                value: trip.departureLabel,
                label: 'DEPARTURE'),
          ),
          _vDivider(),
          Expanded(
            child: _Stat(
                icon: Icons.history_rounded,
                color: _C.primary,
                value: end == null ? '—' : _time.format(end),
                label: trip.isWaitMode ? 'RETURN' : 'BACK BY'),
          ),
          _vDivider(),
          Expanded(
            child: _Stat(
                icon: Icons.hourglass_bottom_rounded,
                color: _C.primary,
                value: _durationLabel(item.plannedDuration),
                label: 'DURATION'),
          ),
          _vDivider(),
          Expanded(
            child: _Stat(
                icon: Icons.explore_outlined,
                color: _C.textMuted,
                value: distance,
                label: 'DISTANCE'),
          ),
        ],
      ),
    );
  }
}

class _RouteSection extends StatelessWidget {
  final AdminTripModel trip;
  const _RouteSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    final stops = trip.stops;
    return _Card(
      icon: Icons.map_rounded,
      title: 'Route',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < stops.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Column(
                      children: [
                        Icon(
                          stops[i].type == 'ORIGIN' || stops[i].type == 'DESTINATION'
                              ? Icons.location_on_rounded
                              : Icons.circle,
                          size: stops[i].type == 'ORIGIN' ||
                              stops[i].type == 'DESTINATION'
                              ? 22
                              : 10,
                          color: stops[i].type == 'ORIGIN'
                              ? _C.primary
                              : stops[i].type == 'DESTINATION'
                              ? _C.yellow
                              : _C.textMuted,
                        ),
                        if (i != stops.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: _C.border,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i == stops.length - 1 ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stops[i].type == 'ORIGIN'
                                ? 'FROM'
                                : stops[i].type == 'DESTINATION'
                                ? 'TO'
                                : 'STOP',
                            style: const TextStyle(
                              color: _C.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stops[i].address,
                            style: const TextStyle(
                              color: _C.textDark,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (stops[i].type != 'ORIGIN') ...[
                            const SizedBox(height: 2),
                            Text(
                              '~${stops[i].travelMinutes} min from base'
                                  '${stops[i].isCustom ? ' (estimate)' : ''}',
                              style: const TextStyle(color: _C.textMuted, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TripDetailsSection extends StatelessWidget {
  final DriverTrip item;
  const _TripDetailsSection({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case AdminTripStatus.headDriverApproved:
        return _C.orange;
      case AdminTripStatus.driverAccepted:
        return _C.primary;
      case AdminTripStatus.ongoing:
        return _C.green;
      case AdminTripStatus.completed:
        return _C.green;
      default:
        return _C.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final passengerCount = trip.passengers.length;

    return _Card(
      icon: Icons.description_rounded,
      title: 'Trip Details',
      trailing: _Pill(
        text: item.driverStatusLabel.toUpperCase(),
        color: _statusColor,
        withDot: true,
      ),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: _fullDate.format(trip.date),
          ),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: '${trip.departureLabel} - ${trip.endTimeLabel}',
            subValue:
            '${trip.endTimeTitle.replaceAll(':', '')} ${trip.endTimeLabel}',
          ),
          _DetailRow(
            icon: Icons.work_outline_rounded,
            label: 'Service',
            value: trip.serviceModeLabel,
          ),
          _DetailRow(
            icon: Icons.edit_note_rounded,
            label: 'Purpose',
            value: trip.purpose,
          ),
          _DetailRow(
            icon: Icons.apartment_rounded,
            label: 'Department',
            value: trip.departmentName,
          ),
          _DetailRow(
            icon: Icons.groups_outlined,
            label: 'Passengers',
            value: passengerCount == 0
                ? 'No passengers listed'
                : '$passengerCount passenger${passengerCount == 1 ? '' : 's'}',
          ),
          _DetailRow(
            icon: Icons.schedule_send_outlined,
            label: 'Submitted',
            value: _submitted.format(trip.createdAt),
            last: true,
          ),
        ],
      ),
    );
  }
}

class _VehicleSection extends StatelessWidget {
  final DriverTrip item;
  const _VehicleSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final arrival = item.arrival;
    return _Card(
      icon: Icons.directions_car_filled_rounded,
      title: 'Assigned Vehicle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 54,
                decoration: BoxDecoration(
                  color: _C.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border),
                ),
                child: const Icon(Icons.airport_shuttle_rounded,
                    color: Color(0xFF9AA8C7), size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.vehicleModel,
                      style: const TextStyle(
                          color: _C.textDark, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Plate ${trip.vehiclePlate}',
                      style: const TextStyle(color: _C.textMuted, fontSize: 12.5),
                    ),
                    Text(
                      item.vehicleOdometer == null
                          ? 'No odometer reading yet'
                          : 'Last odometer: ${item.vehicleOdometer} km',
                      style: const TextStyle(color: _C.textMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (arrival != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: _C.border),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.local_gas_station_rounded,
                    color: _C.yellow,
                    value: '${arrival.gasolineUsedLiters.toStringAsFixed(1)} L',
                    label: 'FUEL USED',
                  ),
                ),
                _vDivider(),
                Expanded(
                  child: _Stat(
                    icon: Icons.speed_rounded,
                    color: _C.primary,
                    value: '${arrival.odometerEnd}',
                    label: 'ODOMETER',
                  ),
                ),
                _vDivider(),
                Expanded(
                  child: _Stat(
                    icon: Icons.route_rounded,
                    color: _C.green,
                    value: '${arrival.distanceTraveledKm.toStringAsFixed(0)} km',
                    label: 'DISTANCE',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PassengersSection extends StatelessWidget {
  final AdminTripModel trip;
  const _PassengersSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    // The requester is listed first, then the named passengers.
    final people = <(String, String)>[
      (trip.requester.fullName, 'Requester'),
      ...trip.passengers.map((p) => (p, 'Passenger')),
    ];

    return _Card(
      icon: Icons.people_alt_rounded,
      title: 'Passengers',
      trailing: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: _C.primary, shape: BoxShape.circle),
        child: Text(
          '${people.length}',
          style: const TextStyle(
              color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Column(
        children: [
          for (int i = 0; i < people.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i == people.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: _C.border)),
              ),
              child: Row(
                children: [
                  InitialsAvatar(
                    name: people[i].$1,
                    radius: 17,
                    color: i == 0 ? _C.navy : _C.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      people[i].$1,
                      style: const TextStyle(
                          color: _C.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _Pill(
                    text: people[i].$2,
                    color: i == 0 ? _C.primary : _C.textMuted,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LogsSection extends StatelessWidget {
  final DriverTrip item;
  const _LogsSection({required this.item});

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(color: _C.textMuted, fontSize: 13)),
        ),
        Text(value,
            style: const TextStyle(
                color: _C.textDark, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _heading(String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: _Pill(text: text, color: color),
  );

  String _l(double v) => '${v.toStringAsFixed(1)} L';

  @override
  Widget build(BuildContext context) {
    final d = item.departure!;
    final r = item.arrival;
    return _Card(
      icon: Icons.local_gas_station_rounded,
      title: 'Trip Logs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('DEPARTURE', _C.yellow),
          _line('Odometer', '${d.odometerStart} km'),
          _line('Fuel in tank', _l(d.fuelBalanceInTank)),
          _line('Issued by office', _l(d.fuelIssuedByOffice)),
          _line('Purchased', _l(d.fuelPurchasedDuring)),
          _line('Total available', _l(d.totalAvailableLiters)),
          if (r != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: _C.border),
            ),
            _heading('RETURN', _C.green),
            _line('Odometer', '${r.odometerEnd} km'),
            _line('Distance', '${r.distanceTraveledKm.toStringAsFixed(0)} km'),
            _line('Fuel used', _l(r.gasolineUsedLiters)),
            _line('Fuel left', _l(r.balanceInTankLiters)),
            if (r.gearOilUsedLiters != null) _line('Gear oil', _l(r.gearOilUsedLiters!)),
            if (r.lubricatingOilUsedLiters != null)
              _line('Lubricating oil', _l(r.lubricatingOilUsedLiters!)),
            if (r.greaseIssuedLiters != null) _line('Grease', _l(r.greaseIssuedLiters!)),
            if (r.remarks != null) _line('Remarks', r.remarks!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline — built from the real timestamps
// ─────────────────────────────────────────────────────────────────────────────

class _Event {
  final DateTime time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _Event(this.time, this.title, this.subtitle, this.icon, this.color);
}

class _TimelineSection extends StatelessWidget {
  final DriverTrip item;
  const _TimelineSection({required this.item});

  List<_Event> get _events {
    final trip = item.trip;
    final events = <_Event>[
      _Event(trip.createdAt, 'Trip requested', trip.requester.fullName,
          Icons.send_rounded, _C.textMuted),
    ];
    if (item.adminApprovedAt != null) {
      events.add(_Event(item.adminApprovedAt!, 'Approved by admin', '',
          Icons.verified_outlined, _C.primary));
    }
    if (item.headDriverApprovedAt != null) {
      events.add(_Event(item.headDriverApprovedAt!, 'Approved by head driver', '',
          Icons.verified_user_outlined, _C.primary));
    }
    if (item.driverAcceptedAt != null) {
      events.add(_Event(item.driverAcceptedAt!, 'You accepted the trip', '',
          Icons.check_rounded, _C.green));
    }
    final d = item.departure;
    if (d != null) {
      final delay = item.departureDelay;
      final lateness = delay == null || delay.inMinutes <= 5
          ? 'On time'
          : '${delay.inMinutes} min late';
      events.add(_Event(
        d.departureTime,
        'Departed from garage',
        '${trip.vehiclePlate} • Odometer: ${d.odometerStart}km • $lateness',
        Icons.play_arrow_rounded,
        _C.yellow,
      ));
    }
    final r = item.arrival;
    if (r != null) {
      events.add(_Event(
        r.arrivalTime,
        'Trip completed & returned',
        'Back to garage • Odometer: ${r.odometerEnd}km',
        Icons.flag_rounded,
        _C.green,
      ));
    }
    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    return _Card(
      icon: Icons.timeline_rounded,
      title: 'Trip Timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < events.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: events[i].color.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(events[i].icon, color: events[i].color, size: 15),
                      ),
                      if (i != events.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: _C.border,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i == events.length - 1 ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(events[i].title,
                              style: const TextStyle(
                                color: _C.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 2),
                          Text(_dateTime.format(events[i].time),
                              style: const TextStyle(
                                color: _C.textMuted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              )),
                          if (events[i].subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(events[i].subtitle,
                                style: const TextStyle(
                                    color: _C.textMuted, fontSize: 12.5)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}