// features/admin/presentation/widgets/admin_vehicle_card.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import '../../data/models/vehicle_model.dart';

enum VehicleCardAction { edit, changeStatus, delete }

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;

  /// Null hides the ⋮ menu entirely, so the card can also be used read-only.
  final void Function(VehicleCardAction)? onAction;

  /// Disables the menu while another action is still running.
  final bool busy;

  const VehicleCard({
    required this.vehicle,
    this.onAction,
    this.busy = false,
    super.key,
  });

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

  /// A vehicle that has been on a trip can never be deleted — the backend
  /// refuses it, so the menu says why instead of failing after the tap.
  bool get _canDelete => vehicle.trips == 0;

  /// While a vehicle is out on the road its status is owned by the system.
  bool get _canChangeStatus => vehicle.status != VehicleStatus.onTrip;

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
          Stack(
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
                      child: Icon(Icons.directions_car,
                          size: 48, color: Colors.black26)),
                )
                    : const Center(
                    child: Icon(Icons.directions_car,
                        size: 48, color: Colors.black26)),
              ),
              if (onAction != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: _ActionMenu(
                    enabled: !busy,
                    canDelete: _canDelete,
                    canChangeStatus: _canChangeStatus,
                    tripCount: vehicle.trips,
                    onSelected: onAction!,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PLATE: ${vehicle.plateNumber}',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(vehicle.model,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(vehicle.type,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _statBox('CAPACITY', '${vehicle.capacity}pax')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _statBox('ODOMETER', '${vehicle.odometerCurrent ?? 0} KM')),
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
                // Status and drivers share one row rather than stacking, so
                // the card's height is unchanged — a taller card would
                // overflow wherever this sits in a fixed-ratio grid.
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: _statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(_statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DriverStrip(drivers: vehicle.drivers),
                  ],
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
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Overlapping avatars for the assigned drivers, primary first with an
/// amber ring. Shows at most three, then "+N".
///
/// Sized to the same height as the status chip so adding it costs no
/// vertical space.
class _DriverStrip extends StatelessWidget {
  final List<VehicleDriver> drivers;
  static const int _maxShown = 3;
  static const double _size = 22;

  const _DriverStrip({required this.drivers});

  @override
  Widget build(BuildContext context) {
    if (drivers.isEmpty) {
      return Tooltip(
        message: 'No driver assigned',
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12),
          ),
          child: const Icon(Icons.person_off_outlined,
              size: 12, color: Colors.white24),
        ),
      );
    }

    final shown = drivers.take(_maxShown).toList();
    final extra = drivers.length - shown.length;

    // Each avatar after the first overlaps the one before it.
    const overlap = 7.0;
    final stripWidth =
        _size + (shown.length - 1) * (_size - overlap) + (extra > 0 ? _size - overlap : 0);

    return Tooltip(
      message: drivers
          .map((d) => d.isPrimary ? '${d.fullName} (primary)' : d.fullName)
          .join('\n'),
      child: SizedBox(
        width: stripWidth,
        height: _size,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(
                left: i * (_size - overlap),
                child: _Avatar(driver: shown[i]),
              ),
            if (extra > 0)
              Positioned(
                left: shown.length * (_size - overlap),
                child: Container(
                  width: _size,
                  height: _size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2761),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF141B4D), width: 1.5),
                  ),
                  child: Text(
                    '+$extra',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final VehicleDriver driver;
  const _Avatar({required this.driver});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConfig.mediaUrl(driver.avatarUrl);

    return Container(
      width: _DriverStrip._size,
      height: _DriverStrip._size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // The ring doubles as the separator between overlapping avatars,
        // and goes amber for the primary driver.
        border: Border.all(
          color: driver.isPrimary ? Colors.amber : const Color(0xFF141B4D),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF29B6F6).withOpacity(0.3),
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(
          driver.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final bool enabled;
  final bool canDelete;
  final bool canChangeStatus;
  final int tripCount;
  final void Function(VehicleCardAction) onSelected;

  const _ActionMenu({
    required this.enabled,
    required this.canDelete,
    required this.canChangeStatus,
    required this.tripCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F35).withOpacity(0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<VehicleCardAction>(
        enabled: enabled,
        tooltip: 'Vehicle actions',
        color: const Color(0xFF1E2761),
        icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        splashRadius: 18,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: onSelected,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: VehicleCardAction.edit,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
                SizedBox(width: 10),
                Text('Edit details', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          PopupMenuItem(
            value: VehicleCardAction.changeStatus,
            enabled: canChangeStatus,
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded,
                    size: 16,
                    color: canChangeStatus ? Colors.white70 : Colors.white24),
                const SizedBox(width: 10),
                Text(
                  canChangeStatus ? 'Change status' : 'On a trip — status locked',
                  style: TextStyle(
                      color: canChangeStatus ? Colors.white : Colors.white38,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: VehicleCardAction.delete,
            enabled: canDelete,
            child: Row(
              children: [
                Icon(Icons.delete_outline,
                    size: 16, color: canDelete ? Colors.redAccent : Colors.white24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    canDelete ? 'Delete' : 'Has $tripCount trip(s) — cannot delete',
                    style: TextStyle(
                        color: canDelete ? Colors.redAccent : Colors.white38,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}