// features/admin/presentation/widgets/admin_vehicle_card.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/vehicle_model.dart';

enum VehicleCardAction { edit, changeStatus, delete, viewMap }

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
        return const Color(0xFF22C55E);
      case VehicleStatus.onTrip:
        return const Color(0xFFF59E0B);
      case VehicleStatus.maintenance:
        return const Color(0xFFEF4444);
      case VehicleStatus.inactive:
        return const Color(0xFF94A3B8);
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

  /// Only a vehicle out on the road has a position worth looking at.
  bool get _isOnTrip => vehicle.status == VehicleStatus.onTrip;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiConfig.mediaUrl(vehicle.imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AdminColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo ───────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 125,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const _NoPhoto(),
                )
                    : const _NoPhoto(),
              ),
              if (onAction != null)
                Positioned(
                  top: 10,
                  right: 10,
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

          // ── Details panel ───────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PLATE: ${vehicle.plateNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AdminColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(vehicle.model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AdminColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  Text(vehicle.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AdminColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _statBox('CAPACITY', '${vehicle.capacity}pax')),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _statBox(
                              'ODOMETER', '${vehicle.odometerCurrent ?? 0} KM')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _statBox('YEAR', '${vehicle.year ?? '—'}')),
                      const SizedBox(width: 6),
                      Expanded(child: _statBox('TRIPS', '${vehicle.trips}')),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration:
                        BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(_statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: vehicle.status == VehicleStatus.maintenance
                                    ? _statusColor
                                    : vehicle.status == VehicleStatus.inactive
                                    ? AdminColors.textMuted
                                    : const Color(0xFF16A34A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      _DriverStrip(drivers: vehicle.drivers),
                    ],
                  ),

                  // ── Live map ──────────────────────────────────────
                  // Only while the vehicle is out on the road. A parked
                  // vehicle's last fix is days old and tells nobody
                  // anything useful.
                  if (_isOnTrip && onAction != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: busy
                            ? null
                            : () => onAction!(VehicleCardAction.viewMap),
                        icon: const Icon(Icons.location_on_outlined, size: 16),
                        label: const Text(
                          'View on map',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AdminColors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AdminColors.navy, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.directions_car, size: 56, color: Color(0xFFCBD2E1)),
  );
}

/// Overlapping initials for the assigned drivers, primary first with an
/// amber ring. Shows at most three, then "+N".
class _DriverStrip extends StatelessWidget {
  final List<VehicleDriver> drivers;
  static const int _maxShown = 3;
  static const double _size = 26;

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
            color: const Color(0xFFECEFF6),
            shape: BoxShape.circle,
            border: Border.all(color: AdminColors.border),
          ),
          child: const Icon(Icons.construction, size: 14, color: Color(0xFF8A94AD)),
        ),
      );
    }

    final shown = drivers.take(_maxShown).toList();
    final extra = drivers.length - shown.length;

    const overlap = 6.0;
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
                    color: AdminColors.navy,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text('+$extra',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
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
    final primary = driver.isPrimary;

    return Container(
      width: _DriverStrip._size,
      height: _DriverStrip._size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary ? Colors.white : AdminColors.blue,
        // Primary: amber ring on white (like the mockup). Others: white ring
        // that separates the overlapping blue circles.
        border: Border.all(
          color: primary ? AdminColors.amber : Colors.white,
          width: primary ? 2 : 1.5,
        ),
        image: avatarUrl != null
            ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: avatarUrl == null
          ? Text(driver.initials,
          style: TextStyle(
              color: primary ? AdminColors.navy : Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800))
          : null,
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
    const enabledText = TextStyle(color: AdminColors.navy, fontSize: 13);
    const disabledText = TextStyle(color: Color(0xFFA0A8BC), fontSize: 13);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<VehicleCardAction>(
        enabled: enabled,
        tooltip: 'Vehicle actions',
        color: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.more_vert, color: AdminColors.navy, size: 18),
        padding: EdgeInsets.zero,
        splashRadius: 18,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: onSelected,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: VehicleCardAction.edit,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 16, color: AdminColors.navy),
                SizedBox(width: 10),
                Text('Edit details', style: enabledText),
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
                    color: canChangeStatus ? AdminColors.navy : const Color(0xFFA0A8BC)),
                const SizedBox(width: 10),
                Text(canChangeStatus ? 'Change status' : 'On a trip — status locked',
                    style: canChangeStatus ? enabledText : disabledText),
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
                    size: 16,
                    color: canDelete ? const Color(0xFFE53935) : const Color(0xFFA0A8BC)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    canDelete ? 'Delete' : 'Has $tripCount trip(s) — cannot delete',
                    style: canDelete
                        ? const TextStyle(color: Color(0xFFE53935), fontSize: 13)
                        : disabledText,
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