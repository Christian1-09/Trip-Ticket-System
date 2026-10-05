// features/driver/presentation/NavigateRoutePage/trip_log_forms.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../data/driver_models.dart';
import '../providers/driver_trip_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared bits
// ─────────────────────────────────────────────────────────────────────────────

final _intOnly = FilteringTextInputFormatter.digitsOnly;
final _decimal = FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'));

double? _parseDouble(String text) => double.tryParse(text.trim());
int? _parseInt(String text) => int.tryParse(text.trim());

InputDecoration _decoration(String label, {String? suffix, String? helper}) {
  return InputDecoration(
    labelText: label,
    suffixText: suffix,
    helperText: helper,
    helperMaxLines: 2,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    helperStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
    suffixStyle: const TextStyle(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.cardDeepBlue,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.statusBlue.withOpacity(0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accentYellow),
    ),
  );
}

Widget _computedBox(String label, String value, {Color color = AppColors.accentYellow}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.6)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ),
        Text(value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
      ],
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
          backgroundColor: Colors.redAccent,
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
          backgroundColor: Colors.redAccent,
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
    final trip = widget.item.trip;
    final lastOdometer = widget.item.vehicleOdometer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Record Departure',
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}), // keeps the total live
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${trip.ticketNumber} • ${trip.vehiclePlate} ${trip.vehicleModel}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _odometer,
                keyboardType: TextInputType.number,
                inputFormatters: [_intOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration(
                  'Odometer reading *',
                  suffix: 'km',
                  helper: lastOdometer == null
                      ? 'As shown on the dashboard.'
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
              const SizedBox(height: 20),
              const Text('FUEL',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _balance,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimal],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Already in the tank *', suffix: 'L'),
                validator: _requiredNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _issued,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimal],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Issued by the office', suffix: 'L'),
                validator: _requiredNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purchased,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimal],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Purchased for this trip', suffix: 'L'),
                validator: _requiredNumber,
              ),
              const SizedBox(height: 16),
              _computedBox('Total fuel available', '${_total.toStringAsFixed(2)} L'),
              const SizedBox(height: 8),
              const Text(
                'The departure time is recorded automatically when you save.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save & Depart',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
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
      _isWait ? 'Time of arrival at destination *' : 'Time of drop-off at destination *';
  String get _departedLabel =>
      _isWait ? 'Time of departure from destination *' : 'Time of pick-up from destination *';

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
        SnackBar(content: Text(timeError), backgroundColor: Colors.redAccent),
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
    final trip = widget.item.trip;
    final dep = _departure;

    final end = _parseInt(_odometer.text);
    final left = _parseDouble(_balance.text);
    final distance = end == null ? null : end - dep.odometerStart;
    final used = left == null ? null : dep.totalAvailableLiters - left;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Record Return',
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${trip.ticketNumber} • ${trip.vehiclePlate} ${trip.vehicleModel}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                'At departure: ${dep.odometerStart} km, '
                    '${dep.totalAvailableLiters.toStringAsFixed(1)} L available',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              const Text('TIMES AT THE DESTINATION',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
              const SizedBox(height: 4),
              Text(
                'These two go on the printed trip ticket. The trip left the garage at '
                    '${DateFormat('h:mm a').format(_departure.departureTime)}.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 10),
              _TimePickerField(
                label: _arrivedLabel,
                value: _arrivedAtDestination,
                onTap: _pickArrived,
              ),
              const SizedBox(height: 12),
              _TimePickerField(
                label: _departedLabel,
                value: _departedFromDestination,
                onTap: _pickDeparted,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _odometer,
                keyboardType: TextInputType.number,
                inputFormatters: [_intOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Odometer reading now *', suffix: 'km'),
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
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Fuel left in the tank *', suffix: 'L'),
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
              const SizedBox(height: 16),
              _computedBox(
                'Distance traveled',
                distance == null || distance < 0 ? '—' : '$distance km',
                color: AppColors.statusBlue,
              ),
              const SizedBox(height: 8),
              _computedBox(
                'Fuel used',
                used == null || used < 0 ? '—' : '${used.toStringAsFixed(2)} L',
              ),
              const SizedBox(height: 20),
              const Text('OILS (optional)',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _gearOil,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimal],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Gear oil used', suffix: 'L'),
                validator: _optionalNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lubricating,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimal],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Lubricating oil used', suffix: 'L'),
                validator: _optionalNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _grease,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimal],
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Grease issued', suffix: 'L'),
                validator: _optionalNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarks,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Remarks'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save & Complete Trip',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Read-only field that opens a time picker — used for the two destination
/// times on the return form.
class _TimePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value == null
                ? AppColors.statusBlue.withOpacity(0.4)
                : AppColors.accentYellow.withOpacity(0.8),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.statusBlue, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
            Text(
              value == null ? 'Set time' : DateFormat('h:mm a').format(value!),
              style: TextStyle(
                color: value == null ? Colors.white38 : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}