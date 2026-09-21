/// Every role the backend can assign — including ADMIN, which is never
/// selectable at registration (assigned manually in the database) but can
/// still come back from a login response.
enum AppRole {
  admin,
  headDriver,
  driver,
  faculty,
  staff,
  ssgPresident;

  static AppRole fromBackend(String value) {
    switch (value) {
      case 'ADMIN':
        return AppRole.admin;
      case 'HEAD_DRIVER':
        return AppRole.headDriver;
      case 'DRIVER':
        return AppRole.driver;
      case 'FACULTY':
        return AppRole.faculty;
      case 'STAFF':
        return AppRole.staff;
      case 'SSG_PRESIDENT':
        return AppRole.ssgPresident;
      default:
        throw ArgumentError('Unknown role from backend: $value');
    }
  }
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl; // relative path from backend, e.g. "/uploads/avatars/xxx.jpg"
  final AppRole role;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: AppRole.fromBackend(json['role'] as String),
    );
  }
}