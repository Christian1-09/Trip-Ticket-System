import 'package:jtrips_app/features/auth/presentation/RegisterScreen.dart';
/// RegisterScreen's UserRole enum only covers the roles a person can
/// self-register as (Admin is assigned manually in the database, so it's
/// intentionally excluded from that dropdown). This extension converts
/// those dropdown values into the exact strings the backend's Role enum
/// expects.
extension UserRoleBackendMapping on UserRole {
  String get backendValue {
    switch (this) {
      case UserRole.faculty:
        return 'FACULTY';
      case UserRole.staff:
        return 'STAFF';
      case UserRole.ssgPresident:
        return 'SSG_PRESIDENT';
      case UserRole.driver:
        return 'DRIVER';
    }
  }
}
