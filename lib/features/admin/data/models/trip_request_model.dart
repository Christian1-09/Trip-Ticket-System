// features/admin/data/models/trip_request_model.dart
import 'package:flutter/material.dart';

enum TripRequestStatus { pending, complete, urgent }

extension TripRequestStatusX on TripRequestStatus {
  String get label {
    switch (this) {
      case TripRequestStatus.pending:
        return 'Pending';
      case TripRequestStatus.complete:
        return 'Complete';
      case TripRequestStatus.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TripRequestStatus.pending:
        return const Color(0xFF64748B);
      case TripRequestStatus.complete:
        return const Color(0xFF2E7D32);
      case TripRequestStatus.urgent:
        return const Color(0xFFF9A825);
    }
  }
}

class TripRequestModel {
  final String id;
  final String requestingPerson;
  final String department;
  final String driver;
  final TripRequestStatus status;

  const TripRequestModel({
    required this.id,
    required this.requestingPerson,
    required this.department,
    required this.driver,
    required this.status,
  });
}