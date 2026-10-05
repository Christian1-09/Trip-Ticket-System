// features/admin/presentation/screens/locations_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/location_model.dart';
import '../providers/location_provider.dart';
import '../widgets/location_dialog.dart';

enum _LocationAction { edit, toggleActive, delete }

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(adminLocationListProvider);
    final filter = ref.watch(locationFilterProvider);
    final busy = ref.watch(locationBusyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F35),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destinations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Places requesters can pick when booking, with '
                                'the driving time from Katipunan.',
                            style:
                            TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: busy
                          ? null
                          : () => showDialog(
                        context: context,
                        builder: (_) => const LocationDialog(),
                      ),
                      icon: const Icon(Icons.add,
                          size: 18, color: Color(0xFF0A0F35)),
                      label: const Text(
                        'Add destination',
                        style: TextStyle(
                          color: Color(0xFF0A0F35),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: filter == '',
                      onTap: () =>
                      ref.read(locationFilterProvider.notifier).state = '',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Active',
                      selected: filter == 'active',
                      onTap: () => ref
                          .read(locationFilterProvider.notifier)
                          .state = 'active',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Inactive',
                      selected: filter == 'inactive',
                      onTap: () => ref
                          .read(locationFilterProvider.notifier)
                          .state = 'inactive',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: locationsAsync.when(
                    loading: () =>
                    const Center(child: CircularProgressIndicator()),
                    error: (err, _) => _ErrorView(
                      detail: '$err',
                      onRetry: () => ref.invalidate(adminLocationListProvider),
                    ),
                    data: (locations) {
                      if (locations.isEmpty) return _EmptyView(filter: filter);

                      return ListView.separated(
                        itemCount: locations.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _LocationRow(
                          location: locations[index],
                          busy: busy,
                          onAction: (action) => _handleAction(
                            context,
                            ref,
                            locations[index],
                            action,
                          ),
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
                color: Colors.black38,
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
            backgroundColor: const Color(0xFF141B4D),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(
              'Delete ${location.name}?',
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            content: const Text(
              'This cannot be undone. Deactivating instead keeps it out of '
                  'the requester\'s list without losing the record.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent)),
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
    final activeColor =
    location.isActive ? const Color(0xFF2E7D32) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF29B6F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: Color(0xFF29B6F6), size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location.usageLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule,
                    size: 13, color: Color(0xFF29B6F6)),
                const SizedBox(width: 5),
                Text(
                  location.travelLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              location.isActive ? 'Active' : 'Hidden',
              style: TextStyle(
                color: activeColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PopupMenuButton<_LocationAction>(
            enabled: !busy,
            tooltip: 'Destination actions',
            color: const Color(0xFF1E2761),
            icon: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: onAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _LocationAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                    SizedBox(width: 10),
                    Text('Edit',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _LocationAction.toggleActive,
                child: Row(
                  children: [
                    Icon(
                      location.isActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      location.isActive
                          ? 'Hide from requesters'
                          : 'Make available',
                      style:
                      const TextStyle(color: Colors.white, fontSize: 13),
                    ),
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
                            ? Colors.redAccent
                            : Colors.white24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location.canDelete
                            ? 'Delete'
                            : 'In use — hide it instead',
                        style: TextStyle(
                          color: location.canDelete
                              ? Colors.redAccent
                              : Colors.white38,
                          fontSize: 13,
                        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF29B6F6).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF29B6F6) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF29B6F6) : Colors.white54,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
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
          const Icon(Icons.location_off_outlined,
              color: Colors.white24, size: 40),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 6),
          const Text(
            'Until one is added, requesters use the "Other" option and\n'
                'estimate the travel time themselves.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
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
              style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}