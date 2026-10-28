// features/admin/data/models/location_model.dart

/// A destination the requester can pick, with its one-way travel time from
/// the Katipunan base. That travel time is what the overlap check uses to
/// work out how long a driver is on the road.
///
/// The coordinates are the geofence: when a tracked vehicle settles inside
/// [radiusMeters] of them during a trip, the server records the arrival
/// time so the driver never types it.
class AdminLocationModel {
  final String id;
  final String name;
  final int travelMinutes;
  final bool isActive;

  /// How many trip stops reference this location. Computed by the backend.
  /// A location with any usage cannot be deleted, only deactivated.
  final int usedInStops;

  /// All three are null until an admin sets them. Geofencing is skipped
  /// for a destination without coordinates — the driver types the times
  /// as before.
  final double? latitude;
  final double? longitude;
  final int? radiusMeters;

  const AdminLocationModel({
    required this.id,
    required this.name,
    required this.travelMinutes,
    required this.isActive,
    required this.usedInStops,
    this.latitude,
    this.longitude,
    this.radiusMeters,
  });

  factory AdminLocationModel.fromJson(Map<String, dynamic> json) {
    return AdminLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      travelMinutes: (json['travelMinutes'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      usedInStops: (json['usedInStops'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toInt(),
    );
  }

  bool get canDelete => usedInStops == 0;

  /// Both coordinates are required for a fence; a radius alone is useless
  /// and the backend defaults it to 150 m when left blank.
  bool get hasGeofence => latitude != null && longitude != null;

  String get geofenceLabel {
    if (!hasGeofence) return 'No geofence';
    final radius = radiusMeters ?? 150;
    return '${latitude!.toStringAsFixed(4)}, '
        '${longitude!.toStringAsFixed(4)} · ${radius}m';
  }

  /// "45 min", "1h", "2h 30m" — minutes alone get hard to read past an hour.
  String get travelLabel {
    if (travelMinutes < 60) return '$travelMinutes min';
    final hours = travelMinutes ~/ 60;
    final minutes = travelMinutes % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String get usageLabel {
    if (usedInStops == 0) return 'Never used';
    return usedInStops == 1 ? 'Used in 1 trip' : 'Used in $usedInStops trips';
  }
}