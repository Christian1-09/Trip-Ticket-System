// features/instructor/data/requester_trip_models.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/driver/data/driver_models.dart'
    show DepartureLog, ReturnLog;
import 'package:jtrips_app/features/instructor/presentation/widgets/schedule.dart';

/// The rating the requester left for the driver, once given.
class TripRating {
  final int score;
  final String? comment;

  const TripRating({required this.score, this.comment});

  factory TripRating.fromJson(Map<String, dynamic> json) => TripRating(
    score: (json['score'] as num?)?.toInt() ?? 0,
    comment: json['comment'] as String?,
  );
}

/// A trip as its requester sees it. The JSON is the same shape the Admin
/// and driver get, so AdminTripModel is reused rather than duplicated.
class RequesterTrip {
  final AdminTripModel trip;
  final DateTime? adminApprovedAt;
  final DateTime? headDriverApprovedAt;
  final DateTime? driverAcceptedAt;
  final DateTime? rejectedAt;
  final String? rejectedReason;
  final DepartureLog? departure;
  final ReturnLog? arrival;
  final TripRating? rating;

  const RequesterTrip({
    required this.trip,
    this.adminApprovedAt,
    this.headDriverApprovedAt,
    this.driverAcceptedAt,
    this.rejectedAt,
    this.rejectedReason,
    this.departure,
    this.arrival,
    this.rating,
  });

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value as String)?.toLocal();

  factory RequesterTrip.fromJson(Map<String, dynamic> json) {
    final departure = json['departure'] as Map<String, dynamic>?;
    final arrival = json['arrival'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    return RequesterTrip(
      trip: AdminTripModel.fromJson(json),
      adminApprovedAt: _date(json['adminApprovedAt']),
      headDriverApprovedAt: _date(json['headDriverApprovedAt']),
      driverAcceptedAt: _date(json['driverAcceptedAt']),
      rejectedAt: _date(json['rejectedAt']),
      rejectedReason: json['rejectedReason'] as String?,
      departure: departure == null ? null : DepartureLog.fromJson(departure),
      arrival: arrival == null ? null : ReturnLog.fromJson(arrival),
      rating: rating == null ? null : TripRating.fromJson(rating),
    );
  }

  String get id => trip.id;
  AdminTripStatus get status => trip.status;

  bool get isCompleted => status == AdminTripStatus.completed;
  bool get isRejected => status == AdminTripStatus.rejected;
  bool get canRate => isCompleted && rating == null;
  bool get canPrint => isCompleted;

  /// Plain-language status for someone who only cares about their own trip,
  /// not the internal approval chain.
  String get statusLabel {
    switch (status) {
      case AdminTripStatus.pending:
        return 'Waiting for admin approval';
      case AdminTripStatus.adminApproved:
        return 'Waiting for head driver';
      case AdminTripStatus.headDriverApproved:
        return 'Waiting for the driver to accept';
      case AdminTripStatus.driverAccepted:
        return 'Confirmed';
      case AdminTripStatus.driverDeclined:
        return 'Finding another driver';
      case AdminTripStatus.rejected:
        return 'Rejected';
      case AdminTripStatus.ongoing:
        return 'On the road';
      case AdminTripStatus.completed:
        return 'Completed';
      case AdminTripStatus.unknown:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case AdminTripStatus.driverAccepted:
        return AppColors.statusBlue;
      case AdminTripStatus.ongoing:
        return AppColors.accentYellow;
      case AdminTripStatus.completed:
        return AppColors.statusGreen;
      case AdminTripStatus.rejected:
        return Colors.redAccent;
      case AdminTripStatus.driverDeclined:
        return Colors.orangeAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  /// How the trip should look on a ScheduleCard.
  TripStatus get cardStatus {
    switch (status) {
      case AdminTripStatus.driverAccepted:
        return TripStatus.confirmed;
      case AdminTripStatus.ongoing:
        return TripStatus.ongoing;
      case AdminTripStatus.completed:
        return TripStatus.completed;
      case AdminTripStatus.rejected:
        return TripStatus.rejected;
      default:
        return TripStatus.pending;
    }
  }

  /// How far along the approval chain the trip is, for the progress bar.
  /// -1 for a rejected trip, which never finishes the chain.
  int get progressStep {
    switch (status) {
      case AdminTripStatus.pending:
        return 0;
      case AdminTripStatus.adminApproved:
        return 1;
      case AdminTripStatus.headDriverApproved:
      case AdminTripStatus.driverDeclined:
        return 2;
      case AdminTripStatus.driverAccepted:
        return 3;
      case AdminTripStatus.ongoing:
        return 4;
      case AdminTripStatus.completed:
        return 5;
      default:
        return -1;
    }
  }
}