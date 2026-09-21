
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';

import '../../../../core/theme/network/api_client.dart';
import '../../../../core/theme/storage/token_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Registers a new account. Does NOT log the user in automatically —
  /// the backend's /auth/register endpoint only creates the account.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String role, // backend value, e.g. "FACULTY"
    required String password,
  }) async {
    await _apiClient.post('/auth/register', body: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'password': password,
    });
  }

  /// Logs in with either an email address or a full name.
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post('/auth/login', body: {
      'identifier': identifier,
      'password': password,
    });

    final userJson = response['user'] as Map<String, dynamic>;
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;

    final user = AppUser.fromJson(userJson);

    await _tokenStorage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
      role: userJson['role'] as String,
      fullName: user.fullName,
      email: user.email,
    );

    return user;
  }

  /// Logs out on the backend and always clears local storage afterwards,
  /// even if the network call fails.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    try {
      if (refreshToken != null) {
        await _apiClient.post('/auth/logout', body: {
          'refreshToken': refreshToken,
        });
      }
    } finally {
      await _tokenStorage.clear();
    }
  }

  /// Checks secure storage for a previously saved session.
  Future<AppUser?> restoreSession() async {
    final hasSession = await _tokenStorage.hasSession();
    if (!hasSession) return null;

    final id = await _tokenStorage.getUserId();
    final email = await _tokenStorage.getUserEmail();
    final fullName = await _tokenStorage.getUserFullName();
    final role = await _tokenStorage.getUserRole();

    if (id == null || email == null || fullName == null || role == null) {
      return null;
    }

    return AppUser(
      id: id,
      email: email,
      fullName: fullName,
      role: AppRole.fromBackend(role),
    );
  }
}
