// core/printing/trip_ticket_data.dart
import 'package:intl/intl.dart';

/// Everything the printed JRMSU trip ticket needs, parsed straight from
/// POST /api/trips/:id/print. Kept separate from the screen models so the
/// PDF never depends on which screen opened it.
class TripTicketData {
  final String ticketNumber;
  final DateTime date;
  final DateTime? printedAt;

  final String requesterName;
  final String departmentName;
  final String driverName;
  final String vehiclePlate;
  final String vehicleModel;
  final List<String> passengers;
  final List<String> placesToVisit;
  final String purpose;

  /// The "Approved:" line, from the admin-editable system settings.
  final String? approverName;
  final String approverTitle;

  // Section B — filled from the driver's departure and return logs.
  final DateTime? departureFromGarage;
  final DateTime? arrivedAtDestination;
  final DateTime? departedFromDestination;
  final DateTime? arrivalBackAtGarage;
  final int? odometerStart;
  final int? odometerEnd;
  final double? distanceTraveledKm;
  final double? fuelBalanceInTank;
  final double? fuelIssuedByOffice;
  final double? fuelPurchasedDuring;
  final double? totalAvailableLiters;
  final double? gasolineUsedLiters;
  final double? balanceAtEndLiters;
  final double? gearOilUsedLiters;
  final double? lubricatingOilUsedLiters;
  final double? greaseIssuedLiters;
  final String? remarks;

  const TripTicketData({
    required this.ticketNumber,
    required this.date,
    this.printedAt,
    required this.requesterName,
    required this.departmentName,
    required this.driverName,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.passengers,
    required this.placesToVisit,
    required this.purpose,
    this.approverName,
    required this.approverTitle,
    this.departureFromGarage,
    this.arrivedAtDestination,
    this.departedFromDestination,
    this.arrivalBackAtGarage,
    this.odometerStart,
    this.odometerEnd,
    this.distanceTraveledKm,
    this.fuelBalanceInTank,
    this.fuelIssuedByOffice,
    this.fuelPurchasedDuring,
    this.totalAvailableLiters,
    this.gasolineUsedLiters,
    this.balanceAtEndLiters,
    this.gearOilUsedLiters,
    this.lubricatingOilUsedLiters,
    this.greaseIssuedLiters,
    this.remarks,
  });

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String)?.toLocal();
  static double? _d(dynamic v) => (v as num?)?.toDouble();
  static int? _i(dynamic v) => (v as num?)?.toInt();

  /// [json] is the trip, [approver] the { name, title } block returned by
  /// POST /api/trips/:id/print.
  factory TripTicketData.fromJson(
      Map<String, dynamic> json, {
        Map<String, dynamic>? approver,
      }) {
    final requester = json['requester'] as Map<String, dynamic>?;
    final driver = json['driver'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final department = json['department'] as Map<String, dynamic>?;
    final departure = json['departure'] as Map<String, dynamic>?;
    final arrival = json['arrival'] as Map<String, dynamic>?;

    final stops = (json['stops'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => ((a['order'] as num?) ?? 0).compareTo((b['order'] as num?) ?? 0));

    return TripTicketData(
      ticketNumber: json['ticketNumber'] as String? ?? '—',
      date: _date(json['date']) ?? DateTime.now(),
      printedAt: _date(json['printedAt']),
      requesterName: requester?['fullName'] as String? ?? '—',
      departmentName: department?['name'] as String? ?? '—',
      driverName: driver?['fullName'] as String? ?? '—',
      vehiclePlate: vehicle?['plateNumber'] as String? ?? '—',
      vehicleModel: vehicle?['model'] as String? ?? '—',
      passengers: (json['passengers'] as List<dynamic>? ?? [])
          .map((p) => (p as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      // "Place(s) to be visited" — the origin is base, so it is left out.
      placesToVisit: stops
          .where((s) => s['type'] != 'ORIGIN')
          .map((s) => s['address'] as String? ?? '')
          .where((address) => address.isNotEmpty)
          .toList(),
      purpose: json['purpose'] as String? ?? '—',
      approverName: approver?['name'] as String?,
      approverTitle: approver?['title'] as String? ??
          'Administrative Officer V/GSO Unit Head',
      departureFromGarage: _date(departure?['departureTime']),
      arrivedAtDestination: _date(arrival?['arrivedAtDestination']),
      departedFromDestination: _date(arrival?['departedFromDestination']),
      arrivalBackAtGarage: _date(arrival?['arrivalTime']),
      odometerStart: _i(departure?['odometerStart']),
      odometerEnd: _i(arrival?['odometerEnd']),
      distanceTraveledKm: _d(arrival?['distanceTraveledKm']),
      fuelBalanceInTank: _d(departure?['fuelBalanceInTank']),
      fuelIssuedByOffice: _d(departure?['fuelIssuedByOffice']),
      fuelPurchasedDuring: _d(departure?['fuelPurchasedDuring']),
      totalAvailableLiters: _d(departure?['totalAvailableLiters']),
      gasolineUsedLiters: _d(arrival?['gasolineUsedLiters']),
      balanceAtEndLiters: _d(arrival?['balanceInTankLiters']),
      gearOilUsedLiters: _d(arrival?['gearOilUsedLiters']),
      lubricatingOilUsedLiters: _d(arrival?['lubricatingOilUsedLiters']),
      greaseIssuedLiters: _d(arrival?['greaseIssuedLiters']),
      remarks: arrival?['remarks'] as String?,
    );
  }

  // ----- formatting helpers used by the PDF -----

  static final DateFormat _slashDate = DateFormat('MM/dd/yyyy');
  static final DateFormat _time = DateFormat('h:mm a');

  String get dateLabel => _slashDate.format(date);
  String get printedLabel =>
      printedAt == null ? '' : DateFormat('MMM d, yyyy h:mm a').format(printedAt!);

  String time(DateTime? value) => value == null ? '' : _time.format(value);
  String liters(double? value) => value == null ? '' : value.toStringAsFixed(2);
  String km(num? value) => value == null ? '' : value.toStringAsFixed(0);

  String get passengersLabel =>
      passengers.isEmpty ? requesterName : '$requesterName, ${passengers.join(', ')}';
  String get placesLabel => placesToVisit.join(', ');
}