// features/admin/data/models/admin_driver_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Matches the backend DriverStatus enum.
/// ON_TRIP is set by the system when a trip departs — Admin can only
/// switch between AVAILABLE and OFF_DUTY.
enum DriverStatus { available, onTrip, offDuty, unknown }

DriverStatus driverStatusFrom(String? value) {
  switch (value) {
    case 'AVAILABLE':
      return DriverStatus.available;
    case 'ON_TRIP':
      return DriverStatus.onTrip;
    case 'OFF_DUTY':
      return DriverStatus.offDuty;
    default:
      return DriverStatus.unknown;
  }
}

extension DriverStatusX on DriverStatus {
  String get label {
    switch (this) {
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.onTrip:
        return 'On Trip';
      case DriverStatus.offDuty:
        return 'Off Duty';
      case DriverStatus.unknown:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case DriverStatus.available:
        return const Color(0xFF2E7D32);
      case DriverStatus.onTrip:
        return const Color(0xFFF9A825);
      case DriverStatus.offDuty:
        return const Color(0xFF90A4AE);
      case DriverStatus.unknown:
        return const Color(0xFF607D8B);
    }
  }

  String get apiValue {
    switch (this) {
      case DriverStatus.available:
        return 'AVAILABLE';
      case DriverStatus.onTrip:
        return 'ON_TRIP';
      case DriverStatus.offDuty:
        return 'OFF_DUTY';
      case DriverStatus.unknown:
        return 'UNKNOWN';
    }
  }
}

class AdminDriverModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role; // DRIVER | HEAD_DRIVER
  final bool isActive;
  final String? avatarUrl;
  final DateTime createdAt;

  final String? driverCode;
  final DriverStatus status;
  final String? licenseNumber;
  final DateTime? dateHired;

  final String? vehicleModel;
  final String? vehiclePlate;

  // Computed by the backend on every request, never stored.
  final int totalTrips;
  final int completedTrips;
  final double? averageRating;
  final int ratingCount;

  const AdminDriverModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    this.avatarUrl,
    required this.createdAt,
    this.driverCode,
    required this.status,
    this.licenseNumber,
    this.dateHired,
    this.vehicleModel,
    this.vehiclePlate,
    required this.totalTrips,
    required this.completedTrips,
    this.averageRating,
    required this.ratingCount,
  });

  factory AdminDriverModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['assignedVehicle'] as Map<String, dynamic>?;
    return AdminDriverModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '—',
      email: json['email'] as String? ?? '—',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'DRIVER',
      isActive: json['isActive'] as bool? ?? true,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt:
      DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      driverCode: json['driverCode'] as String?,
      status: driverStatusFrom(json['status'] as String?),
      licenseNumber: json['licenseNumber'] as String?,
      dateHired: DateTime.tryParse(json['dateHired'] as String? ?? '')?.toLocal(),
      vehicleModel: vehicle?['model'] as String?,
      vehiclePlate: vehicle?['plateNumber'] as String?,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isHeadDriver => role == 'HEAD_DRIVER';

  String get roleLabel => isHeadDriver ? 'Head Driver' : 'Driver';

  String get registeredLabel => DateFormat('MMM d, yyyy').format(createdAt);

  String get contact => (phone == null || phone!.isEmpty) ? '—' : phone!;

  String get vehicleLabel =>
      vehicleModel == null ? 'Not assigned' : '$vehicleModel ($vehiclePlate)';

  String get tripsLabel => '$completedTrips / $totalTrips';

  String get ratingLabel => averageRating == null
      ? 'No ratings'
      : '${averageRating!.toStringAsFixed(1)} ($ratingCount)';

  /// A driver out on the road cannot be marked off duty.
  bool get canChangeStatus => status != DriverStatus.onTrip;
}