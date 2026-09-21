import 'dart:typed_data';
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ProfileRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<AppUser> getMe() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/me', accessToken: token);
    return AppUser.fromJson(response['user'] as Map<String, dynamic>);
  }

  /// Uploads a new avatar image and returns the updated user (with the
  /// new avatarUrl already set).
  Future<AppUser> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.patchMultipart(
      '/me/avatar',
      fieldName: 'avatar',
      bytes: bytes,
      filename: filename,
      accessToken: token,
    );
    return AppUser.fromJson(response['user'] as Map<String, dynamic>);
  }
}