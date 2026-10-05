// features/driver/data/driver_models.dart
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.tryParse(value as String)?.toLocal();

double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;
double? _doubleOrNull(dynamic value) => (value as num?)?.toDouble();

/// Recorded once, when the vehicle leaves. totalAvailableLiters is
/// calculated by the server, never typed.
class DepartureLog {
  final DateTime departureTime;
  final int odometerStart;
  final double fuelBalanceInTank;
  final double fuelIssuedByOffice;
  final double fuelPurchasedDuring;
  final double totalAvailableLiters;

  const DepartureLog({
    required this.departureTime,
    required this.odometerStart,
    required this.fuelBalanceInTank,
    required this.fuelIssuedByOffice,
    required this.fuelPurchasedDuring,
    required this.totalAvailableLiters,
  });

  factory DepartureLog.fromJson(Map<String, dynamic> json) => DepartureLog(
    departureTime: _date(json['departureTime']) ?? DateTime.now(),
    odometerStart: (json['odometerStart'] as num?)?.toInt() ?? 0,
    fuelBalanceInTank: _double(json['fuelBalanceInTank']),
    fuelIssuedByOffice: _double(json['fuelIssuedByOffice']),
    fuelPurchasedDuring: _double(json['fuelPurchasedDuring']),
    totalAvailableLiters: _double(json['totalAvailableLiters']),
  );
}

/// Recorded once, when the vehicle comes back. distanceTraveledKm and
/// gasolineUsedLiters are calculated by the server, never typed.
class ReturnLog {
  final DateTime arrivalTime;
  final int odometerEnd;
  final double distanceTraveledKm;
  final double gasolineUsedLiters;
  final double balanceInTankLiters;
  final double? gearOilUsedLiters;
  final double? lubricatingOilUsedLiters;
  final double? greaseIssuedLiters;
  final String? remarks;

  /// Items 2 and 3 of the printed ticket: arrival at / departure from the
  /// destination (drop-off / pick-up in DROP_AND_PICKUP mode).
  final DateTime? arrivedAtDestination;
  final DateTime? departedFromDestination;

  const ReturnLog({
    required this.arrivalTime,
    required this.odometerEnd,
    required this.distanceTraveledKm,
    required this.gasolineUsedLiters,
    required this.balanceInTankLiters,
    this.arrivedAtDestination,
    this.departedFromDestination,
    this.gearOilUsedLiters,
    this.lubricatingOilUsedLiters,
    this.greaseIssuedLiters,
    this.remarks,
  });

  factory ReturnLog.fromJson(Map<String, dynamic> json) => ReturnLog(
    arrivalTime: _date(json['arrivalTime']) ?? DateTime.now(),
    odometerEnd: (json['odometerEnd'] as num?)?.toInt() ?? 0,
    distanceTraveledKm: _double(json['distanceTraveledKm']),
    gasolineUsedLiters: _double(json['gasolineUsedLiters']),
    balanceInTankLiters: _double(json['balanceInTankLiters']),
    gearOilUsedLiters: _doubleOrNull(json['gearOilUsedLiters']),
    lubricatingOilUsedLiters: _doubleOrNull(json['lubricatingOilUsedLiters']),
    greaseIssuedLiters: _doubleOrNull(json['greaseIssuedLiters']),
    remarks: json['remarks'] as String?,
    arrivedAtDestination: _date(json['arrivedAtDestination']),
    departedFromDestination: _date(json['departedFromDestination']),
  );
}

/// A trip as the assigned driver sees it. The trip fields have the same
/// JSON shape as the Admin's, so AdminTripModel is reused.
class DriverTrip {
  final AdminTripModel trip;
  final DateTime? adminApprovedAt;
  final DateTime? headDriverApprovedAt;
  final DateTime? driverAcceptedAt;
  final int? vehicleOdometer;
  final DepartureLog? departure;
  final ReturnLog? arrival;

  /// Must match DEPART_EARLY_WINDOW_MINUTES in driver.service.js.
  static const Duration departEarlyWindow = Duration(hours: 2);

  const DriverTrip({
    required this.trip,
    this.adminApprovedAt,
    this.headDriverApprovedAt,
    this.driverAcceptedAt,
    this.vehicleOdometer,
    this.departure,
    this.arrival,
  });

  factory DriverTrip.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final departure = json['departure'] as Map<String, dynamic>?;
    final arrival = json['arrival'] as Map<String, dynamic>?;
    return DriverTrip(
      trip: AdminTripModel.fromJson(json),
      adminApprovedAt: _date(json['adminApprovedAt']),
      headDriverApprovedAt: _date(json['headDriverApprovedAt']),
      driverAcceptedAt: _date(json['driverAcceptedAt']),
      vehicleOdometer: (vehicle?['odometerCurrent'] as num?)?.toInt(),
      departure: departure == null ? null : DepartureLog.fromJson(departure),
      arrival: arrival == null ? null : ReturnLog.fromJson(arrival),
    );
  }

  String get id => trip.id;
  AdminTripStatus get status => trip.status;

  bool get canAccept => status == AdminTripStatus.headDriverApproved;
  bool get canDecline =>
      status == AdminTripStatus.headDriverApproved ||
          status == AdminTripStatus.driverAccepted;
  bool get canDepart => status == AdminTripStatus.driverAccepted;
  bool get canReturn => status == AdminTripStatus.ongoing;

  DateTime get departWindowOpensAt => trip.departureTime.subtract(departEarlyWindow);
  bool get isTooEarlyToDepart => DateTime.now().isBefore(departWindowOpensAt);

  /// Status from the driver's point of view.
  String get driverStatusLabel {
    switch (status) {
      case AdminTripStatus.headDriverApproved:
        return 'Awaiting your answer';
      case AdminTripStatus.driverAccepted:
        return 'Accepted';
      case AdminTripStatus.ongoing:
        return 'On the road';
      case AdminTripStatus.completed:
        return 'Completed';
      case AdminTripStatus.driverDeclined:
        return 'Declined';
      default:
        return status.label;
    }
  }

  /// When the driver is expected back at base.
  DateTime? get plannedEnd {
    if (trip.isWaitMode) return trip.returnTime;
    if (trip.pickupTime == null) return null;
    return trip.pickupTime!.add(Duration(minutes: trip.maxTravelMinutes));
  }

  Duration? get plannedDuration {
    final end = plannedEnd;
    if (end == null) return null;
    return end.difference(trip.departureTime);
  }

  /// Positive = departed late, negative = early.
  Duration? get departureDelay =>
      departure?.departureTime.difference(trip.departureTime);
}

/// Header and stats for the driver's home screen.
class DriverProfileSummary {
  final String fullName;
  final String role;
  final String? driverCode;
  final String? status;
  final int awaitingCount;
  final int upcomingCount;
  final int ongoingCount;
  final int completedCount;
  final double? averageRating;
  final int ratingCount;

  const DriverProfileSummary({
    required this.fullName,
    required this.role,
    this.driverCode,
    this.status,
    required this.awaitingCount,
    required this.upcomingCount,
    required this.ongoingCount,
    required this.completedCount,
    this.averageRating,
    required this.ratingCount,
  });

  factory DriverProfileSummary.fromJson(Map<String, dynamic> json) => DriverProfileSummary(
    fullName: json['fullName'] as String? ?? '—',
    role: json['role'] as String? ?? 'DRIVER',
    driverCode: json['driverCode'] as String?,
    status: json['status'] as String?,
    awaitingCount: (json['awaitingCount'] as num?)?.toInt() ?? 0,
    upcomingCount: (json['upcomingCount'] as num?)?.toInt() ?? 0,
    ongoingCount: (json['ongoingCount'] as num?)?.toInt() ?? 0,
    completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
    averageRating: _doubleOrNull(json['averageRating']),
    ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  );

  String get ratingLabel =>
      averageRating == null ? 'No ratings yet' : '${averageRating!.toStringAsFixed(1)} Rating';
}