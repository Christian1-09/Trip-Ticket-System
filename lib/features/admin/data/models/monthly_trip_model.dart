// features/admin/data/models/monthly_trip_model.dart
class MonthlyTripModel {
  final String month;
  final int visitingLecturer;
  final int faculty;
  final int staff;
  final int ssg;

  const MonthlyTripModel({
    required this.month,
    required this.visitingLecturer,
    required this.faculty,
    required this.staff,
    required this.ssg,
  });
}