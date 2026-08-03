// data/mock/admin_mock_data.dart
import 'package:flutter/material.dart';
import '../models/stat_card_model.dart';
import '../models/department_trip_model.dart';

final adminStatCards = [
  const AdminStatCardModel(
    label: 'Total Trips (Month)',
    value: '42',
    subtext: '12% vs last month',
    icon: Icons.route,
    color: Color(0xFF7C4DFF),
  ),
  const AdminStatCardModel(
    label: 'Pending Approval',
    value: '9',
    subtext: 'unchanged today',
    icon: Icons.pending_actions,
    color: Color(0xFFFFA726),
  ),
  const AdminStatCardModel(
    label: 'Completed Trips',
    value: '30',
    subtext: '12% vs last month',
    icon: Icons.check_circle,
    color: Color(0xFF26C6DA),
  ),
  const AdminStatCardModel(
    label: 'Vehicles Available',
    value: '8',
    subtext: '2 in maintenance',
    icon: Icons.directions_car,
    color: Color(0xFFEF5350),
  ),
  const AdminStatCardModel(
    label: 'Driver Available',
    value: '5',
    subtext: '3 currently on duty',
    icon: Icons.person,
    color: Color(0xFF66BB6A),
  ),
];

final departmentTripData = [
  const DepartmentTripModel(department: 'CCS', tripCount: 18, color: Color(0xFF9C27B0)),
  const DepartmentTripModel(department: 'CTED', tripCount: 22, color: Color(0xFF2196F3)),
  const DepartmentTripModel(department: 'High School', tripCount: 30, color: Color(0xFFE53935)),
  const DepartmentTripModel(department: 'SCJE', tripCount: 12, color: Color(0xFFFFC107)),
  const DepartmentTripModel(department: 'CBA', tripCount: 15, color: Color(0xFF8BC34A)),
  const DepartmentTripModel(department: 'CAP-SDE', tripCount: 10, color: Color(0xFF4CAF50)),
];