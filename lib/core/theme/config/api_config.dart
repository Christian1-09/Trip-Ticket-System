import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for backend connection settings.
///
/// The correct address depends on WHERE the app is running:
/// - Chrome / any web build -> http://localhost:4000/api
///     (the browser runs on your actual PC, so "localhost" IS your PC)
/// - Android emulator        -> http://10.0.2.2:4000/api
///     (10.0.2.2 is a special alias the emulator uses to reach your PC's
///     localhost — it means nothing outside the emulator, e.g. in Chrome)
/// - Physical phone          -> http://<your-PC-LAN-IP>:4000/api
///     (e.g. 192.168.1.23 — swap this in manually if you test on a real device)
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    }
    return 'http://10.0.2.2:4000/api';
    // return "http://10.0.5.133:4000/api";
  }

  /// Same host as [baseUrl], but without the trailing "/api" — used to build
  /// full URLs for uploaded files (avatars, etc.), which the backend
  /// returns as relative paths like "/uploads/avatars/xxx.jpg".
  static String get mediaBaseUrl => baseUrl.replaceAll('/api', '');

  /// Builds a full, displayable URL for a relative path the backend
  /// returned (e.g. user.avatarUrl). Returns null if [relativePath] is null,
  /// so callers can fall back to a placeholder image easily.
  static String? mediaUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    return '$mediaBaseUrl$relativePath';
  }
}