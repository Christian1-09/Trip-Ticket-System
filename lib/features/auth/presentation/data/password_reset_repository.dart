// features/auth/presentation/data/password_reset_repository.dart
import '../../../../core/theme/network/api_client.dart';

/// The three public password-reset calls.
///
/// No TokenStorage here, deliberately: someone who can't log in has no
/// access token to send. These endpoints are the only ones in the API
/// that are reachable without one, which is also why the backend is
/// careful never to reveal whether an address exists.
class PasswordResetRepository {
  final ApiClient _apiClient;

  PasswordResetRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Asks for a code.
  ///
  /// Succeeds whether or not the address belongs to an account — the
  /// server answers identically either way, so the screen can't say
  /// "no such user" and neither can an attacker work it out.
  ///
  /// Returns the code itself ONLY while the server has no SMTP
  /// configured. On a real deployment this is always null.
  Future<String?> requestCode(String email) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    return response['devCode'] as String?;
  }

  /// Exchanges a correct code for a short-lived token that authorises one
  /// password change. Throws ApiException with a usable message when the
  /// code is wrong, expired, or has been tried too many times.
  Future<String> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/auth/verify-reset-code',
      body: {'email': email, 'code': code},
    );
    return response['resetToken'] as String;
  }

  /// Sets the new password. Every existing session for that account is
  /// destroyed server-side, so anyone signed in elsewhere is logged out.
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: {'resetToken': resetToken, 'password': password},
    );
  }
}