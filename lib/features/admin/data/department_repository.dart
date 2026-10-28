// features/admin/data/department_repository.dart
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'models/department_model.dart';

class AdminDepartmentRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AdminDepartmentRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// [status] is 'active', 'inactive', or empty for everything.
  Future<List<AdminDepartmentModel>> listAll({String status = ''}) async {
    final token = await _tokenStorage.getAccessToken();
    final query = status.isEmpty ? '' : '?status=$status';
    final response =
    await _apiClient.get('/admin/departments$query', accessToken: token);
    final list = response['departments'] as List<dynamic>;
    return list
        .map((e) => AdminDepartmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String name,
    required String code,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.post(
      '/admin/departments',
      body: {'name': name, 'code': code},
      accessToken: token,
    );
  }

  /// Every field is optional; send only what changed. The backend rejects
  /// an empty body with a 400, and refuses a code change once the
  /// department has trips.
  Future<void> update(
      String id, {
        String? name,
        String? code,
        bool? isActive,
      }) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.patch(
      '/admin/departments/$id',
      body: {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (isActive != null) 'isActive': isActive,
      },
      accessToken: token,
    );
  }

  /// Only works for a department no user or trip points at. The backend
  /// answers 409 otherwise and says to deactivate it instead.
  Future<void> delete(String id) async {
    final token = await _tokenStorage.getAccessToken();
    await _apiClient.delete('/admin/departments/$id', accessToken: token);
  }
}