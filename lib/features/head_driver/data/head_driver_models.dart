// features/head_driver/data/head_driver_models.dart
import 'package:intl/intl.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

/// A trip as the Head Driver sees it. The trip fields have exactly the same
/// shape as the Admin's, so AdminTripModel is reused instead of duplicated;
/// the decline history is the only extra.
class HeadDriverTrip {
  final AdminTripModel trip;
  final List<DeclineInfo> declines;

  const HeadDriverTrip({required this.trip, required this.declines});

  factory HeadDriverTrip.fromJson(Map<String, dynamic> json) {
    final list = json['driverDeclines'] as List<dynamic>? ?? [];
    return HeadDriverTrip(
      trip: AdminTripModel.fromJson(json),
      declines: list
          .map((e) => DeclineInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// One driver who declined a trip, and why.
class DeclineInfo {
  final String driverName;
  final String reason;
  final DateTime declinedAt;

  const DeclineInfo({
    required this.driverName,
    required this.reason,
    required this.declinedAt,
  });

  factory DeclineInfo.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    return DeclineInfo(
      driverName: driver?['fullName'] as String? ?? 'A driver',
      reason: json['reason'] as String? ?? '—',
      declinedAt:
      DateTime.tryParse(json['declinedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  String get whenLabel => DateFormat('MMM d, h:mm a').format(declinedAt);
}

/// A driver the Head Driver can pick after someone declined.
/// Already filtered by the backend: free at that time, not off duty,
/// and not someone who declined this trip before.
class ReplacementDriver {
  final String id;
  final String fullName;
  final String? phone;
  final String role;

  const ReplacementDriver({
    required this.id,
    required this.fullName,
    this.phone,
    required this.role,
  });

  factory ReplacementDriver.fromJson(Map<String, dynamic> json) => ReplacementDriver(
    id: json['id'] as String,
    fullName: json['fullName'] as String? ?? '—',
    phone: json['phone'] as String?,
    role: json['role'] as String? ?? 'DRIVER',
  );

  bool get isHeadDriver => role == 'HEAD_DRIVER';

  String get label => isHeadDriver ? '$fullName (you)' : fullName;
}