// features/admin/presentation/providers/department_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/department_repository.dart';
import '../../data/models/department_model.dart';

final adminDepartmentRepositoryProvider =
Provider<AdminDepartmentRepository>((ref) {
  return AdminDepartmentRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// '' (all), 'active' or 'inactive'.
final departmentFilterProvider = StateProvider<String>((ref) => '');

final adminDepartmentListProvider =
FutureProvider<List<AdminDepartmentModel>>((ref) {
  final status = ref.watch(departmentFilterProvider);
  return ref.watch(adminDepartmentRepositoryProvider).listAll(status: status);
});

/// True while a save, toggle or delete is in flight.
final departmentBusyProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Save (create + edit share one controller — the only difference is whether
// an id is passed)
// ─────────────────────────────────────────────────────────────────────────────

sealed class SaveDepartmentState {
  const SaveDepartmentState();
}

class SaveDepartmentIdle extends SaveDepartmentState {
  const SaveDepartmentIdle();
}

class SaveDepartmentLoading extends SaveDepartmentState {
  const SaveDepartmentLoading();
}

class SaveDepartmentSuccess extends SaveDepartmentState {
  const SaveDepartmentSuccess();
}

class SaveDepartmentError extends SaveDepartmentState {
  final String message;
  const SaveDepartmentError(this.message);
}

class SaveDepartmentController extends StateNotifier<SaveDepartmentState> {
  final AdminDepartmentRepository _repository;
  final Ref _ref;

  SaveDepartmentController(this._repository, this._ref)
      : super(const SaveDepartmentIdle());

  /// [id] null creates, non-null edits. [code] null on an edit leaves the
  /// code alone — which is what the dialog sends when the code is frozen.
  Future<void> save({
    String? id,
    required String name,
    String? code,
  }) async {
    state = const SaveDepartmentLoading();
    try {
      if (id == null) {
        await _repository.create(name: name, code: code ?? '');
      } else {
        await _repository.update(id, name: name, code: code);
      }
      _ref.invalidate(adminDepartmentListProvider);
      state = const SaveDepartmentSuccess();
    } catch (e) {
      state = SaveDepartmentError('$e');
    }
  }

  void reset() => state = const SaveDepartmentIdle();
}

final saveDepartmentControllerProvider =
StateNotifierProvider<SaveDepartmentController, SaveDepartmentState>((ref) {
  return SaveDepartmentController(
      ref.watch(adminDepartmentRepositoryProvider), ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// Row actions
// ─────────────────────────────────────────────────────────────────────────────

/// Returns null on success, or the error message to show.
Future<String?> toggleDepartmentActive(
    WidgetRef ref,
    AdminDepartmentModel department,
    ) async {
  ref.read(departmentBusyProvider.notifier).state = true;
  try {
    await ref
        .read(adminDepartmentRepositoryProvider)
        .update(department.id, isActive: !department.isActive);
    ref.invalidate(adminDepartmentListProvider);
    return null;
  } catch (e) {
    return '$e';
  } finally {
    ref.read(departmentBusyProvider.notifier).state = false;
  }
}

Future<String?> deleteDepartment(WidgetRef ref, String id) async {
  ref.read(departmentBusyProvider.notifier).state = true;
  try {
    await ref.read(adminDepartmentRepositoryProvider).delete(id);
    ref.invalidate(adminDepartmentListProvider);
    return null;
  } catch (e) {
    return '$e';
  } finally {
    ref.read(departmentBusyProvider.notifier).state = false;
  }
}