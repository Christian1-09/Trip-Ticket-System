// features/admin/presentation/screens/locations_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/admin_colors.dart';
import '../../../data/models/location_model.dart';
import '../../providers/location_provider.dart';
import '../../widgets/location_dialog.dart';

enum _LocationAction { edit, toggleActive, delete }

class LocationsTab extends ConsumerWidget {
  const LocationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(adminLocationListProvider);
    final filter = ref.watch(locationFilterProvider);
    final busy = ref.watch(locationBusyProvider);

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destinations',
                              style: TextStyle(
                                  color: AdminColors.navy,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text(
                            'Places requesters can pick when booking, with '
                                'the driving time from Katipunan.',
                            style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: busy
                            ? null
                            : () => showDialog(
                          context: context,
                          builder: (_) => const LocationDialog(),
                        ),
                        icon: const Icon(Icons.add, size: 22),
                        label: const Text('Add destination',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
                      onTap: () => ref.read(locationFilterProvider.notifier).state = '',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Active',
                      selected: filter == 'active',
                      onTap: () =>
                      ref.read(locationFilterProvider.notifier).state = 'active',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Inactive',
                      selected: filter == 'inactive',
                      onTap: () =>
                      ref.read(locationFilterProvider.notifier).state = 'inactive',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── List ─────────────────────────────────────────
                Expanded(
                  child: locationsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _ErrorView(
                      detail: '$err',
                      onRetry: () => ref.invalidate(adminLocationListProvider),
                    ),
                    data: (locations) {
                      if (locations.isEmpty) return _EmptyView(filter: filter);

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: locations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _LocationRow(
                          location: locations[index],
                          busy: busy,
                          onAction: (action) =>
                              _handleAction(context, ref, locations[index], action),
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
      ),
    );
  }

  Future<void> _handleAction(
      BuildContext context,
      WidgetRef ref,
      AdminLocationModel location,
      _LocationAction action,
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
      case _LocationAction.edit:
        showDialog(
          context: context,
          builder: (_) => LocationDialog(location: location),
        );

      case _LocationAction.toggleActive:
        final error = await toggleLocationActive(ref, location);
        report(
          error,
          location.isActive
              ? '${location.name} hidden from requesters.'
              : '${location.name} is available again.',
        );

      case _LocationAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Delete ${location.name}?',
              style: const TextStyle(
                  color: AdminColors.navy, fontSize: 18, fontWeight: FontWeight.w800),
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
        final error = await deleteLocation(ref, location.id);
        report(error, '${location.name} deleted.');
    }
  }
}

class _LocationRow extends StatelessWidget {
  final AdminLocationModel location;
  final bool busy;
  final void Function(_LocationAction) onAction;

  const _LocationRow({
    required this.location,
    required this.busy,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final active = location.isActive;
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
          // Pin icon in a soft blue square
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AdminColors.blue, size: 24),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(location.usageLabel,
                    style: const TextStyle(color: AdminColors.textMuted, fontSize: 13.5)),
              ],
            ),
          ),

          // Travel-time chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 17, color: AdminColors.blue),
                const SizedBox(width: 8),
                Text(
                  location.travelLabel,
                  style: const TextStyle(
                    color: AdminColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

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
              style: TextStyle(color: pillFg, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),

          PopupMenuButton<_LocationAction>(
            enabled: !busy,
            tooltip: 'Destination actions',
            color: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.more_vert, color: AdminColors.navy, size: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: onAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _LocationAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: AdminColors.navy),
                    SizedBox(width: 10),
                    Text('Edit', style: menuText),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _LocationAction.toggleActive,
                child: Row(
                  children: [
                    Icon(
                      active ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                value: _LocationAction.delete,
                // The backend refuses a used location with a 409, so the
                // menu says why rather than failing after the tap.
                enabled: location.canDelete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 16,
                        color: location.canDelete
                            ? const Color(0xFFE53935)
                            : const Color(0xFFA0A8BC)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location.canDelete ? 'Delete' : 'In use — hide it instead',
                        style: location.canDelete
                            ? const TextStyle(color: Color(0xFFE53935), fontSize: 13)
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
      'active' => 'No active destinations.',
      'inactive' => 'No hidden destinations.',
      _ => 'No destinations yet.',
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_outlined, color: Color(0xFFB7BECF), size: 44),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(
                  color: AdminColors.navy, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Until one is added, requesters use the "Other" option and\n'
                'estimate the travel time themselves.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AdminColors.textMuted, fontSize: 12.5, height: 1.5),
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
          const Text('Could not load destinations',
              style: TextStyle(
                  color: AdminColors.navy, fontSize: 15, fontWeight: FontWeight.w600)),
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