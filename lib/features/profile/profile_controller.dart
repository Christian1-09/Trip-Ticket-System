import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;
import 'profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

class ProfileController extends StateNotifier<AsyncValue<AppUser>> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Uploads a new avatar. Keeps the previous data visible while uploading
  /// (doesn't flip to a loading state), and rethrows on failure so the UI
  /// can show a snackbar without losing the current profile display.
  Future<void> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final updated = await _repository.uploadAvatar(bytes: bytes, filename: filename);
    state = AsyncValue.data(updated);
  }
}

final profileControllerProvider =
StateNotifierProvider<ProfileController, AsyncValue<AppUser>>((ref) {
  return ProfileController(ref.watch(profileRepositoryProvider));
});