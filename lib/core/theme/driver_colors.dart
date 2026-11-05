// features/driver/presentation/theme/driver_colors.dart
import 'package:flutter/material.dart';

/// The driver app's light palette.
///
/// These exact values already exist as a private `_C` class inside both
/// `TripInformation.dart` and `trip_log_forms.dart` — two copies of the
/// same numbers, neither reachable from anywhere else. That is why a new
/// driver screen has had to carry a third copy.
///
/// New driver screens use this. The two existing files can migrate with a
/// find-and-replace of `_C.` → `DriverColors.` and deleting their private
/// class, whenever either is next touched. Not urgent; worth not
/// forgetting.
class DriverColors {
  DriverColors._();

  static const bg = Color(0xFFF2F5FB);
  static const card = Colors.white;
  static const headerTint = Color(0xFFF6F8FE);

  static const primary = Color(0xFF2448B8);
  static const primaryLight = Color(0xFFE8EEFF);
  static const navy = Color(0xFF1E2A5A);

  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E9F2);
  static const field = Color(0xFFF8FAFD);

  static const yellow = Color(0xFFF5B400);
  static const yellowBg = Color(0xFFFFF7E0);
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF2E7D32);
  static const red = Color(0xFFDC2626);
  static const orange = Color(0xFFF59E0B);
}