// features/admin/data/admin_settings_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/settings_model.dart';

class AdminSettingsRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AdminSettingsRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<SystemSettingsModel> getSettings() async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.get('/admin/settings', accessToken: token);
    return SystemSettingsModel.fromJson(response['settings'] as Map<String, dynamic>);
  }

  /// Only the fields passed are changed; anything left null is untouched.
  Future<SystemSettingsModel> updateSettings({
    bool? notifyRequesterOnApprovalRejection,
    bool? notifyDriverWhenAssigned,
    bool? sendTripCompletionReminder,
    bool? alertAdminOnOverdueIncompleteTrips,
    String? approverName,
    String? approverTitle,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final response = await _apiClient.patch(
      '/admin/settings',
      body: {
        if (notifyRequesterOnApprovalRejection != null)
          'notifyRequesterOnApprovalRejection': notifyRequesterOnApprovalRejection,
        if (notifyDriverWhenAssigned != null)
          'notifyDriverWhenAssigned': notifyDriverWhenAssigned,
        if (sendTripCompletionReminder != null)
          'sendTripCompletionReminder': sendTripCompletionReminder,
        if (alertAdminOnOverdueIncompleteTrips != null)
          'alertAdminOnOverdueIncompleteTrips': alertAdminOnOverdueIncompleteTrips,
        if (approverName != null) 'approverName': approverName,
        if (approverTitle != null) 'approverTitle': approverTitle,
      },
      accessToken: token,
    );
    return SystemSettingsModel.fromJson(response['settings'] as Map<String, dynamic>);
  }
}