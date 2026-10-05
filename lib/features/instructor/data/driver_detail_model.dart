// features/instructor/trip_ticket/data/driver_detail_model.dart

import '../trip_ticket/data/fleet_models.dart';

/// A vehicle this driver is assigned to, as shown at the bottom of the
/// detail screen.
class AssignedVehicle {
  final String id;
  final String model;
  final String plateNumber;
  final String type;
  final String? imageUrl;
  final String status; // raw backend VehicleStatus
  final bool isPrimary;

  const AssignedVehicle({
    required this.id,
    required this.model,
    required this.plateNumber,
    required this.type,
    required this.status,
    required this.isPrimary,
    this.imageUrl,
  });

  factory AssignedVehicle.fromJson(Map<String, dynamic> json) {
    return AssignedVehicle(
      id: json['id'] as String,
      model: json['model'] as String,
      plateNumber: json['plateNumber'] as String,
      type: json['type'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        return 'Available';
      case 'ON_TRIP':
        return 'On trip';
      case 'MAINTENANCE':
        return 'Maintenance';
      default:
        return 'Not in service';
    }
  }

  String get rankLabel => isPrimary ? 'Primary' : 'Secondary';
}

/// The full driver record behind the requester's detail screen.
///
/// Home address is not part of this — the backend never sends it.
class DriverDetailModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role;

  final String? driverCode;
  final String? employeeId;
  final DriverDirectoryStatus status;
  final DateTime? dateHired;

  final int completedTrips;
  final double kilometresDriven;
  final int incidentCount;

  /// Null when no departure has ever been recorded — distinct from 0%.
  final int? onTimePercentage;

  final double? averageRating;
  final int ratingCount;

  final List<AssignedVehicle> assignedVehicles;

  const DriverDetailModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.completedTrips,
    required this.kilometresDriven,
    required this.incidentCount,
    required this.ratingCount,
    required this.assignedVehicles,
    this.phone,
    this.avatarUrl,
    this.driverCode,
    this.employeeId,
    this.dateHired,
    this.onTimePercentage,
    this.averageRating,
  });

  factory DriverDetailModel.fromJson(Map<String, dynamic> json) {
    final vehicles = json['assignedVehicles'] as List<dynamic>? ?? const [];

    return DriverDetailModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'DRIVER',
      driverCode: json['driverCode'] as String?,
      employeeId: json['employeeId'] as String?,
      status: DriverDirectoryStatusX.fromApi(json['status'] as String?),
      dateHired: json['dateHired'] == null
          ? null
          : DateTime.parse(json['dateHired'] as String).toLocal(),
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      kilometresDriven: (json['kilometresDriven'] as num?)?.toDouble() ?? 0,
      incidentCount: (json['incidentCount'] as num?)?.toInt() ?? 0,
      onTimePercentage: (json['onTimePercentage'] as num?)?.toInt(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      assignedVehicles: vehicles
          .map((e) => AssignedVehicle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isHeadDriver => role == 'HEAD_DRIVER';

  bool get hasRating => averageRating != null && ratingCount > 0;

  String get ratingLabel => hasRating ? averageRating!.toStringAsFixed(1) : '—';

  String get reviewsLabel {
    if (!hasRating) return 'No reviews yet';
    return ratingCount == 1 ? '(1 review)' : '($ratingCount reviews)';
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Whole years since the hire date. Null when no date is recorded.
  int? get yearsOfService {
    if (dateHired == null) return null;
    final now = DateTime.now();
    var years = now.year - dateHired!.year;
    // Subtract a year if the anniversary hasn't come round yet.
    final hadAnniversary = now.month > dateHired!.month ||
        (now.month == dateHired!.month && now.day >= dateHired!.day);
    if (!hadAnniversary) years -= 1;
    return years < 0 ? 0 : years;
  }

  String get experienceLabel {
    final years = yearsOfService;
    if (years == null) return 'New';
    if (years < 1) return 'Under 1yr';
    return years == 1 ? '1yr exp' : '${years}yrs exp';
  }

  String get serviceLabel {
    final years = yearsOfService;
    if (years == null) return '—';
    if (years < 1) return 'Less than a year of service';
    return years == 1 ? '1 year of service' : '$years years of service';
  }

  /// "1,243" — thousands separated, no decimals unless it's a short trip
  /// total where the fraction still means something.
  String get kilometresLabel {
    if (kilometresDriven >= 1000) {
      final whole = kilometresDriven.round().toString();
      final buffer = StringBuffer();
      for (var i = 0; i < whole.length; i++) {
        if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
        buffer.write(whole[i]);
      }
      return buffer.toString();
    }
    return kilometresDriven % 1 == 0
        ? kilometresDriven.toStringAsFixed(0)
        : kilometresDriven.toStringAsFixed(1);
  }

  String get onTimeLabel =>
      onTimePercentage == null ? '—' : '$onTimePercentage%';

  String get tripsChipLabel =>
      completedTrips == 1 ? '1 trip' : '$completedTrips trips';
}