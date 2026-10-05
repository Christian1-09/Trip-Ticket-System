// features/driver/presentation/NavigateRoutePage/TripInformation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/driver/presentation/widgets/common.dart';

import '../../../../core/theme/printing/print_trip_ticket.dart';
import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';
import 'trip_log_forms.dart';

final DateFormat _fullDate = DateFormat('EEEE, MMMM d, yyyy');
final DateFormat _time = DateFormat('h:mm a');
final DateFormat _dateTime = DateFormat('MMM d, h:mm a');

String _durationLabel(Duration? d) {
  if (d == null || d.isNegative) return '—';
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}M';
  return minutes == 0 ? '${hours}H' : '${hours}H ${minutes}M';
}

/// Full details of one of the driver's trips, plus the action for its
/// current stage: Accept/Decline → Record Departure → Record Return.
class TripInformation extends ConsumerWidget {
  final String tripId;
  const TripInformation({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(driverTripProvider(tripId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.background,
        title: Text(
          tripAsync.valueOrNull?.trip.ticketNumber ?? 'Information',
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
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
                Text(
                  err is ApiException ? err.message : 'Could not load this trip.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(driverTripProvider(tripId)),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.trip.isUrgent) ...[
                  _UrgentBanner(reason: item.trip.urgentReason),
                  const SizedBox(height: 14),
                ],
                _RequesterSection(item: item),
                const SizedBox(height: 14),
                _TimeStatsSection(item: item),
                const SizedBox(height: 14),
                _TripInfoSection(item: item),
                const SizedBox(height: 14),
                _RouteSection(trip: item.trip),
                const SizedBox(height: 14),
                _VehicleSection(item: item),
                const SizedBox(height: 14),
                _PassengersSection(trip: item.trip),
                if (item.departure != null) ...[
                  const SizedBox(height: 14),
                  _LogsSection(item: item),
                ],
                const SizedBox(height: 14),
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
        backgroundColor: error ? Colors.redAccent : Colors.green,
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
        backgroundColor: AppColors.cardDeepBlue,
        title: const Text('Accept this trip?', style: TextStyle(color: Colors.white)),
        content: Text(
          '${trip.dateLabel}, ${trip.departureLabel} to ${trip.destinationLabel} '
              'using ${trip.vehicleModel} (${trip.vehiclePlate}).',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Accept', style: TextStyle(color: Colors.greenAccent)),
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

  ButtonStyle _style(Color color) => ElevatedButton.styleFrom(
    backgroundColor: color,
    disabledBackgroundColor: color.withOpacity(0.3),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget? content;

    if (item.canAccept) {
      content = Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _decline(context, ref),
              style: _style(Colors.redAccent),
              child: _label('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _accept(context, ref),
              style: _style(const Color(0xFF2E7D32)),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'You can record the departure from '
                    '${_dateTime.format(item.departWindowOpensAt)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          Row(
            children: [
              TextButton(
                onPressed: () => _decline(context, ref),
                child: const Text("Can't make it",
                    style: TextStyle(color: Colors.redAccent)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: tooEarly ? null : () => _depart(context, ref),
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: _label('Record Departure'),
                  style: _style(AppColors.statusBlue),
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
          icon: const Icon(Icons.flag_rounded, color: Colors.white),
          label: _label('Record Return'),
          style: _style(const Color(0xFF2E7D32)),
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
          icon: const Icon(Icons.print_rounded, color: Colors.white),
          label: _label('Print Trip Ticket'),
          style: _style(AppColors.statusBlue),
        ),
      );
    }

    if (content == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          border: Border(top: BorderSide(color: AppColors.statusBlue.withOpacity(0.3))),
        ),
        child: content,
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
      backgroundColor: AppColors.cardDeepBlue,
      title: Text(
        widget.alreadyAccepted ? "Can't make this trip?" : 'Decline this trip?',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The head driver will assign another driver. Please say why.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Reason *',
              hintStyle: const TextStyle(color: Colors.white38),
              errorText: _error,
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
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) {
              setState(() => _error = 'A reason is required.');
              return;
            }
            Navigator.pop(context, reason);
          },
          child: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentYellow),
      ),
      child: Text(
        'URGENT — ${reason ?? 'No reason given'}',
        style: const TextStyle(
            color: AppColors.accentYellow, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RequesterSection extends StatelessWidget {
  final DriverTrip item;
  const _RequesterSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    return SectionCard(
      child: Row(
        children: [
          InitialsAvatar(name: trip.requester.fullName, radius: 28, color: AppColors.statusCard),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REQUESTED BY',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.requester.fullName,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.departmentName} • ${trip.requester.contact}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeStatsSection extends StatelessWidget {
  final DriverTrip item;
  const _TimeStatsSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final end = item.plannedEnd;
    final distance = item.arrival == null
        ? '—'
        : '${item.arrival!.distanceTraveledKm.toStringAsFixed(0)}Km';

    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: StatItem(
                value: trip.departureLabel, label: 'DEPARTURE', color: AppColors.accentYellow),
          ),
          Expanded(
            child: StatItem(
                value: end == null ? '—' : _time.format(end),
                label: trip.isWaitMode ? 'RETURN' : 'BACK BY',
                color: AppColors.textPrimary),
          ),
          Expanded(
            child: StatItem(
                value: _durationLabel(item.plannedDuration),
                label: 'DURATION',
                color: AppColors.textPrimary),
          ),
          Expanded(
            child: StatItem(value: distance, label: 'DISTANCE', color: AppColors.statusCard),
          ),
        ],
      ),
    );
  }
}

class _TripInfoSection extends StatelessWidget {
  final DriverTrip item;
  const _TripInfoSection({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case AdminTripStatus.headDriverApproved:
        return AppColors.accentYellow;
      case AdminTripStatus.driverAccepted:
        return AppColors.statusBlue;
      case AdminTripStatus.ongoing:
        return AppColors.statusCard;
      case AdminTripStatus.completed:
        return AppColors.statusGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description_outlined,
            iconColor: AppColors.statusCard,
            title: 'Trip Information',
            trailing: StatusBadge(
              text: item.driverStatusLabel.toUpperCase(),
              color: _statusColor,
              withDot: true,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'DATE OF TRAVEL',
            value: _fullDate.format(trip.date),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.access_time,
            label: 'TRIP TIME',
            value: '${trip.departureLabel} - ${trip.endTimeLabel}',
            subValue: '${trip.serviceModeLabel} • ${trip.endTimeTitle.replaceAll(':', '')} ${trip.endTimeLabel}',
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.edit_note,
            label: 'PURPOSE',
            value: trip.purpose,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.statusBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  )),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  )),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(subValue!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteSection extends StatelessWidget {
  final AdminTripModel trip;
  const _RouteSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    final stops = trip.stops;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.statusBlue,
            title: 'Route & Destinations',
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < stops.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      TimelineDot(
                        color: i == 0 || i == stops.length - 1
                            ? AppColors.accentYellow
                            : AppColors.statusBlue,
                      ),
                      if (i != stops.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.cardDark,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i == stops.length - 1 ? 0 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stops[i].type == 'ORIGIN'
                                ? 'ORIGIN'
                                : stops[i].type == 'DESTINATION'
                                ? 'DESTINATION'
                                : 'STOP',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stops[i].address,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (stops[i].type != 'ORIGIN') ...[
                            const SizedBox(height: 2),
                            Text(
                              '~${stops[i].travelMinutes} min from base'
                                  '${stops[i].isCustom ? ' (estimate)' : ''}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12.5),
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

class _VehicleSection extends StatelessWidget {
  final DriverTrip item;
  const _VehicleSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final arrival = item.arrival;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.directions_car_filled_outlined,
            iconColor: AppColors.accentYellow,
            title: 'Assigned Vehicle',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 84,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardDeepBlue),
                ),
                child: const Icon(Icons.directions_car,
                    color: AppColors.textSecondary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.vehiclePlate} ${trip.vehicleModel.toUpperCase()}',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.vehicleOdometer == null
                          ? 'No odometer reading yet'
                          : 'Last odometer: ${item.vehicleOdometer} km',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (arrival != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    value: '${arrival.gasolineUsedLiters.toStringAsFixed(1)} L',
                    label: 'FUEL USED',
                    color: AppColors.accentYellow,
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: '${arrival.odometerEnd}',
                    label: 'ODOMETER',
                    color: AppColors.accentYellow,
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: '${arrival.distanceTraveledKm.toStringAsFixed(0)} km',
                    label: 'DISTANCE',
                    color: AppColors.textPrimary,
                    alignment: CrossAxisAlignment.end,
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

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.people_alt_outlined,
            iconColor: AppColors.statusBlue,
            title: 'Passengers',
            trailing: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.statusBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${people.length}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < people.length; i++) ...[
            Row(
              children: [
                InitialsAvatar(name: people[i].$1, radius: 18, color: AppColors.gradientStart),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    people[i].$1,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                StatusBadge(
                  text: people[i].$2,
                  color: i == 0 ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ],
            ),
            if (i != people.length - 1)
              const Divider(color: AppColors.cardDeepBlue, height: 24),
          ],
        ],
      ),
    );
  }
}

class _LogsSection extends StatelessWidget {
  final DriverTrip item;
  const _LogsSection({required this.item});

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  String _l(double v) => '${v.toStringAsFixed(1)} L';

  @override
  Widget build(BuildContext context) {
    final d = item.departure!;
    final r = item.arrival;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.local_gas_station_outlined,
            iconColor: AppColors.accentYellow,
            title: 'Trip Logs',
          ),
          const SizedBox(height: 12),
          const Text('DEPARTURE',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6)),
          _line('Odometer', '${d.odometerStart} km'),
          _line('Fuel in tank', _l(d.fuelBalanceInTank)),
          _line('Issued by office', _l(d.fuelIssuedByOffice)),
          _line('Purchased', _l(d.fuelPurchasedDuring)),
          _line('Total available', _l(d.totalAvailableLiters)),
          if (r != null) ...[
            const Divider(color: AppColors.cardDeepBlue, height: 24),
            const Text('RETURN',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6)),
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
          Icons.send_rounded, AppColors.textSecondary),
    ];
    if (item.adminApprovedAt != null) {
      events.add(_Event(item.adminApprovedAt!, 'Approved by admin', '',
          Icons.verified_outlined, AppColors.statusBlue));
    }
    if (item.headDriverApprovedAt != null) {
      events.add(_Event(item.headDriverApprovedAt!, 'Approved by head driver', '',
          Icons.verified_user_outlined, AppColors.statusBlue));
    }
    if (item.driverAcceptedAt != null) {
      events.add(_Event(item.driverAcceptedAt!, 'You accepted the trip', '',
          Icons.check, AppColors.statusGreen));
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
        AppColors.accentYellow,
      ));
    }
    final r = item.arrival;
    if (r != null) {
      events.add(_Event(
        r.arrivalTime,
        'Trip completed & returned',
        'Back to garage • Odometer: ${r.odometerEnd}km',
        Icons.flag_rounded,
        AppColors.statusGreen,
      ));
    }
    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.show_chart,
            iconColor: AppColors.statusBlue,
            title: 'Trip Timeline',
          ),
          const SizedBox(height: 16),
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
                          color: events[i].color.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(events[i].icon, color: events[i].color, size: 15),
                      ),
                      if (i != events.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.cardDeepBlue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i == events.length - 1 ? 0 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_dateTime.format(events[i].time),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 3),
                          Text(events[i].title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              )),
                          if (events[i].subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(events[i].subtitle,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12.5)),
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