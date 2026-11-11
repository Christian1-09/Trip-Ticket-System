// features/notifications/data/notification_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// One row from GET /api/notifications. Every role uses the same shape.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  /// What this notification is about — "TRIP_REQUEST", "DRIVER_APPROVAL",
  /// "INCIDENT", "TRIP" — and the id of that thing.
  ///
  /// Both nullable, because every notification written before these
  /// columns existed has neither. Those still render; they just fall back
  /// to reading the title, and tapping them does nothing but mark read.
  final String? type;
  final String? referenceId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.referenceId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String? ?? '—',
    message: json['message'] as String? ?? '',
    isRead: json['isRead'] as bool? ?? false,
    type: json['type'] as String?,
    referenceId: json['referenceId'] as String?,
    createdAt:
    DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
  );

  /// "5 min ago", "Yesterday", "Mar 12, 2026" — whichever reads best.
  String get whenLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, yyyy').format(createdAt);
  }

  /// True when tapping it should take the user somewhere.
  bool get isActionable => type != null && referenceId != null;

  // ---------------------------------------------------------------------
  // Icon and colour
  // ---------------------------------------------------------------------
  //
  // `type` first, title second.
  //
  // Reading the title was the only option when the backend sent no
  // category, and it works — until someone rewords a message and the
  // icon quietly changes. The type field is now set on everything new,
  // so that is what decides. The title heuristic stays underneath for
  // rows written before the column existed.

  IconData get icon {
    switch (type) {
      case 'TRIP_REQUEST':
        return Icons.description_outlined;
      case 'DRIVER_APPROVAL':
        return Icons.person_add_alt_outlined;
      case 'INCIDENT':
        return Icons.report_gmailerrorred_outlined;
      case 'TRIP':
        return _iconFromTitle;
    }
    return _iconFromTitle;
  }

  Color get color {
    switch (type) {
      case 'TRIP_REQUEST':
        return const Color(0xFF2563EB);
      case 'DRIVER_APPROVAL':
        return const Color(0xFFF59E0B);
      case 'INCIDENT':
        return const Color(0xFFDC2626);
      case 'TRIP':
        return _colorFromTitle;
    }
    return _colorFromTitle;
  }

  /// A trip notification can be an approval, a departure or a completion,
  /// so the title still decides which — it's the only thing that knows.
  IconData get _iconFromTitle {
    final t = title.toLowerCase();
    if (t.contains('reject') || t.contains('unavailable') || t.contains('declined')) {
      return Icons.cancel_outlined;
    }
    if (t.contains('approved') || t.contains('confirmed')) return Icons.verified_outlined;
    if (t.contains('completed')) return Icons.flag_rounded;
    if (t.contains('departed')) return Icons.play_arrow_rounded;
    if (t.contains('assigned')) return Icons.assignment_ind_outlined;
    if (t.contains('rating')) return Icons.star_outline_rounded;
    if (t.contains('duty')) return Icons.badge_outlined;
    return Icons.notifications_none_rounded;
  }

  Color get _colorFromTitle {
    final t = title.toLowerCase();
    if (t.contains('reject') || t.contains('unavailable') || t.contains('declined')) {
      return Colors.redAccent;
    }
    if (t.contains('completed')) return AppColors.statusGreen;
    if (t.contains('approved') || t.contains('confirmed')) return AppColors.statusBlue;
    if (t.contains('departed') || t.contains('rating')) return AppColors.accentYellow;
    return AppColors.textSecondary;
  }

  /// The ticket number mentioned in the message, e.g. "TT-2026-0001",
  /// so tapping a notification can open that trip.
  String? get ticketNumber {
    final match = RegExp(r'TT-\d{4}-\d{4}').firstMatch(message);
    return match?.group(0);
  }
}