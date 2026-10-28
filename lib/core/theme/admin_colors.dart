// features/admin/presentation/theme/admin_colors.dart
import 'package:flutter/material.dart';

/// Palette taken from the JTRIPS admin mockup.
class AdminColors {
  AdminColors._();

  // Sidebar
  static const sidebarTop = Color(0xFF0F2C8F);
  static const sidebarBottom = Color(0xFF0A1E66);

  // Brand
  static const navy = Color(0xFF14286B); // headings / main text
  static const amber = Color(0xFFFFC21A); // selected nav, logout, logo

  // Surfaces
  static const background = Color(0xFFF3F5FB); // content area
  static const surface = Colors.white; // cards, top bar
  static const border = Color(0xFFE6E9F2);
  static const textMuted = Color(0xFF7A849E);

  // Accents
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF59E0B);
  static const green = Color(0xFF16A34A);

  // Trip Overview banner gradient
  static const bannerStart = Color(0xFF0B2580);
  static const bannerEnd = Color(0xFF1D4ED8);

  static const cardShadow = [
    BoxShadow(color: Color(0x141E2A5A), blurRadius: 18, offset: Offset(0, 6)),
  ];
}