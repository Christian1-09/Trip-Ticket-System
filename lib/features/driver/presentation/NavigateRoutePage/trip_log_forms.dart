// features/driver/presentation/NavigateRoutePage/trip_log_forms.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../../../core/theme/driver_colors.dart';
import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Light palette (same as TripInformation)
// ────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Shared bits
// ─────────────────────────────────────────────────────────────────────────────

final _intOnly = FilteringTextInputFormatter.digitsOnly;
final _decimal = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

double? _parseDouble(String text) => double.tryParse(text.trim());
int? _parseInt(String text) => int.tryParse(text.trim());

const _inputText = TextStyle(
    color: DriverColors.textDark, fontSize: 15, fontWeight: FontWeight.w600);

InputDecoration _decoration(
    String label, {
      String? suffix,
      String? helper,
      IconData? icon,
    }) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );

  return InputDecoration(
    labelText: label,
    suffixText: suffix,
    helperText: helper,
    helperMaxLines: 2,
    prefixIcon: icon == null ? null : Icon(icon, size: 20, color: DriverColors.primary),
    labelStyle: const TextStyle(color: DriverColors.textMuted, fontSize: 14),
    floatingLabelStyle: const TextStyle(color: DriverColors.primary, fontWeight: FontWeight.w600),
    helperStyle: const TextStyle(color: DriverColors.textMuted, fontSize: 11.5),
    suffixStyle: const TextStyle(color: DriverColors.textMuted, fontWeight: FontWeight.w600),
    filled: true,
    fillColor: DriverColors.field,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: border(DriverColors.border),
    enabledBorder: border(DriverColors.border),
    focusedBorder: border(DriverColors.primary, 1.5),
    errorBorder: border(DriverColors.red),
    focusedErrorBorder: border(DriverColors.red, 1.5),
  );
}

/// White card with a tinted header: [icon] Title  (optional subtitle)
class _FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _FormCard({
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
                            style: const TextStyle(color: DriverColors.textMuted, fontSize: 12)),
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

/// Small coloured tile showing a value worked out from the inputs.
class _ComputedTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ComputedTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: DriverColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(
                          color: DriverColors.textDark, fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue info line (icon + text).
class _Note extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Note(this.text, {this.icon = Icons.info_outline_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DriverColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: DriverColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: DriverColors.primary, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}

/// Trip summary strip shown at the top of both forms.
class _TripStrip extends StatelessWidget {
  final DriverTrip item;
  final List<(IconData, String)> facts;
  const _TripStrip({required this.item, this.facts = const []});

  @override
  Widget build(BuildContext context) {
    final trip = item.trip;
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
            child: const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${trip.vehicleModel} · ${trip.vehiclePlate}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(trip.ticketNumber,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in facts)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(f.$1, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(f.$2,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
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

PreferredSizeWidget _appBar(String title) => AppBar(
  backgroundColor: DriverColors.card,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 1,
  shadowColor: Colors.black12,
  iconTheme: const IconThemeData(color: DriverColors.textDark),
  titleSpacing: 0,
  title: Text(title,
      style: const TextStyle(
          color: DriverColors.textDark, fontSize: 18, fontWeight: FontWeight.w800)),
);

/// White bar pinned to the bottom holding the main button.
Widget _bottomButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
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
            icon: Icon(icon),
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<bool> _submit(
    BuildContext context,
    Future<void> Function() action,
    ) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    await action();
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    return true;
  } on ApiException catch (e) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: DriverColors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: DriverColors.red,
        ),
      );
    }
  }
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Departure
// ─────────────────────────────────────────────────────────────────────────────

/// Odometer and fuel when the vehicle leaves. The departure time is taken
/// from the server clock, and the total fuel is calculated by the server.
class DepartureLogScreen extends ConsumerStatefulWidget {
  final DriverTrip item;
  const DepartureLogScreen({super.key, required this.item});

  @override
  ConsumerState<DepartureLogScreen> createState() => _DepartureLogScreenState();
}

class _DepartureLogScreenState extends ConsumerState<DepartureLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _odometer;
  final _balance = TextEditingController();
  final _issued = TextEditingController(text: '0');
  final _purchased = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    // Pre-filled with the vehicle's last reading — the driver corrects it
    // if the dashboard shows something else.
    _odometer = TextEditingController(text: widget.item.vehicleOdometer?.toString() ?? '');
  }

  @override
  void dispose() {
    _odometer.dispose();
    _balance.dispose();
    _issued.dispose();
    _purchased.dispose();
    super.dispose();
  }

  double get _total =>
      (_parseDouble(_balance.text) ?? 0) +
          (_parseDouble(_issued.text) ?? 0) +
          (_parseDouble(_purchased.text) ?? 0);

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (_parseDouble(value) == null) return 'Enter a number';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await _submit(
      context,
          () => ref.read(driverRepositoryProvider).recordDeparture(
        widget.item.id,
        odometerStart: _parseInt(_odometer.text)!,
        fuelBalanceInTank: _parseDouble(_balance.text)!,
        fuelIssuedByOffice: _parseDouble(_issued.text)!,
        fuelPurchasedDuring: _parseDouble(_purchased.text)!,
      ),
    );
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final lastOdometer = widget.item.vehicleOdometer;

    return Scaffold(
      backgroundColor: DriverColors.bg,
      appBar: _appBar('Record Departure'),
      bottomNavigationBar: _bottomButton(
        label: 'Save & Depart',
        icon: Icons.play_arrow_rounded,
        color: DriverColors.primary,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}), // keeps the total live
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _TripStrip(
              item: widget.item,
              facts: [
                if (lastOdometer != null) (Icons.speed_rounded, 'Last $lastOdometer km'),
              ],
            ),
            const SizedBox(height: 12),
            _FormCard(
              icon: Icons.speed_rounded,
              title: 'Odometer',
              subtitle: 'As shown on the dashboard.',
              child: TextFormField(
                controller: _odometer,
                keyboardType: TextInputType.number,
                inputFormatters: [_intOnly],
                style: _inputText,
                decoration: _decoration(
                  'Odometer reading *',
                  suffix: 'km',
                  icon: Icons.speed_rounded,
                  helper: lastOdometer == null
                      ? null
                      : 'Last recorded: $lastOdometer km. It cannot be lower.',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final value = _parseInt(v);
                  if (value == null) return 'Enter a whole number';
                  if (lastOdometer != null && value < lastOdometer) {
                    return 'Cannot be lower than $lastOdometer km';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              icon: Icons.local_gas_station_rounded,
              title: 'Fuel',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _balance,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Already in the tank *',
                        suffix: 'L', icon: Icons.water_drop_outlined),
                    validator: _requiredNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _issued,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Issued by the office',
                        suffix: 'L', icon: Icons.apartment_rounded),
                    validator: _requiredNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _purchased,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Purchased for this trip',
                        suffix: 'L', icon: Icons.receipt_long_outlined),
                    validator: _requiredNumber,
                  ),
                  const SizedBox(height: 14),
                  _ComputedTile(
                    icon: Icons.local_gas_station_rounded,
                    label: 'Total fuel available',
                    value: '${_total.toStringAsFixed(2)} L',
                    color: DriverColors.yellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Note(
              'The departure time is recorded automatically when you save.',
              icon: Icons.schedule_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Return
// ─────────────────────────────────────────────────────────────────────────────

/// Odometer and fuel left when the vehicle comes back. Distance and fuel
/// used are calculated by the server from these and the departure log.
class ReturnLogScreen extends ConsumerStatefulWidget {
  final DriverTrip item;
  const ReturnLogScreen({super.key, required this.item});

  @override
  ConsumerState<ReturnLogScreen> createState() => _ReturnLogScreenState();
}

class _ReturnLogScreenState extends ConsumerState<ReturnLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometer = TextEditingController();
  final _balance = TextEditingController();
  final _gearOil = TextEditingController();
  final _lubricating = TextEditingController();
  final _grease = TextEditingController();
  final _remarks = TextEditingController();

  // Items 2 and 3 of the printed ticket.
  DateTime? _arrivedAtDestination;
  DateTime? _departedFromDestination;

  @override
  void dispose() {
    _odometer.dispose();
    _balance.dispose();
    _gearOil.dispose();
    _lubricating.dispose();
    _grease.dispose();
    _remarks.dispose();
    super.dispose();
  }

  DepartureLog get _departure => widget.item.departure!;

  /// In WAIT mode the driver stays, so these are arrival at and departure
  /// from the destination. In DROP_AND_PICKUP mode they are the drop-off
  /// and the pick-up. Same two fields, different wording.
  bool get _isWait => widget.item.trip.isWaitMode;
  String get _arrivedLabel =>
      _isWait ? 'Arrival at destination *' : 'Drop-off at destination *';
  String get _departedLabel =>
      _isWait ? 'Departure from destination *' : 'Pick-up from destination *';

  /// Turns a picked clock time into a full DateTime on the trip's day.
  /// A time earlier than [notBefore] rolls to the next day ONLY when that
  /// keeps it in the past — a trip that ran past midnight. Otherwise the
  /// time is simply too early, and _validateTimes says so plainly instead
  /// of silently moving it into the future.
  DateTime _onTripDay(TimeOfDay picked, DateTime notBefore) {
    final base = _departure.departureTime;
    final sameDay = DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
    if (!sameDay.isBefore(notBefore)) return sameDay;

    final nextDay = sameDay.add(const Duration(days: 1));
    return nextDay.isAfter(DateTime.now()) ? sameDay : nextDay;
  }

  /// Same order the server checks: garage -> destination -> destination -> now.
  String? _validateTimes() {
    final arrived = _arrivedAtDestination;
    final departed = _departedFromDestination;
    if (arrived == null || departed == null) return 'Please set both destination times.';

    final left = _departure.departureTime;
    final arrivedLabel = _isWait ? 'arrival at the destination' : 'drop-off';
    final departedLabel = _isWait ? 'departure from the destination' : 'pick-up';

    if (arrived.isBefore(left)) {
      return 'The $arrivedLabel cannot be before the trip left the garage '
          '(${DateFormat('h:mm a').format(left)}).';
    }
    if (departed.isBefore(arrived)) {
      return 'The $departedLabel cannot be before the $arrivedLabel.';
    }
    if (departed.isAfter(DateTime.now())) {
      return 'The $departedLabel cannot be in the future.';
    }
    return null;
  }

  Future<void> _pickArrived() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departure.departureTime),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _arrivedAtDestination = _onTripDay(picked, _departure.departureTime);
      // Keep the pair in order.
      if (_departedFromDestination != null &&
          _departedFromDestination!.isBefore(_arrivedAtDestination!)) {
        _departedFromDestination = null;
      }
    });
  }

  Future<void> _pickDeparted() async {
    if (_arrivedAtDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set the ${_isWait ? 'arrival' : 'drop-off'} time first.')),
      );
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_arrivedAtDestination!),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _departedFromDestination = _onTripDay(picked, _arrivedAtDestination!);
    });
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (_parseDouble(value) == null) return 'Enter a number';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final timeError = _validateTimes();
    if (timeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(timeError), backgroundColor: DriverColors.red),
      );
      return;
    }

    double? optional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : _parseDouble(c.text);

    final ok = await _submit(
      context,
          () => ref.read(driverRepositoryProvider).recordReturn(
        widget.item.id,
        odometerEnd: _parseInt(_odometer.text)!,
        balanceInTankLiters: _parseDouble(_balance.text)!,
        arrivedAtDestination: _arrivedAtDestination!,
        departedFromDestination: _departedFromDestination!,
        gearOilUsedLiters: optional(_gearOil),
        lubricatingOilUsedLiters: optional(_lubricating),
        greaseIssuedLiters: optional(_grease),
        remarks: _remarks.text,
      ),
    );
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dep = _departure;

    final end = _parseInt(_odometer.text);
    final left = _parseDouble(_balance.text);
    final distance = end == null ? null : end - dep.odometerStart;
    final used = left == null ? null : dep.totalAvailableLiters - left;

    return Scaffold(
      backgroundColor: DriverColors.bg,
      appBar: _appBar('Record Return'),
      bottomNavigationBar: _bottomButton(
        label: 'Save & Complete Trip',
        icon: Icons.flag_rounded,
        color: DriverColors.greenDark,
        onPressed: _save,
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _TripStrip(
              item: widget.item,
              facts: [
                (Icons.logout_rounded,
                'Left ${DateFormat('h:mm a').format(dep.departureTime)}'),
                (Icons.speed_rounded, '${dep.odometerStart} km'),
                (Icons.local_gas_station_rounded,
                '${dep.totalAvailableLiters.toStringAsFixed(1)} L'),
              ],
            ),
            const SizedBox(height: 12),
            _FormCard(
              icon: Icons.schedule_rounded,
              title: 'Times at the Destination',
              subtitle: 'These two go on the printed trip ticket.',
              child: Column(
                children: [
                  _TimePickerField(
                    label: _arrivedLabel,
                    icon: Icons.login_rounded,
                    value: _arrivedAtDestination,
                    onTap: _pickArrived,
                  ),
                  const SizedBox(height: 10),
                  _TimePickerField(
                    label: _departedLabel,
                    icon: Icons.logout_rounded,
                    value: _departedFromDestination,
                    onTap: _pickDeparted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              icon: Icons.speed_rounded,
              title: 'Odometer & Fuel',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _odometer,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_intOnly],
                    style: _inputText,
                    decoration: _decoration('Odometer reading now *',
                        suffix: 'km', icon: Icons.speed_rounded),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final value = _parseInt(v);
                      if (value == null) return 'Enter a whole number';
                      if (value < dep.odometerStart) {
                        return 'Cannot be lower than ${dep.odometerStart} km';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _balance,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Fuel left in the tank *',
                        suffix: 'L', icon: Icons.water_drop_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final value = _parseDouble(v);
                      if (value == null) return 'Enter a number';
                      if (value > dep.totalAvailableLiters) {
                        return 'Cannot be more than ${dep.totalAvailableLiters.toStringAsFixed(1)} L';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ComputedTile(
                          icon: Icons.route_rounded,
                          label: 'Distance',
                          value: distance == null || distance < 0 ? '—' : '$distance km',
                          color: DriverColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ComputedTile(
                          icon: Icons.local_gas_station_rounded,
                          label: 'Fuel used',
                          value: used == null || used < 0
                              ? '—'
                              : '${used.toStringAsFixed(2)} L',
                          color: DriverColors.yellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              icon: Icons.oil_barrel_outlined,
              title: 'Oils',
              subtitle: 'Optional — leave blank if none were used.',
              child: Column(
                children: [
                  TextFormField(
                    controller: _gearOil,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Gear oil used', suffix: 'L'),
                    validator: _optionalNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lubricating,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Lubricating oil used', suffix: 'L'),
                    validator: _optionalNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _grease,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    style: _inputText,
                    decoration: _decoration('Grease issued', suffix: 'L'),
                    validator: _optionalNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormCard(
              icon: Icons.edit_note_rounded,
              title: 'Remarks',
              child: TextFormField(
                controller: _remarks,
                maxLines: 3,
                style: _inputText,
                decoration: _decoration('Anything to report? (optional)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only field that opens a time picker — used for the two destination
/// times on the return form.
class _TimePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final set = value != null;
    return Material(
      color: set ? DriverColors.primaryLight.withOpacity(0.5) : DriverColors.field,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: set ? DriverColors.primary : DriverColors.border, width: set ? 1.3 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: DriverColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: DriverColors.textDark, fontSize: 13.5, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: set ? DriverColors.primary : DriverColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: set ? null : Border.all(color: DriverColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14, color: set ? Colors.white : DriverColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      set ? DateFormat('h:mm a').format(value!) : 'Set time',
                      style: TextStyle(
                        color: set ? Colors.white : DriverColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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