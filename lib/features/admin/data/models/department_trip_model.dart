// data/models/department_trip_model.dart
import 'dart:ui';

class DepartmentTripModel {
  final String department;
  final int tripCount;
  final Color color;

  const DepartmentTripModel({
    required this.department,
    required this.tripCount,
    required this.color,
  });
}