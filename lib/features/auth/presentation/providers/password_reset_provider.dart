// features/auth/presentation/providers/password_reset_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/password_reset_repository.dart';
import 'auth_controller.dart' show apiClientProvider;

/// Just the repository — no StateNotifier.
///
/// AuthController holds state because "who is signed in" outlives any
/// one screen and several parts of the app read it. A password reset is
/// a three-step errand that starts and finishes inside its own
/// navigation stack: each screen owns its own busy flag and hands the
/// next one what it needs through the constructor. A shared state
/// machine here would add a thing to reset on cancel and a way for a
/// half-finished reset to leak into the next one.
final passwordResetRepositoryProvider = Provider<PasswordResetRepository>((ref) {
  return PasswordResetRepository(apiClient: ref.watch(apiClientProvider));
});