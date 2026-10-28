// features/admin/data/models/tracking_model.dart
import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// Parsing helpers
// ---------------------------------------------------------------------------
//
// Every number goes through `num` before `.toDouble()`.
//
// Prisma sends a Float of 45.0 as the JSON literal `45`, which Dart decodes
// as an int — so `json['gpsDistanceKm'] as double` throws on exactly the
// round numbers you meet first in testing. `as num` accepts both.

double? _double(dynamic value) => (value as num?)?.toDouble();

int? _int(dynamic value) => (value as num?)?.round();

/// Server timestamps are UTC ISO strings; the admin wants local time.
DateTime? _date(dynamic value) =>
    value == null ? null : DateTime.parse(value as String).toLocal();

// ---------------------------------------------------------------------------
// GET /api/admin/tracking/live
// ---------------------------------------------------------------------------

/// The trip a vehicle is out on right now, as the live endpoint reports it.
class LiveTrip {
  final String id;
  final String ticketNumber;
  final DateTime? departureTime;
  final String? driverName;
  final String? driverPhone;
  final String? destination;

  /// Measured by GPS, not typed by the driver.
  final double? distanceKm;
  final bool hasArrived;

  const LiveTrip({
    required this.id,
    required this.ticketNumber,
    this.departureTime,
    this.driverName,
    this.driverPhone,
    this.destination,
    this.distanceKm,
    this.hasArrived = false,
  });

  factory LiveTrip.fromJson(Map<String, dynamic> json) => LiveTrip(
    id: json['id'] as String,
    ticketNumber: json['ticketNumber'] as String,
    departureTime: _date(json['departureTime']),
    driverName: json['driverName'] as String?,
    driverPhone: json['driverPhone'] as String?,
    destination: json['destination'] as String?,
    distanceKm: _double(json['distanceKm']),
    hasArrived: json['hasArrived'] as bool? ?? false,
  );
}

/// One vehicle's last known position.
///
/// `deviceToken` is never part of this — the server strips it and sends
/// `hasDevice` instead. The token is the tracker's password; it has no
/// business being in a web page's memory.
class LiveVehicle {
  final String id;
  final String model;
  final String plateNumber;
  final String status; // ACTIVE | ON_TRIP | MAINTENANCE | INACTIVE
  final String? imageUrl;
  final bool hasDevice;

  final double? latitude;
  final double? longitude;
  final double? speedKph;
  final DateTime? lastSeenAt;

  /// Nothing heard for 15 minutes: out of signal, or powered down. The map
  /// greys the marker rather than showing a confident dot at a dead fix.
  final bool isStale;

  final LiveTrip? trip;

  const LiveVehicle({
    required this.id,
    required this.model,
    required this.plateNumber,
    required this.status,
    required this.hasDevice,
    required this.isStale,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.speedKph,
    this.lastSeenAt,
    this.trip,
  });

  factory LiveVehicle.fromJson(Map<String, dynamic> json) => LiveVehicle(
    id: json['id'] as String,
    model: json['model'] as String,
    plateNumber: json['plateNumber'] as String,
    status: json['status'] as String,
    imageUrl: json['imageUrl'] as String?,
    hasDevice: json['hasDevice'] as bool? ?? false,
    latitude: _double(json['latitude']),
    longitude: _double(json['longitude']),
    speedKph: _double(json['speedKph']),
    lastSeenAt: _date(json['lastSeenAt']),
    isStale: json['isStale'] as bool? ?? true,
    trip: json['trip'] == null
        ? null
        : LiveTrip.fromJson(json['trip'] as Map<String, dynamic>),
  );

  bool get hasPosition => latitude != null && longitude != null;

  LatLng? get position =>
      hasPosition ? LatLng(latitude!, longitude!) : null;
}

// ---------------------------------------------------------------------------
// GET /api/admin/tracking/trips/:id/track
// ---------------------------------------------------------------------------

class TrackPoint {
  final double latitude;
  final double longitude;
  final double? speedKph;
  final double? headingDeg;

  /// OBD-II only. A Honda BeAT has no port a dongle can talk to, so expect
  /// these to stay null through the motorcycle phase.
  final int? odometerKm;
  final double? fuelLevelPct;

  final DateTime recordedAt;

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.speedKph,
    this.headingDeg,
    this.odometerKm,
    this.fuelLevelPct,
  });

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
    latitude: _double(json['latitude'])!,
    longitude: _double(json['longitude'])!,
    speedKph: _double(json['speedKph']),
    headingDeg: _double(json['headingDeg']),
    odometerKm: _int(json['odometerKm']),
    fuelLevelPct: _double(json['fuelLevelPct']),
    recordedAt: _date(json['recordedAt'])!,
  );

  LatLng get position => LatLng(latitude, longitude);
}

/// The circle the arrival was judged against. Null when the trip's final
/// stop is a hand-typed address, or a destination with no coordinates set
/// yet — in both cases the driver still types the times by hand.
class GeoFence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;

  const GeoFence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory GeoFence.fromJson(Map<String, dynamic> json) => GeoFence(
    id: json['id'] as String,
    name: json['name'] as String,
    latitude: _double(json['latitude'])!,
    longitude: _double(json['longitude'])!,
    radiusMeters: _int(json['radiusMeters']) ?? 150,
  );

  LatLng get center => LatLng(latitude, longitude);
}

/// The figures the trip log form will eventually pre-fill from.
class TrackSummary {
  final int pointCount;
  final double? distanceKm;
  final int? maxSpeedKph;
  final DateTime? firstFixAt;
  final DateTime? lastFixAt;
  final DateTime? arrivedAtDestination;
  final DateTime? departedFromDestination;
  final int? odometerStartKm;
  final int? odometerEndKm;
  final double? fuelStartPct;
  final double? fuelEndPct;

  const TrackSummary({
    required this.pointCount,
    this.distanceKm,
    this.maxSpeedKph,
    this.firstFixAt,
    this.lastFixAt,
    this.arrivedAtDestination,
    this.departedFromDestination,
    this.odometerStartKm,
    this.odometerEndKm,
    this.fuelStartPct,
    this.fuelEndPct,
  });

  factory TrackSummary.fromJson(Map<String, dynamic> json) => TrackSummary(
    pointCount: _int(json['pointCount']) ?? 0,
    distanceKm: _double(json['distanceKm']),
    maxSpeedKph: _int(json['maxSpeedKph']),
    firstFixAt: _date(json['firstFixAt']),
    lastFixAt: _date(json['lastFixAt']),
    arrivedAtDestination: _date(json['arrivedAtDestination']),
    departedFromDestination: _date(json['departedFromDestination']),
    odometerStartKm: _int(json['odometerStartKm']),
    odometerEndKm: _int(json['odometerEndKm']),
    fuelStartPct: _double(json['fuelStartPct']),
    fuelEndPct: _double(json['fuelEndPct']),
  );
}

class TripTrack {
  final String tripId;
  final String ticketNumber;
  final String status;
  final List<TrackPoint> points;
  final GeoFence? fence;
  final TrackSummary summary;

  const TripTrack({
    required this.tripId,
    required this.ticketNumber,
    required this.status,
    required this.points,
    required this.summary,
    this.fence,
  });

  factory TripTrack.fromJson(Map<String, dynamic> json) {
    final trip = json['trip'] as Map<String, dynamic>;
    final rawPoints = json['points'] as List<dynamic>? ?? const [];

    return TripTrack(
      tripId: trip['id'] as String,
      ticketNumber: trip['ticketNumber'] as String,
      status: trip['status'] as String,
      points: rawPoints
          .map((e) => TrackPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      fence: json['fence'] == null
          ? null
          : GeoFence.fromJson(json['fence'] as Map<String, dynamic>),
      summary:
      TrackSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
    );
  }

  List<LatLng> get route => points.map((p) => p.position).toList();
}

// ---------------------------------------------------------------------------

/// What the map dialog actually renders: one vehicle's live position, plus
/// the track of its trip if it has one.
///
/// Both come from one provider so they refresh together — a marker drawn
/// from a newer fix than the polyline it sits on looks like a bug.
class VehicleTrackView {
  final LiveVehicle? live;
  final TripTrack? track;

  const VehicleTrackView({this.live, this.track});

  bool get hasAnything => live?.hasPosition == true || track != null;
}