// features/admin/presentation/screens/vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/add_vehicle_dialog.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/edit_vehicle_dialog.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/admin_vehicle_card.dart';
import '../../data/models/vehicle_model.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  // ---------------------------------------------------------------------
  // Actions
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
        backgroundColor: const Color(0xFF141B4D),
        title: const Text('Delete vehicle', style: TextStyle(color: Colors.white)),
        content: Text(
          'Permanently delete ${vehicle.model} (${vehicle.plateNumber})? '
              'This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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

    return Stack(
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
                        Text('Vehicles',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        Text('Manage and monitor your entire fleet in real-time',
                            style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidate(vehicleListProvider),
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) => const AddVehicleDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text('Add Vehicles',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4EDB),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: ['All Vehicles', 'Available', 'On Trip', 'Maintenance', 'Inactive']
                    .map((label) {
                  final isSelected = label == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () =>
                      ref.read(vehicleFilterProvider.notifier).state = label,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : const Color(0xFF141B4D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected ? Colors.amber : Colors.white24),
                        ),
                        child: Text(label,
                            style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0A0F35)
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

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
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('$err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        TextButton(
                          onPressed: () => ref.invalidate(vehicleListProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (vehicles) {
                    final filtered = switch (filter) {
                      'Available' => vehicles
                          .where((v) => v.status == VehicleStatus.active)
                          .toList(),
                      'On Trip' => vehicles
                          .where((v) => v.status == VehicleStatus.onTrip)
                          .toList(),
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
                            style: TextStyle(color: Colors.white54)),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisExtent: 356,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
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
            color: Colors.black38,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
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
      backgroundColor: const Color(0xFF141B4D),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Change status',
              style: TextStyle(color: Colors.white, fontSize: 17)),
          const SizedBox(height: 2),
          Text('${widget.vehicle.model} · ${widget.vehicle.plateNumber}',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._options.entries.map((entry) {
            final selected = entry.key == _selected;
            return InkWell(
              onTap: () => setState(() => _selected = entry.key),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: selected ? Colors.amber : Colors.white38,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.value.$1,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600)),
                          Text(entry.value.$2,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          const Text(
            'Trips already booked on this vehicle are not cancelled — you will be '
                'told which ones are affected.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B4EDB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Apply', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}