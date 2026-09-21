import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps `flutter_secure_storage` so the rest of the app never touches
/// raw storage keys directly. Tokens are encrypted at rest by the OS
/// (Android Keystore / iOS Keychain) rather than plain SharedPreferences.
class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userIdKey = 'userId';
  static const _userRoleKey = 'userRole';
  static const _userFullNameKey = 'userFullName';
  static const _userEmailKey = 'userEmail';

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String fullName,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userRoleKey, value: role),
      _storage.write(key: _userFullNameKey, value: fullName),
      _storage.write(key: _userEmailKey, value: email),
    ]);
  }

  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessTokenKey, value: accessToken);

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getUserRole() => _storage.read(key: _userRoleKey);
  Future<String?> getUserFullName() => _storage.read(key: _userFullNameKey);
  Future<String?> getUserEmail() => _storage.read(key: _userEmailKey);

  /// True if a session was saved previously (used for "stay logged in").
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
