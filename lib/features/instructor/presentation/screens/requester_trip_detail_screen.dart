// features/instructor/presentation/screens/requester_trip_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/printing/print_trip_ticket.dart';
import '../../data/requester_trip_models.dart';
import '../providers/requester_trip_providers.dart';
import '../widgets/rate_driver_dialog.dart';

final DateFormat _fullDate = DateFormat('EEEE, MMMM d, yyyy');
final DateFormat _dateTime = DateFormat('MMM d, h:mm a');

// ─────────────────────────────────────────────────────────── light palette

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _pageBg = Color(0xFFF2F5FA);
const _tileBg = Color(0xFFE8F0FD);
const _divider = Color(0xFFE9EDF4);
const _grey = Color(0xFFC5CCD8);
const _green = Color(0xFF1FA35B);
const _amber = Color(0xFFF2B300);
const _red = Color(0xFFE5394A);

/// What the requester sees about their own trip: where it is in the
/// approval chain, who is driving, and — once completed — rating and print.
class RequesterTripDetailScreen extends ConsumerWidget {
  final String tripId;
  const RequesterTripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myTripProvider(tripId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: _pageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: _navy),
          titleSpacing: 0,
          toolbarHeight: 64,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Details',
                style: TextStyle(
                  color: _navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (async.valueOrNull?.trip.ticketNumber != null)
                Text(
                  async.valueOrNull!.trip.ticketNumber,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
            ],
          ),
        ),
        body: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _blue),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: _red, size: 34),
                  const SizedBox(height: 10),
                  Text(
                    err is ApiException
                        ? err.message
                        : 'Could not load this trip.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _navy, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(myTripProvider(tripId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (item) => RefreshIndicator(
            color: _blue,
            onRefresh: () async {
              ref.invalidate(myTripProvider(tripId));
              await ref.read(myTripProvider(tripId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                _StatusCard(item: item),
                const SizedBox(height: 12),
                if (item.isRejected) ...[
                  _RejectedCard(item: item),
                  const SizedBox(height: 12),
                ],
                _DriverCard(item: item),
                const SizedBox(height: 12),
                _ScheduleCard(item: item),
                const SizedBox(height: 12),
                _RouteCard(trip: item.trip),
                const SizedBox(height: 12),
                _DetailsCard(item: item),
                if (item.arrival != null) ...[
                  const SizedBox(height: 12),
                  _SummaryCard(item: item),
                ],
                if (item.rating != null) ...[
                  const SizedBox(height: 12),
                  _MyRatingCard(item: item),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: async.valueOrNull == null
            ? null
            : _ActionBar(item: async.valueOrNull!),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────── shared pieces

class _Card extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  const _Card({
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color tileColor;

  const _CardHeader({
    required this.icon,
    required this.title,
    this.iconColor = _blue,
    this.tileColor = _tileBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 10.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _VLine extends StatelessWidget {
  const _VLine();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 64, color: _divider);
}

// ──────────────────────────────────────────────────────────── action bar

class _ActionBar extends ConsumerWidget {
  final RequesterTrip item;
  const _ActionBar({required this.item});

  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({int score, String comment})>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RateDriverDialog(
        driverName: item.trip.driver.fullName,
        ticketNumber: item.trip.ticketNumber,
      ),
    );
    if (result == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(requesterTripRepositoryProvider).rateDriver(
        item.id,
        score: result.score,
        comment: result.comment,
      );
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      refreshMyTrips(ref, tripId: item.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! Your rating was sent to the driver.'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (_) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send your rating. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!item.canRate && !item.canPrint) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              if (item.canRate) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rate(context, ref),
                    icon: const Icon(Icons.star_rounded, color: _navy),
                    label: const Text(
                      'Rate Driver',
                      style: TextStyle(
                          color: _navy, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _amber,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (item.canPrint) const SizedBox(width: 12),
              ],
              if (item.canPrint)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => printTripTicket(context, ref, item.id),
                    icon: const Icon(Icons.print_rounded, color: Colors.white),
                    label: const Text(
                      'Print Ticket',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

// ────────────────────────────────────────────────────────── status card

/// Where the trip is in the chain, as a row of five steps.
class _StatusCard extends StatelessWidget {
  final RequesterTrip item;
  const _StatusCard({required this.item});

  static const _steps = ['Submitted', 'Admin', 'Head Driver', 'Driver', 'Done'];

  IconData get _icon {
    final name = item.status.name.toLowerCase();
    if (name.contains('reject')) return Icons.close_rounded;
    if (name.contains('declin')) return Icons.swap_horiz_rounded;
    if (name.contains('complet')) return Icons.flag_rounded;
    if (name.contains('pend') || name.contains('submit')) {
      return Icons.hourglass_top_rounded;
    }
    return Icons.check_rounded;
  }

  String get _subtitle {
    final name = item.status.name.toLowerCase();
    if (name.contains('reject')) return 'Your trip request was not approved.';
    if (name.contains('complet')) return 'Your trip has been completed.';
    if (name.contains('declin')) return 'A new driver is being assigned.';
    if (name.contains('pend') || name.contains('submit')) {
      return 'Your trip is waiting for approval.';
    }
    return 'Your trip is ${item.statusLabel.toLowerCase()}.';
  }

  @override
  Widget build(BuildContext context) {
    final step = item.progressStep;
    final color = item.statusColor;

    return _Card(
      color: const Color(0xFFE4EEFD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.statusLabel,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (item.trip.isUrgent)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active, size: 13, color: _navy),
                      SizedBox(width: 4),
                      Text(
                        'URGENT',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (step >= 0) ...[
            const SizedBox(height: 18),
            Row(
              children: List.generate(_steps.length, (index) {
                final done = index < step;
                final current = index == step;
                final leftActive = index <= step && index != 0;
                final rightActive = index < step;

                return Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2.5,
                              color: index == 0
                                  ? Colors.transparent
                                  : (leftActive ? _blue : _grey),
                            ),
                          ),
                          _StepDot(done: done, current: current),
                          Expanded(
                            child: Container(
                              height: 2.5,
                              color: index == _steps.length - 1
                                  ? Colors.transparent
                                  : (rightActive ? _blue : _grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _steps[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: current
                              ? _blue
                              : done
                              ? _navy
                              : _muted,
                          fontSize: 10.5,
                          fontWeight:
                          current ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
          if (item.status == AdminTripStatus.driverDeclined) ...[
            const SizedBox(height: 12),
            const Text(
              'The assigned driver could not take this trip. The head driver is '
                  'assigning someone else — your approval still stands.',
              style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool done;
  final bool current;
  const _StepDot({required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
      );
    }
    if (current) {
      return Container(
        width: 24,
        height: 24,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _blue, width: 2.5),
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(color: _blue, shape: BoxShape.circle),
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _grey, width: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── rejected

class _RejectedCard extends StatelessWidget {
  final RequesterTrip item;
  const _RejectedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel, color: _red, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why it was rejected',
                  style: TextStyle(
                    color: _red,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.rejectedReason ?? 'No reason was given.',
                  style: const TextStyle(
                      color: _navy, fontSize: 13.5, height: 1.4),
                ),
                if (item.rejectedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _dateTime.format(item.rejectedAt!),
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── driver

class _DriverCard extends StatelessWidget {
  final RequesterTrip item;
  const _DriverCard({required this.item});

  String get _initials {
    final parts = item.trip.driver.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    final ok = await canLaunchUrl(uri) && await launchUrl(uri);
    if (!ok && context.mounted) {
      Clipboard.setData(ClipboardData(text: number));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start a call. Number copied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = item.trip.driver;
    final hasContact = driver.contact.trim().isNotEmpty;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.person, title: 'Driver Information'),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _tileBg,
                      ),
                      child: CircleAvatar(
                        backgroundColor: _navy,
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 3,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.isHeadDriver
                          ? '${driver.fullName} (Head Driver)'
                          : driver.fullName,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.trip.vehicleModel} - ${item.trip.vehiclePlate}',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                    if (hasContact)
                      Text(
                        driver.contact,
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                  ],
                ),
              ),
              if (hasContact)
                Material(
                  color: _tileBg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _call(context, driver.contact),
                    child: const SizedBox(
                      width: 62,
                      height: 58,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: _blue, size: 22),
                          SizedBox(height: 3),
                          Text(
                            'Call',
                            style: TextStyle(
                              color: _blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── schedule

class _ScheduleCard extends StatelessWidget {
  final RequesterTrip item;
  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.access_time_filled,
            title: 'Schedule & Distance',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricColumn(
                icon: Icons.schedule,
                iconColor: _amber,
                value: trip.departureLabel,
                label: 'DEPARTURE',
              ),
              const _VLine(),
              _MetricColumn(
                icon: Icons.schedule,
                iconColor: _blue,
                value: trip.endTimeLabel,
                label: trip.isWaitMode ? 'RETURN' : 'PICK UP',
              ),
              const _VLine(),
              _MetricColumn(
                icon: Icons.explore_outlined,
                iconColor: _muted,
                value: item.arrival == null
                    ? '—'
                    : '${item.arrival!.distanceTraveledKm.toStringAsFixed(0)} km',
                label: 'DISTANCE',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────── route

class _RouteCard extends StatelessWidget {
  final AdminTripModel trip;
  const _RouteCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final stops = trip.stops;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.map, title: 'Route'),
          const SizedBox(height: 14),
          for (int i = 0; i < stops.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 24,
                          color: stops[i].type == 'ORIGIN'
                              ? _blue
                              : stops[i].type == 'DESTINATION'
                              ? _amber
                              : _muted,
                        ),
                        if (i != stops.length - 1)
                          const Expanded(child: _DashedLine()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 2, bottom: i == stops.length - 1 ? 0 : 14),
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
                              color: _muted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            stops[i].address,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
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
    );
  }
}

/// Vertical dashed connector between route stops.
///
/// Drawn with CustomPaint (not LayoutBuilder) because it sits inside an
/// IntrinsicHeight, and LayoutBuilder can't report intrinsic sizes.
class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 2,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0, gap = 4.0;
    final paint = Paint()
      ..color = _blue.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double y = 4; // small gap under the pin
    final x = size.width / 2;
    while (y + dash <= size.height - 2) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────────────────────────────────────────────── details

class _DetailsCard extends StatelessWidget {
  final RequesterTrip item;
  const _DetailsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
    final rows = <(IconData, String, String, Color)>[
      (Icons.calendar_month_outlined, 'Date', _fullDate.format(trip.date), _muted),
      (Icons.work_outline, 'Service', trip.serviceModeLabel, _muted),
      (Icons.assignment_outlined, 'Purpose', trip.purpose, _muted),
      (Icons.apartment, 'Department', trip.departmentName, _muted),
      (Icons.groups_outlined, 'Passengers', trip.passengersLabel, _muted),
      (Icons.schedule, 'Submitted', trip.requestedOnLabel, _muted),
      if (trip.isUrgent)
        (Icons.warning_rounded, 'Urgent Reason', trip.urgentReason ?? '—', _amber),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.description, title: 'Trip Details'),
          const SizedBox(height: 8),
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(rows[i].$1, size: 18, color: rows[i].$4),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 104,
                    child: Text(
                      rows[i].$2,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rows[i].$3,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, thickness: 1, color: _divider),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── summary

/// Only shown once the driver has recorded the return.
class _SummaryCard extends StatelessWidget {
  final RequesterTrip item;
  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final r = item.arrival!;
    final d = item.departure;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.flag_rounded,
            title: 'Trip Summary',
            iconColor: _green,
            tileColor: Color(0xFFDDF3E6),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricColumn(
                icon: Icons.logout_rounded,
                iconColor: _amber,
                value: d == null ? '—' : _dateTime.format(d.departureTime),
                label: 'LEFT GARAGE',
              ),
              const _VLine(),
              _MetricColumn(
                icon: Icons.login_rounded,
                iconColor: _green,
                value: _dateTime.format(r.arrivalTime),
                label: 'BACK',
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: _divider),
          const SizedBox(height: 10),
          Row(
            children: [
              _MetricColumn(
                icon: Icons.route_outlined,
                iconColor: _blue,
                value: '${r.distanceTraveledKm.toStringAsFixed(0)} km',
                label: 'DISTANCE',
              ),
              const _VLine(),
              _MetricColumn(
                icon: Icons.local_gas_station_outlined,
                iconColor: _amber,
                value: '${r.gasolineUsedLiters.toStringAsFixed(1)} L',
                label: 'FUEL USED',
              ),
            ],
          ),
          if (r.remarks != null && r.remarks!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _pageBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Driver's remarks: ${r.remarks}",
                style: const TextStyle(color: _muted, fontSize: 12.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────── rating

class _MyRatingCard extends StatelessWidget {
  final RequesterTrip item;
  const _MyRatingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rating = item.rating!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.star_rounded,
            title: 'Your Rating',
            iconColor: _amber,
            tileColor: Color(0xFFFFF3D1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                5,
                    (i) => Icon(
                  i < rating.score
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${rating.score}/5',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${rating.comment}"',
              style: const TextStyle(
                color: _muted,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}