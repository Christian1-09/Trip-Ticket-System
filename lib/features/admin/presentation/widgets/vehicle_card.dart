// features/admin/presentation/widgets/vehicle_card.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import '../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  const VehicleCard({required this.vehicle, super.key});

  Color get _statusColor {
    switch (vehicle.status) {
      case VehicleStatus.active:
        return const Color(0xFF2E7D32);
      case VehicleStatus.onTrip:
        return const Color(0xFFF9A825);
      case VehicleStatus.maintenance:
        return const Color(0xFFC62828);
      case VehicleStatus.inactive:
        return const Color(0xFF64748B);
    }
  }

  String get _statusLabel {
    switch (vehicle.status) {
      case VehicleStatus.active:
        return 'Available';
      case VehicleStatus.onTrip:
        return 'On Trip';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.inactive:
        return 'Inactive';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.mediaUrl(vehicle.imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            color: Colors.white,
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.directions_car, size: 48, color: Colors.black26)),
            )
                : const Center(child: Icon(Icons.directions_car, size: 48, color: Colors.black26)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLATE: ${vehicle.plateNumber}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(vehicle.model,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(vehicle.type, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _statBox('CAPACITY', '${vehicle.capacity}pax')),
                    const SizedBox(width: 8),
                    Expanded(child: _statBox('ODOMETER', '${vehicle.odometerCurrent ?? 0} KM')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _statBox('YEAR', '${vehicle.year ?? '—'}')),
                    const SizedBox(width: 8),
                    Expanded(child: _statBox('TRIPS', '${vehicle.trips}')),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}