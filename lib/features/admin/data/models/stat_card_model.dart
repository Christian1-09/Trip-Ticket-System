// data/models/stat_card_model.dart
import 'package:flutter/material.dart';

class AdminStatCardModel {
  final String label;
  final String value;
  final String? subtext;
  final IconData icon;
  final Color color;

  const AdminStatCardModel({
    required this.label,
    required this.value,
    this.subtext,
    required this.icon,
    required this.color,
  });
}