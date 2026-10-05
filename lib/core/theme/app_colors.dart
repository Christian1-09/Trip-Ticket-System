import 'package:flutter/material.dart';

/// Centralized color palette for the dark dashboard theme.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFE6E7EC);
  static const Color cardDark = Color(0xFF050A3D);
  static const Color cardDeepBlue = Color(0xFF0E1B72);
  static const Color gradientStart = Color(0xFF1AC7C7);
  static const Color gradientEnd = Color(0xFF1B2A6B);
  static const Color accentYellow = Color(0xFFFFC727);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAEB4D6);
  static const Color statusGreen = Color(0xFF34D399);
  static const Color statusBlue = Color(0xFF46CBF7);
  static const Color navInactive = Color(0xFF6B7099);
  static const Color menuBackground = Color(0xFF202556);
  static const Color quickActions = Color(0xFF0C1671);
  static const Color statusCard = Color(0xFF252E8E);
  static const TextStyle header =
  TextStyle(fontWeight: FontWeight.w500, fontSize: 23);

  // ── Light home dashboard ────────────────────────────────────────────────
  // Kept separate from the colors above so other (dark) screens that use
  // textPrimary / textSecondary don't change.
  static const Color homeBackground = Color(0xFFF2F4F9);
  static const Color homeSurface = Color(0xFFFFFFFF);
  static const Color homeNavy = Color(0xFF0B1E6B);
  static const Color homeNavyDark = Color(0xFF071166);
  static const Color homeTextDark = Color(0xFF0B1E6B);
  static const Color homeTextMuted = Color(0xFF6B7280);
  static const Color homeTileBlue = Color(0xFFEAF2FF);
  static const Color homeIconBlue = Color(0xFF2F80ED);
  static const Color homeGreen = Color(0xFF22C55E);
}