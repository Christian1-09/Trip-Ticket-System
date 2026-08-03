import 'package:flutter/material.dart';

/// Central color palette for the Trip Ticket flow.
/// Pulled by eye from the design mock — tweak freely.
class TicketFormColors {
  TicketFormColors._();

  // Backgrounds
  static const Color bgTop = Color(0xFF16215A);
  static const Color bgBottom = Color(0xFF0A0F2C);
  static const Color cardBg = Color(0xFF141B42);
  static const Color cardBgAlt = Color(0xFF10173A);
  static const Color inputBg = Color(0xFF0E1638);

  // Borders
  static const Color border = Color(0xFF2C3868);
  static const Color borderFocused = Color(0xFF4C6FFF);

  // Accents
  static const Color gold = Color(0xFFF2B90D);
  static const Color goldDark = Color(0xFFC79A0B);
  static const Color blueAccent = Color(0xFF4C8DFF);
  static const Color greenAccent = Color(0xFF34C77B);
  static const Color infoBg = Color(0xFF15224F);

  // Text
  static const Color textPrimary = Color(0xFFF5F7FF);
  static const Color textSecondary = Color(0xFF8C96C4);
  static const Color textMuted = Color(0xFF6670A3);
  static const Color link = Color(0xFF6FA8FF);

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static const LinearGradient submitButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3C63FF), Color(0xFF203BB8)],
  );
}