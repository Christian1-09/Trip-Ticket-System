// features/admin/presentation/screens/vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/add_vehicle_dialog.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/edit_vehicle_dialog.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/vehicle_map_dialog.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/admin_vehicle_card.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  static const _filters = ['All Vehicles', 'Available', 'On Trip', 'Maintenance', 'Inactive'];

  // ---------------------------------------------------------------------
  // Actions (logic unchanged)
  // ---------------------------------------------------------------------

  void _message(BuildContext context, String text, {bool error = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  Future<void> _run(
      BuildContext context,
      WidgetRef ref,
      Future<void> Function() action,
      ) async {
    ref.read(vehicleActionBusyProvider.notifier).state = true;
    try {
      await action();
      ref.invalidate(vehicleListProvider);
    } on ApiException catch (e) {
      _message(context, e.message, error: true);
    } catch (_) {
      _message(context, 'Something went wrong. Please try again.', error: true);
    } finally {
      ref.read(vehicleActionBusyProvider.notifier).state = false;
    }
  }

  Future<void> _changeStatus(
      BuildContext context, WidgetRef ref, VehicleModel vehicle) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _StatusDialog(vehicle: vehicle),
    );
    if (picked == null || !context.mounted) return;

    await _run(context, ref, () async {
      final affected =
      await ref.read(vehicleRepositoryProvider).setStatus(vehicle.id, picked);

      if (affected.isEmpty) {
        _message(context, '${vehicle.plateNumber} is now ${_label(picked)}.');
      } else {
        // The trips are NOT cancelled — the admin has to deal with them.
        _message(
          context,
          '${vehicle.plateNumber} is now ${_label(picked)}. '
              '${affected.length} upcoming trip(s) still use it: ${affected.join(", ")}. '
              'Reassign or reject them.',
          error: true,
        );
      }
    });
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete vehicle',
            style: TextStyle(color: AdminColors.navy, fontWeight: FontWeight.w800)),
        content: Text(
          'Permanently delete ${vehicle.model} (${vehicle.plateNumber})? '
              'This cannot be undone.',
          style: const TextStyle(color: AdminColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: AdminColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await _run(context, ref, () async {
      await ref.read(vehicleRepositoryProvider).delete(vehicle.id);
      _message(context, '${vehicle.plateNumber} deleted.');
    });
  }

  /// Live position + the route driven so far. Opened from the card button,
  /// which only appears while the vehicle is ON_TRIP.
  void _viewMap(BuildContext context, VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (_) => VehicleMapDialog(
        vehicleId: vehicle.id,
        vehicleName: vehicle.model,
        plateNumber: vehicle.plateNumber,
      ),
    );
  }

  static String _label(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Available';
      case 'MAINTENANCE':
        return 'under Maintenance';
      default:
        return 'Inactive';
    }
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final filter = ref.watch(vehicleFilterProvider);
    final busy = ref.watch(vehicleActionBusyProvider);

    return ColoredBox(
      color: AdminColors.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicles',
                              style: TextStyle(
                                  color: AdminColors.navy,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Manage and monitor your entire fleet in real-time',
                              style: TextStyle(color: AdminColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () => ref.invalidate(vehicleListProvider),
                      icon: const Icon(Icons.refresh, color: AdminColors.navy, size: 26),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const AddVehicleDialog(),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add Vehicles',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AdminColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Filter pills ────────────────────────────────────
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filters
                      .map((label) => _FilterPill(
                    label: label,
                    selected: label == filter,
                    onTap: () =>
                    ref.read(vehicleFilterProvider.notifier).state = label,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 20),

                // ── Grid ────────────────────────────────────────────
                Expanded(
                  child: vehiclesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 32),
                          const SizedBox(height: 8),
                          const Text('Could not load vehicles',
                              style: TextStyle(
                                  color: AdminColors.navy, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('$err',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AdminColors.textMuted, fontSize: 11)),
                          TextButton(
                            onPressed: () => ref.invalidate(vehicleListProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (vehicles) {
                      final filtered = switch (filter) {
                        'Available' =>
                            vehicles.where((v) => v.status == VehicleStatus.active).toList(),
                        'On Trip' =>
                            vehicles.where((v) => v.status == VehicleStatus.onTrip).toList(),
                        'Maintenance' => vehicles
                            .where((v) => v.status == VehicleStatus.maintenance)
                            .toList(),
                        'Inactive' => vehicles
                            .where((v) => v.status == VehicleStatus.inactive)
                            .toList(),
                        _ => vehicles,
                      };

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No vehicles found.',
                              style: TextStyle(color: AdminColors.textMuted)),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          // 350 before the map button. An ON_TRIP card now
                          // carries a 36px button plus its gap, and the old
                          // height had about 7px of slack — not enough.
                          mainAxisExtent: 396,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final vehicle = filtered[index];
                          return VehicleCard(
                            vehicle: vehicle,
                            busy: busy,
                            onAction: (action) {
                              switch (action) {
                                case VehicleCardAction.edit:
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => EditVehicleDialog(vehicle: vehicle),
                                  );
                                  break;
                                case VehicleCardAction.changeStatus:
                                  _changeStatus(context, ref, vehicle);
                                  break;
                                case VehicleCardAction.delete:
                                  _delete(context, ref, vehicle);
                                  break;
                                case VehicleCardAction.viewMap:
                                  _viewMap(context, vehicle);
                                  break;
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminColors.amber : Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: selected ? 0 : 0.5,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: selected ? AdminColors.amber : AdminColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: AdminColors.navy,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

/// Available / Maintenance / Inactive. ON_TRIP is deliberately absent — the
/// system sets it when a trip departs and clears it on completion.
class _StatusDialog extends StatefulWidget {
  final VehicleModel vehicle;
  const _StatusDialog({required this.vehicle});

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late String _selected;

  static const _options = {
    'ACTIVE': ('Available', 'Can be booked for new trips.'),
    'MAINTENANCE': ('Maintenance', 'In the shop — hidden from new bookings.'),
    'INACTIVE': ('Inactive', 'Retired or out of service for good.'),
  };

  @override
  void initState() {
    super.initState();
    _selected = switch (widget.vehicle.status) {
      VehicleStatus.maintenance => 'MAINTENANCE',
      VehicleStatus.inactive => 'INACTIVE',
      _ => 'ACTIVE',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Change status',
              style: TextStyle(
                  color: AdminColors.navy, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${widget.vehicle.model} · ${widget.vehicle.plateNumber}',
              style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._options.entries.map((entry) {
            final selected = entry.key == _selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selected = entry.key),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFFF7DD) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selected ? AdminColors.amber : AdminColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: selected ? AdminColors.orange : const Color(0xFFA0A8BC),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value.$1,
                                style: const TextStyle(
                                    color: AdminColors.navy,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700)),
                            Text(entry.value.$2,
                                style: const TextStyle(
                                    color: AdminColors.textMuted, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          const Text(
            'Trips already booked on this vehicle are not cancelled — you will be '
                'told which ones are affected.',
            style: TextStyle(color: AdminColors.textMuted, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AdminColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AdminColors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}