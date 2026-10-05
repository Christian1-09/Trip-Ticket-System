// features/admin/presentation/providers/admin_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/admin_settings_repository.dart';
import '../../data/models/settings_model.dart';

final adminSettingsRepositoryProvider = Provider<AdminSettingsRepository>((ref) {
  return AdminSettingsRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final adminSettingsProvider = FutureProvider<SystemSettingsModel>((ref) {
  return ref.watch(adminSettingsRepositoryProvider).getSettings();
});