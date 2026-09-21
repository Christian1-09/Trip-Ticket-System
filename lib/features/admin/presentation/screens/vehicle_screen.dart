// features/admin/presentation/screens/vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/add_vehicle_dialog.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import '../../data/models/vehicle_model.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleListProvider);
    final filter = ref.watch(vehicleFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Vehicles',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Manage and monitor your entire fleet in real-time',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => const AddVehicleDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Vehicles', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4EDB),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: ['All Vehicles', 'Available', 'On Trip', 'Maintenance'].map((label) {
              final isSelected = label == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => ref.read(vehicleFilterProvider.notifier).state = label,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : const Color(0xFF141B4D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.amber : Colors.white24),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            color: isSelected ? const Color(0xFF0A0F35) : Colors.white70,
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
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
                    const SizedBox(height: 8),
                    const Text('Could not load vehicles', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    TextButton(
                      onPressed: () => ref.invalidate(vehicleListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (vehicles) {
                final filtered = switch (filter) {
                  'Available' => vehicles.where((v) => v.status == VehicleStatus.active).toList(),
                  'On Trip' => vehicles.where((v) => v.status == VehicleStatus.onTrip).toList(),
                  'Maintenance' => vehicles.where((v) => v.status == VehicleStatus.maintenance).toList(),
                  _ => vehicles,
                };

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No vehicles found.', style: TextStyle(color: Colors.white54)),
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
                  itemBuilder: (context, index) => VehicleCard(vehicle: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}