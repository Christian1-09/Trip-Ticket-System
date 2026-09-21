import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';
import 'package:jtrips_app/features/auth/presentation/data/auth_repository.dart';

import '../../../../core/theme/network/api_client.dart';
import '../../../../core/theme/network/api_exception.dart';
import '../../../../core/theme/storage/token_storage.dart';

// ── Plumbing providers ──────────────────────────────────────────────────
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

// ── Auth state ───────────────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
}

class AuthRegistered extends AuthState {
  const AuthRegistered();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Controller ───────────────────────────────────────────────────────────
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthInitial());

  Future<void> tryRestoreSession() async {
    state = const AuthLoading();
    final user = await _repository.restoreSession();
    state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.login(
        identifier: identifier,
        password: password,
      );
      state = AuthAuthenticated(user);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        password: password,
      );
      state = const AuthRegistered();
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _repository.logout();
    state = const AuthUnauthenticated();
  }
}

final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});