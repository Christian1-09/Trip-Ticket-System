// features/admin/data/models/driver_model.dart
import 'package:flutter/material.dart';

enum DriverStatus { available, onTrip, offDuty }

extension DriverStatusX on DriverStatus {
  String get label {
    switch (this) {
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.onTrip:
        return 'On trip';
      case DriverStatus.offDuty:
        return 'Off duty';
    }
  }

  Color get color {
    switch (this) {
      case DriverStatus.available:
        return const Color(0xFF29B6F6);
      case DriverStatus.onTrip:
        return const Color(0xFFF9A825);
      case DriverStatus.offDuty:
        return const Color(0xFF64748B);
    }
  }
}

class DriverModel {
  final int id;
  final String name;
  final String date;
  final int totalTrips;
  final DriverStatus status;

  const DriverModel({
    required this.id,
    required this.name,
    required this.date,
    required this.totalTrips,
    required this.status,
  });
}