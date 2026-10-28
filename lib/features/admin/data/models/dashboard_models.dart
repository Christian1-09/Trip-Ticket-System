// features/admin/data/models/dashboard_models.dart
import 'package:flutter/material.dart';

/// A fixed palette so the same department keeps the same colour across the
/// bar chart, the doughnut and its legend. Colours come from the position
/// in the list, which the backend sorts by trip count.
const List<Color> kChartPalette = [
  Color(0xFF2563EB), // blue
  Color(0xFF60A5FA), // light blue
  Color(0xFFFBBF24), // amber
  Color(0xFF22C55E), // green
  Color(0xFFA855F7), // purple
  Color(0xFFEF4444), // red
  Color(0xFF14B8A6), // teal
  Color(0xFFF97316), // orange
];

Color paletteColor(int index) => kChartPalette[index % kChartPalette.length];

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class AdminStatCardModel {
  final String label;
  final String value;
  final String? subtext;
  final IconData icon;
  final Color color;

  const AdminStatCardModel({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtext,
  });
}

class DepartmentTripModel {
  final String department; // the short code, for chart labels
  final String name;
  final int tripCount;
  final Color color;

  const DepartmentTripModel({
    required this.department,
    required this.name,
    required this.tripCount,
    required this.color,
  });

  factory DepartmentTripModel.fromJson(Map<String, dynamic> json, int index) =>
      DepartmentTripModel(
        department: json['code'] as String? ?? '—',
        name: json['name'] as String? ?? 'Unknown',
        tripCount: (json['tripCount'] as num?)?.toInt() ?? 0,
        color: paletteColor(index),
      );
}

class AdminDashboard {
  final int todayTotal;
  final int pendingToday;
  final int ongoingNow;
  final int inProgress;

  final int totalTrips;
  final int completedTrips;
  final int rejectedTrips;
  final int activeVehicles;
  final int totalVehicles;
  final int approvedDrivers;
  final int pendingDrivers;
  final double? averageRating;
  final int ratingCount;

  final List<DepartmentTripModel> departmentTrips;

  const AdminDashboard({
    required this.todayTotal,
    required this.pendingToday,
    required this.ongoingNow,
    required this.inProgress,
    required this.totalTrips,
    required this.completedTrips,
    required this.rejectedTrips,
    required this.activeVehicles,
    required this.totalVehicles,
    required this.approvedDrivers,
    required this.pendingDrivers,
    this.averageRating,
    required this.ratingCount,
    required this.departmentTrips,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    final overview = json['overview'] as Map<String, dynamic>? ?? {};
    final cards = json['cards'] as Map<String, dynamic>? ?? {};
    final departments = json['departmentTrips'] as List<dynamic>? ?? [];

    int n(Map<String, dynamic> map, String key) => (map[key] as num?)?.toInt() ?? 0;

    return AdminDashboard(
      todayTotal: n(overview, 'todayTotal'),
      pendingToday: n(overview, 'pendingToday'),
      ongoingNow: n(overview, 'ongoingNow'),
      inProgress: n(overview, 'inProgress'),
      totalTrips: n(cards, 'totalTrips'),
      completedTrips: n(cards, 'completedTrips'),
      rejectedTrips: n(cards, 'rejectedTrips'),
      activeVehicles: n(cards, 'activeVehicles'),
      totalVehicles: n(cards, 'totalVehicles'),
      approvedDrivers: n(cards, 'approvedDrivers'),
      pendingDrivers: n(cards, 'pendingDrivers'),
      averageRating: (cards['averageRating'] as num?)?.toDouble(),
      ratingCount: n(cards, 'ratingCount'),
      departmentTrips: [
        for (var i = 0; i < departments.length; i++)
          DepartmentTripModel.fromJson(departments[i] as Map<String, dynamic>, i),
      ],
    );
  }

  /// The four cards across the top of the dashboard.
  List<AdminStatCardModel> get statCards => [
    AdminStatCardModel(
      label: 'Total Trips',
      value: '$totalTrips',
      subtext: '$completedTrips completed · $rejectedTrips rejected',
      icon: Icons.route_rounded,
      color: const Color(0xFF2563EB),
    ),
    AdminStatCardModel(
      label: 'In Progress',
      value: '$inProgress',
      subtext: '$ongoingNow on the road now',
      icon: Icons.description_rounded,
      color: const Color(0xFFF59E0B),
    ),
    AdminStatCardModel(
      label: 'Vehicles',
      value: '$activeVehicles',
      subtext: 'of $totalVehicles available',
      icon: Icons.directions_car_filled_rounded,
      color: const Color(0xFF4F46E5),
    ),
    AdminStatCardModel(
      label: 'Drivers',
      value: '$approvedDrivers',
      subtext: pendingDrivers > 0
          ? '$pendingDrivers awaiting approval'
          : averageRating == null
          ? 'No ratings yet'
          : '${averageRating!.toStringAsFixed(1)} average rating',
      icon: Icons.people_alt_rounded,
      color: const Color(0xFF16A34A),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Analysis
// ─────────────────────────────────────────────────────────────────────────────

class MonthlyTripModel {
  final String month; // "Sep 26" — already formatted by the backend
  final int total;
  final int completed;
  final int urgent;
  final int faculty;
  final int staff;
  final int ssg;

  const MonthlyTripModel({
    required this.month,
    required this.total,
    required this.completed,
    required this.urgent,
    required this.faculty,
    required this.staff,
    required this.ssg,
  });

  factory MonthlyTripModel.fromJson(Map<String, dynamic> json) {
    int n(String key) => (json[key] as num?)?.toInt() ?? 0;
    return MonthlyTripModel(
      month: json['label'] as String? ?? '—',
      total: n('total'),
      completed: n('completed'),
      urgent: n('urgent'),
      faculty: n('faculty'),
      staff: n('staff'),
      ssg: n('ssg'),
    );
  }
}

class StatusCountModel {
  final String status;
  final int count;
  final Color color;

  const StatusCountModel({
    required this.status,
    required this.count,
    required this.color,
  });

  static const _labels = {
    'PENDING': 'Pending',
    'ADMIN_APPROVED': 'With Head Driver',
    'HEAD_DRIVER_APPROVED': 'With Driver',
    'DRIVER_ACCEPTED': 'Accepted',
    'DRIVER_DECLINED': 'Declined',
    'REJECTED': 'Rejected',
    'ONGOING': 'Ongoing',
    'COMPLETED': 'Completed',
  };

  // Matches the mockup: With Driver blue, Accepted light blue, Pending
  // amber, Rejected red, Completed green.
  static const _colors = {
    'PENDING': Color(0xFFFBBF24),
    'ADMIN_APPROVED': Color(0xFF6366F1),
    'HEAD_DRIVER_APPROVED': Color(0xFF2563EB),
    'DRIVER_ACCEPTED': Color(0xFF60A5FA),
    'DRIVER_DECLINED': Color(0xFFF97316),
    'REJECTED': Color(0xFFEF4444),
    'ONGOING': Color(0xFF14B8A6),
    'COMPLETED': Color(0xFF22C55E),
  };

  factory StatusCountModel.fromJson(Map<String, dynamic> json) {
    final raw = json['status'] as String? ?? 'UNKNOWN';
    return StatusCountModel(
      status: _labels[raw] ?? raw,
      count: (json['count'] as num?)?.toInt() ?? 0,
      color: _colors[raw] ?? const Color(0xFF455A64),
    );
  }
}

class DestinationCountModel {
  final String name;
  final int count;

  const DestinationCountModel({required this.name, required this.count});

  factory DestinationCountModel.fromJson(Map<String, dynamic> json) =>
      DestinationCountModel(
        name: json['name'] as String? ?? '—',
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}

class DriverPerformanceModel {
  final String name;
  final int trips;
  final int distanceKm;
  final double? averageRating;
  final int ratingCount;

  const DriverPerformanceModel({
    required this.name,
    required this.trips,
    required this.distanceKm,
    this.averageRating,
    required this.ratingCount,
  });

  factory DriverPerformanceModel.fromJson(Map<String, dynamic> json) =>
      DriverPerformanceModel(
        name: json['name'] as String? ?? '—',
        trips: (json['trips'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toInt() ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      );

  String get ratingLabel =>
      averageRating == null ? '—' : '${averageRating!.toStringAsFixed(1)} ($ratingCount)';
}

class VehicleUsageModel {
  final String label;
  final int trips;
  final int distanceKm;
  final double fuelLiters;
  final double? kmPerLiter;

  const VehicleUsageModel({
    required this.label,
    required this.trips,
    required this.distanceKm,
    required this.fuelLiters,
    this.kmPerLiter,
  });

  factory VehicleUsageModel.fromJson(Map<String, dynamic> json) => VehicleUsageModel(
    label: json['label'] as String? ?? '—',
    trips: (json['trips'] as num?)?.toInt() ?? 0,
    distanceKm: (json['distanceKm'] as num?)?.toInt() ?? 0,
    fuelLiters: (json['fuelLiters'] as num?)?.toDouble() ?? 0,
    kmPerLiter: (json['kmPerLiter'] as num?)?.toDouble(),
  );

  String get efficiencyLabel =>
      kmPerLiter == null ? '—' : '${kmPerLiter!.toStringAsFixed(1)} km/L';
}

class AdminAnalytics {
  final int monthSpan;
  final List<MonthlyTripModel> tripsByMonth;
  final List<StatusCountModel> tripsByStatus;
  final List<DestinationCountModel> topDestinations;
  final List<DriverPerformanceModel> driverPerformance;
  final List<VehicleUsageModel> vehicleUsage;
  final int completedTrips;
  final int distanceKm;
  final double fuelLiters;

  const AdminAnalytics({
    required this.monthSpan,
    required this.tripsByMonth,
    required this.tripsByStatus,
    required this.topDestinations,
    required this.driverPerformance,
    required this.vehicleUsage,
    required this.completedTrips,
    required this.distanceKm,
    required this.fuelLiters,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    List<T> parse<T>(String key, T Function(Map<String, dynamic>) build) =>
        (json[key] as List<dynamic>? ?? [])
            .map((e) => build(e as Map<String, dynamic>))
            .toList();

    final totals = json['totals'] as Map<String, dynamic>? ?? {};

    return AdminAnalytics(
      monthSpan: (json['monthSpan'] as num?)?.toInt() ?? 6,
      tripsByMonth: parse('tripsByMonth', MonthlyTripModel.fromJson),
      tripsByStatus: parse('tripsByStatus', StatusCountModel.fromJson),
      topDestinations: parse('topDestinations', DestinationCountModel.fromJson),
      driverPerformance: parse('driverPerformance', DriverPerformanceModel.fromJson),
      vehicleUsage: parse('vehicleUsage', VehicleUsageModel.fromJson),
      completedTrips: (totals['completedTrips'] as num?)?.toInt() ?? 0,
      distanceKm: (totals['distanceKm'] as num?)?.toInt() ?? 0,
      fuelLiters: (totals['fuelLiters'] as num?)?.toDouble() ?? 0,
    );
  }
}