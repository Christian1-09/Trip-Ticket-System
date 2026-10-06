// features/admin/data/models/admin_trip_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The real backend statuses. Replaces the old 3-value enum — "urgent" was
/// never a status, it is the separate [AdminTripModel.isUrgent] flag.
enum AdminTripStatus {
  pending,
  adminApproved,
  headDriverApproved,
  driverAccepted,
  driverDeclined,
  rejected,
  ongoing,
  completed,
  unknown,
}

AdminTripStatus adminTripStatusFrom(String? value) {
  switch (value) {
    case 'PENDING':
      return AdminTripStatus.pending;
    case 'ADMIN_APPROVED':
      return AdminTripStatus.adminApproved;
    case 'HEAD_DRIVER_APPROVED':
      return AdminTripStatus.headDriverApproved;
    case 'DRIVER_ACCEPTED':
      return AdminTripStatus.driverAccepted;
    case 'DRIVER_DECLINED':
      return AdminTripStatus.driverDeclined;
    case 'REJECTED':
      return AdminTripStatus.rejected;
    case 'ONGOING':
      return AdminTripStatus.ongoing;
    case 'COMPLETED':
      return AdminTripStatus.completed;
    default:
      return AdminTripStatus.unknown;
  }
}

extension AdminTripStatusX on AdminTripStatus {
  String get label {
    switch (this) {
      case AdminTripStatus.pending:
        return 'Pending';
      case AdminTripStatus.adminApproved:
        return 'With Head Driver';
      case AdminTripStatus.headDriverApproved:
        return 'With Driver';
      case AdminTripStatus.driverAccepted:
        return 'Accepted';
      case AdminTripStatus.driverDeclined:
        return 'Declined';
      case AdminTripStatus.rejected:
        return 'Rejected';
      case AdminTripStatus.ongoing:
        return 'Ongoing';
      case AdminTripStatus.completed:
        return 'Completed';
      case AdminTripStatus.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case AdminTripStatus.pending:
        return const Color(0xFF64748B);
      case AdminTripStatus.adminApproved:
      case AdminTripStatus.headDriverApproved:
        return const Color(0xFF3B4EDB);
      case AdminTripStatus.driverAccepted:
        return const Color(0xFF00897B);
      case AdminTripStatus.driverDeclined:
      case AdminTripStatus.rejected:
        return const Color(0xFFC62828);
      case AdminTripStatus.ongoing:
        return const Color(0xFFF9A825);
      case AdminTripStatus.completed:
        return const Color(0xFF2E7D32);
      case AdminTripStatus.unknown:
        return const Color(0xFF455A64);
    }
  }
}

class AdminPerson {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? role;

  const AdminPerson({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.role,
  });

  factory AdminPerson.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AdminPerson(id: '', fullName: '—');
    return AdminPerson(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '—',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
    );
  }

  bool get isHeadDriver => role == 'HEAD_DRIVER';

  String get contact => (phone == null || phone!.isEmpty) ? 'No contact number' : phone!;
}

class AdminStop {
  final String type; // ORIGIN | STOP | DESTINATION
  final String address;
  final int order;
  final int travelMinutes;
  final String? locationName;

  const AdminStop({
    required this.type,
    required this.address,
    required this.order,
    required this.travelMinutes,
    this.locationName,
  });

  factory AdminStop.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return AdminStop(
      type: json['type'] as String? ?? 'STOP',
      address: json['address'] as String? ?? '—',
      order: (json['order'] as num?)?.toInt() ?? 0,
      travelMinutes: (json['travelMinutes'] as num?)?.toInt() ?? 0,
      locationName: location?['name'] as String?,
    );
  }

  /// Places typed by the requester are not on the Admin location list,
  /// so their travel time is only an estimate.
  bool get isCustom => locationName == null;
}

class AdminTripModel {
  final String id;
  final String ticketNumber;
  final String purpose;
  final AdminTripStatus status;
  final bool isUrgent;
  final String? urgentReason;
  final String? authorizationLetterUrl;
  final String serviceMode; // WAIT | DROP_AND_PICKUP

  final DateTime date;
  final DateTime departureTime;
  final DateTime? returnTime;
  final DateTime? pickupTime;
  final DateTime createdAt;
  final DateTime? printedAt; // first time the ticket was printed, if ever

  final AdminPerson requester;
  final AdminPerson driver;
  final String departmentName;
  final String departmentCode;
  final String vehicleModel;
  final String vehiclePlate;

  /// Relative or absolute path to the vehicle photo, if the backend sends one.
  /// Pass it through ApiConfig.mediaUrl(...) before loading.
  final String? vehicleImageUrl;

  /// Seats in the vehicle, if the backend sends it.
  final int? vehicleCapacity;

  final List<String> passengers;
  final List<AdminStop> stops;

  const AdminTripModel({
    required this.id,
    required this.ticketNumber,
    required this.purpose,
    required this.status,
    required this.isUrgent,
    this.urgentReason,
    this.authorizationLetterUrl,
    required this.serviceMode,
    required this.date,
    required this.departureTime,
    this.returnTime,
    this.pickupTime,
    required this.createdAt,
    this.printedAt,
    required this.requester,
    required this.driver,
    required this.departmentName,
    required this.departmentCode,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.vehicleImageUrl,
    this.vehicleCapacity,
    required this.passengers,
    required this.stops,
  });

  /// Backend sends UTC ISO strings — .toLocal() puts them back in Manila time.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String)?.toLocal();
  }

  factory AdminTripModel.fromJson(Map<String, dynamic> json) {
    final department = json['department'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final passengerList = (json['passengers'] as List<dynamic>? ?? []);
    final stopList = (json['stops'] as List<dynamic>? ?? []);

    return AdminTripModel(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String? ?? '—',
      purpose: json['purpose'] as String? ?? '—',
      status: adminTripStatusFrom(json['status'] as String?),
      isUrgent: json['isUrgent'] as bool? ?? false,
      urgentReason: json['urgentReason'] as String?,
      authorizationLetterUrl: json['authorizationLetterUrl'] as String?,
      serviceMode: json['serviceMode'] as String? ?? 'WAIT',
      date: _parseDate(json['date']) ?? DateTime.now(),
      departureTime: _parseDate(json['departureTime']) ?? DateTime.now(),
      returnTime: _parseDate(json['returnTime']),
      pickupTime: _parseDate(json['pickupTime']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      printedAt: _parseDate(json['printedAt']),
      requester: AdminPerson.fromJson(json['requester'] as Map<String, dynamic>?),
      driver: AdminPerson.fromJson(json['driver'] as Map<String, dynamic>?),
      departmentName: department?['name'] as String? ?? '—',
      departmentCode: department?['code'] as String? ?? '—',
      vehicleModel: vehicle?['model'] as String? ?? '—',
      vehiclePlate: vehicle?['plateNumber'] as String? ?? '—',
      vehicleImageUrl: vehicle?['imageUrl'] as String?,
      vehicleCapacity: (vehicle?['capacity'] as num?)?.toInt(),
      passengers: passengerList
          .map((p) => (p as Map<String, dynamic>)['name'] as String? ?? '—')
          .toList(),
      stops: stopList
          .map((s) => AdminStop.fromJson(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }

  // ----- display helpers -----

  static final DateFormat _dateFmt = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFmt = DateFormat('h:mm a');

  String get dateLabel => _dateFmt.format(date);
  String get requestedOnLabel => '${_dateFmt.format(createdAt)} ${_timeFmt.format(createdAt)}';
  String get departureLabel => _timeFmt.format(departureTime);

  bool get isWaitMode => serviceMode == 'WAIT';

  String get serviceModeLabel =>
      isWaitMode ? 'Driver waits' : 'Drop off & pick up later';

  /// In WAIT mode the driver stays until the return time; in the other mode
  /// he comes back at pick-up time.
  String get endTimeLabel {
    if (isWaitMode) {
      return returnTime == null ? '—' : _timeFmt.format(returnTime!);
    }
    return pickupTime == null ? '—' : _timeFmt.format(pickupTime!);
  }

  String get endTimeTitle => isWaitMode ? 'Return Time:' : 'Pick-up Time:';

  /// "1:30 PM - 3:30 PM", or just "1:30 PM" when there is no return /
  /// pick-up time yet (avoids showing "1:30 PM - —").
  String get timeRangeLabel {
    final end = endTimeLabel;
    return end == '—' ? departureLabel : '$departureLabel - $end';
  }

  String get originLabel =>
      stops.isEmpty ? '—' : stops.first.address;

  String get destinationLabel =>
      stops.isEmpty ? '—' : stops.last.address;

  /// "Katipunan → Dapitan → Ipil"
  String get routeLabel =>
      stops.isEmpty ? '—' : stops.map((s) => s.address).join('  →  ');

  String get passengersLabel =>
      passengers.isEmpty ? 'No passengers listed' : passengers.join(', ');

  bool get hasLetter =>
      authorizationLetterUrl != null && authorizationLetterUrl!.isNotEmpty;

  /// The farthest stop decides how long the driver is on the road.
  int get maxTravelMinutes =>
      stops.fold(0, (max, s) => s.travelMinutes > max ? s.travelMinutes : max);
}