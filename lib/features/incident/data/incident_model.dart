// features/incident/data/incident_model.dart
//
// Shared by the admin table, the driver's report form and the
// requester's. One copy, in its own feature folder, because all three
// apps read the same endpoint.

import 'package:latlong2/latlong.dart';

// Prisma sends a Float of 8.0 as the JSON literal `8`, which Dart decodes
// as an int — `as double` would throw on exactly the round coordinates
// you meet first in testing. Everything numeric goes through `num`.
double? _double(dynamic v) => (v as num?)?.toDouble();

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.parse(v as String).toLocal();

/// Turns BREAKDOWN into "Breakdown", LATE_PICKUP into "Late pickup".
String prettify(String raw) {
  if (raw.isEmpty) return raw;
  final words = raw.toLowerCase().split('_');
  final first = words.first;
  return [
    first[0].toUpperCase() + first.substring(1),
    ...words.skip(1),
  ].join(' ');
}

enum IncidentSeverity { minor, moderate, major }

extension IncidentSeverityX on IncidentSeverity {
  static IncidentSeverity fromBackend(String value) => switch (value) {
    'MAJOR' => IncidentSeverity.major,
    'MODERATE' => IncidentSeverity.moderate,
    _ => IncidentSeverity.minor,
  };

  String get backendValue => switch (this) {
    IncidentSeverity.major => 'MAJOR',
    IncidentSeverity.moderate => 'MODERATE',
    IncidentSeverity.minor => 'MINOR',
  };

  String get label => switch (this) {
    IncidentSeverity.major => 'Major',
    IncidentSeverity.moderate => 'Moderate',
    IncidentSeverity.minor => 'Minor',
  };
}

enum IncidentStatus { open, underReview, resolved, dismissed }

extension IncidentStatusX on IncidentStatus {
  static IncidentStatus fromBackend(String value) => switch (value) {
    'UNDER_REVIEW' => IncidentStatus.underReview,
    'RESOLVED' => IncidentStatus.resolved,
    'DISMISSED' => IncidentStatus.dismissed,
    _ => IncidentStatus.open,
  };

  String get backendValue => switch (this) {
    IncidentStatus.underReview => 'UNDER_REVIEW',
    IncidentStatus.resolved => 'RESOLVED',
    IncidentStatus.dismissed => 'DISMISSED',
    IncidentStatus.open => 'OPEN',
  };

  String get label => switch (this) {
    IncidentStatus.underReview => 'Under review',
    IncidentStatus.resolved => 'Resolved',
    IncidentStatus.dismissed => 'Dismissed',
    IncidentStatus.open => 'Open',
  };

  /// Open and under-review still need someone to act.
  bool get isLive =>
      this == IncidentStatus.open || this == IncidentStatus.underReview;
}

/// A person named on an incident — reporter, driver or reviewer.
class IncidentPerson {
  final String id;
  final String fullName;
  final String? phone;
  final String? role;

  const IncidentPerson({
    required this.id,
    required this.fullName,
    this.phone,
    this.role,
  });

  static IncidentPerson? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return IncidentPerson(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '—',
      phone: json['phone'] as String?,
      role: json['role'] as String?,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class IncidentVehicle {
  final String id;
  final String model;
  final String plateNumber;
  final String status;

  const IncidentVehicle({
    required this.id,
    required this.model,
    required this.plateNumber,
    required this.status,
  });

  static IncidentVehicle? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return IncidentVehicle(
      id: json['id'] as String,
      model: json['model'] as String,
      plateNumber: json['plateNumber'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  String get label => '$model ($plateNumber)';
}

class IncidentTrip {
  final String id;
  final String ticketNumber;
  final String status;
  final DateTime? date;

  const IncidentTrip({
    required this.id,
    required this.ticketNumber,
    required this.status,
    this.date,
  });

  static IncidentTrip? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return IncidentTrip(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      status: json['status'] as String? ?? '',
      date: _date(json['date']),
    );
  }
}

class IncidentModel {
  final String id;
  final String incidentNumber;

  final IncidentTrip? trip;
  final IncidentVehicle? vehicle;

  /// Who the incident is ABOUT. Not the same person as [reportedBy] when
  /// a passenger files a complaint — which is the whole point of
  /// incidentCount.
  final IncidentPerson? driver;
  final IncidentPerson reportedBy;

  final String type;
  final IncidentSeverity severity;
  final IncidentStatus status;

  final DateTime occurredAt;
  final String description;

  final String? locationText;
  final double? latitude;
  final double? longitude;

  /// "GPS" when the tracker filled this in, "MANUAL" when a person did.
  final String? locationSource;

  final List<String> photoUrls;

  final IncidentPerson? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolution;

  final DateTime? countedAgainstDriverAt;
  final DateTime? vehicleFlaggedAt;

  final DateTime createdAt;

  const IncidentModel({
    required this.id,
    required this.incidentNumber,
    required this.reportedBy,
    required this.type,
    required this.severity,
    required this.status,
    required this.occurredAt,
    required this.description,
    required this.photoUrls,
    required this.createdAt,
    this.trip,
    this.vehicle,
    this.driver,
    this.locationText,
    this.latitude,
    this.longitude,
    this.locationSource,
    this.reviewedBy,
    this.reviewedAt,
    this.resolution,
    this.countedAgainstDriverAt,
    this.vehicleFlaggedAt,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photoUrls'] as List<dynamic>? ?? const [];

    return IncidentModel(
      id: json['id'] as String,
      incidentNumber: json['incidentNumber'] as String,
      trip: IncidentTrip.fromJson(json['tripRequest'] as Map<String, dynamic>?),
      vehicle:
      IncidentVehicle.fromJson(json['vehicle'] as Map<String, dynamic>?),
      driver: IncidentPerson.fromJson(json['driver'] as Map<String, dynamic>?),
      reportedBy:
      IncidentPerson.fromJson(json['reportedBy'] as Map<String, dynamic>)!,
      type: json['type'] as String,
      severity: IncidentSeverityX.fromBackend(json['severity'] as String),
      status: IncidentStatusX.fromBackend(json['status'] as String),
      occurredAt: _date(json['occurredAt'])!,
      description: json['description'] as String,
      locationText: json['locationText'] as String?,
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      locationSource: json['locationSource'] as String?,
      photoUrls: rawPhotos.map((e) => e as String).toList(),
      reviewedBy:
      IncidentPerson.fromJson(json['reviewedBy'] as Map<String, dynamic>?),
      reviewedAt: _date(json['reviewedAt']),
      resolution: json['resolution'] as String?,
      countedAgainstDriverAt: _date(json['countedAgainstDriverAt']),
      vehicleFlaggedAt: _date(json['vehicleFlaggedAt']),
      createdAt: _date(json['createdAt']) ?? DateTime.now(),
    );
  }

  String get typeLabel => prettify(type);

  bool get hasPosition => latitude != null && longitude != null;

  LatLng? get position =>
      hasPosition ? LatLng(latitude!, longitude!) : null;

  /// True when the tracker supplied the coordinates rather than a person.
  bool get locatedByGps => locationSource == 'GPS';

  bool get isClosed =>
      status == IncidentStatus.resolved || status == IncidentStatus.dismissed;
}

/// What GET /api/incidents/options returns — the types *this* user may
/// report. Driver and requester get different lists, and the form asks
/// the server rather than carrying its own copy to drift.
class IncidentOptions {
  final List<String> types;
  final List<String> severities;
  final int maxPhotos;

  const IncidentOptions({
    required this.types,
    required this.severities,
    required this.maxPhotos,
  });

  factory IncidentOptions.fromJson(Map<String, dynamic> json) {
    return IncidentOptions(
      types: (json['types'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      severities: (json['severities'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      maxPhotos: (json['maxPhotos'] as num?)?.toInt() ?? 3,
    );
  }
}