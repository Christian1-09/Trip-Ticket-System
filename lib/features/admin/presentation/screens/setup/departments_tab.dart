// features/admin/presentation/screens/setup/departments_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/admin_colors.dart';
import '../../../data/models/department_model.dart';
import '../../providers/department_provider.dart';
import '../../widgets/department_dialog.dart';

enum _DepartmentAction { edit, toggleActive, delete }

/// Body only — no Scaffold. `AdminSetupScreen` provides that and the tabs.
///
/// Styled to match the light admin panel (AdminColors), not the dark
/// requester app.
class DepartmentsTab extends ConsumerWidget {
  const DepartmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(adminDepartmentListProvider);
    final filter = ref.watch(departmentFilterProvider);
    final busy = ref.watch(departmentBusyProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Colleges and offices requesters file their trips under. '
                          'The code is printed on the trip ticket.',
                      style: TextStyle(
                          color: AdminColors.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: busy
                          ? null
                          : () => showDialog(
                        context: context,
                        builder: (_) => const DepartmentDialog(),
                      ),
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text('Add department',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AdminColors.amber,
                        foregroundColor: AdminColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Filter chips ─────────────────────────────────
              Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: filter == '',
                    onTap: () =>
                    ref.read(departmentFilterProvider.notifier).state = '',
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Active',
                    selected: filter == 'active',
                    onTap: () => ref
                        .read(departmentFilterProvider.notifier)
                        .state = 'active',
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Inactive',
                    selected: filter == 'inactive',
                    onTap: () => ref
                        .read(departmentFilterProvider.notifier)
                        .state = 'inactive',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── List ─────────────────────────────────────────
              Expanded(
                child: departmentsAsync.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (err, _) => _ErrorView(
                    detail: '$err',
                    onRetry: () => ref.invalidate(adminDepartmentListProvider),
                  ),
                  data: (departments) {
                    if (departments.isEmpty) return _EmptyView(filter: filter);

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: departments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _DepartmentRow(
                        department: departments[index],
                        busy: busy,
                        onAction: (action) => _handleAction(
                            context, ref, departments[index], action),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (busy)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Future<void> _handleAction(
      BuildContext context,
      WidgetRef ref,
      AdminDepartmentModel department,
      _DepartmentAction action,
      ) async {
    void report(String? error, String successMessage) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? successMessage),
          backgroundColor: error == null ? Colors.green : Colors.redAccent,
          duration: Duration(seconds: error == null ? 3 : 6),
        ),
      );
    }

    switch (action) {
      case _DepartmentAction.edit:
        showDialog(
          context: context,
          builder: (_) => DepartmentDialog(department: department),
        );

      case _DepartmentAction.toggleActive:
        final error = await toggleDepartmentActive(ref, department);
        report(
          error,
          department.isActive
              ? '${department.code} hidden from requesters.'
              : '${department.code} is available again.',
        );

      case _DepartmentAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Delete ${department.name}?',
              style: const TextStyle(
                  color: AdminColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
            content: const Text(
              'This cannot be undone. Deactivating instead keeps it out of '
                  'the requester\'s list without losing the record.',
              style: TextStyle(color: AdminColors.textMuted, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel',
                    style: TextStyle(color: AdminColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final error = await deleteDepartment(ref, department.id);
        report(error, '${department.name} deleted.');
    }
  }
}

class _DepartmentRow extends StatelessWidget {
  final AdminDepartmentModel department;
  final bool busy;
  final void Function(_DepartmentAction) onAction;

  const _DepartmentRow({
    required this.department,
    required this.busy,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final active = department.isActive;
    final pillBg = active ? const Color(0xFFE6F7EC) : const Color(0xFFECEFF5);
    final pillFg = active ? const Color(0xFF16A34A) : AdminColors.textMuted;

    const menuText = TextStyle(color: AdminColors.navy, fontSize: 13);
    const disabledText = TextStyle(color: Color(0xFFA0A8BC), fontSize: 13);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AdminColors.cardShadow,
      ),
      child: Row(
        children: [
          // The code itself is the icon — it's short, unique and the thing
          // an admin scans for.
          Container(
            width: 56,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              department.code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdminColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  department.usageLabel,
                  style: const TextStyle(
                      color: AdminColors.textMuted, fontSize: 13.5),
                ),
              ],
            ),
          ),

          if (!department.canEditCode)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Tooltip(
                message: 'Code locked — trips already carry it',
                child: Icon(Icons.lock_outline,
                    size: 18, color: Color(0xFFA0A8BC)),
              ),
            ),

          // Active / Inactive pill
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              active ? 'Active' : 'Inactive',
              style: TextStyle(
                  color: pillFg, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),

          PopupMenuButton<_DepartmentAction>(
            enabled: !busy,
            tooltip: 'Department actions',
            color: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.more_vert, color: AdminColors.navy, size: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: onAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _DepartmentAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: AdminColors.navy),
                    SizedBox(width: 10),
                    Text('Edit', style: menuText),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _DepartmentAction.toggleActive,
                child: Row(
                  children: [
                    Icon(
                      active
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                      color: AdminColors.navy,
                    ),
                    const SizedBox(width: 10),
                    Text(active ? 'Hide from requesters' : 'Make available',
                        style: menuText),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _DepartmentAction.delete,
                // The backend refuses a used department with a 409, so the
                // menu says why rather than failing after the tap.
                enabled: department.canDelete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 16,
                        color: department.canDelete
                            ? const Color(0xFFE53935)
                            : const Color(0xFFA0A8BC)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        department.canDelete
                            ? 'Delete'
                            : 'In use — hide it instead',
                        style: department.canDelete
                            ? const TextStyle(
                            color: Color(0xFFE53935), fontSize: 13)
                            : disabledText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE3EDFF) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AdminColors.blue : AdminColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AdminColors.blue : AdminColors.navy,
              fontSize: 13.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      'active' => 'No active departments.',
      'inactive' => 'No hidden departments.',
      _ => 'No departments yet.',
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.apartment_outlined,
              color: Color(0xFFB7BECF), size: 44),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: AdminColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Requesters must pick a department when booking, so add at\n'
                'least one before they can submit a trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AdminColors.textMuted, fontSize: 12.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String detail;
  final VoidCallback onRetry;

  const _ErrorView({required this.detail, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 34),
          const SizedBox(height: 10),
          const Text('Could not load departments',
              style: TextStyle(
                  color: AdminColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AdminColors.textMuted, fontSize: 12),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}