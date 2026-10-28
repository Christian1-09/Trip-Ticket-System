// features/admin/data/models/department_model.dart

/// A department as the admin manages it. Distinct from the requester's
/// `DepartmentModel` in trip_ticket/data/reference_models.dart, which is
/// just a dropdown option — this one carries usage counts and the active
/// flag the admin screen needs.
class AdminDepartmentModel {
  final String id;
  final String name;
  final String code;
  final bool isActive;

  /// Users whose profile points at this department.
  final int userCount;

  /// Trips filed under this department.
  final int tripCount;

  const AdminDepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.userCount,
    required this.tripCount,
  });

  factory AdminDepartmentModel.fromJson(Map<String, dynamic> json) {
    return AdminDepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      isActive: json['isActive'] as bool? ?? true,
      userCount: (json['userCount'] as num?)?.toInt() ?? 0,
      tripCount: (json['tripCount'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isInUse => userCount > 0 || tripCount > 0;

  bool get canDelete => !isInUse;

  /// The code is printed on every trip ticket and nothing snapshots it, so
  /// the backend freezes it once trips exist. The dialog disables the field
  /// rather than letting the admin type a change that gets rejected.
  bool get canEditCode => tripCount == 0;

  String get usageLabel {
    if (!isInUse) return 'Not used yet';
    final parts = <String>[];
    if (tripCount > 0) {
      parts.add(tripCount == 1 ? '1 trip' : '$tripCount trips');
    }
    if (userCount > 0) {
      parts.add(userCount == 1 ? '1 member' : '$userCount members');
    }
    return parts.join(' · ');
  }
}