// features/admin/data/models/location_model.dart

/// A destination the requester can pick, with its one-way travel time from
/// the Katipunan base. That travel time is what the overlap check uses to
/// work out how long a driver is on the road.
class AdminLocationModel {
  final String id;
  final String name;
  final int travelMinutes;
  final bool isActive;

  /// How many trip stops reference this location. Computed by the backend.
  /// A location with any usage cannot be deleted, only deactivated.
  final int usedInStops;

  const AdminLocationModel({
    required this.id,
    required this.name,
    required this.travelMinutes,
    required this.isActive,
    required this.usedInStops,
  });

  factory AdminLocationModel.fromJson(Map<String, dynamic> json) {
    return AdminLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      travelMinutes: (json['travelMinutes'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      usedInStops: (json['usedInStops'] as num?)?.toInt() ?? 0,
    );
  }

  bool get canDelete => usedInStops == 0;

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