// features/admin/presentation/widgets/driver_assignment_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

import '../../data/models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

/// Multi-select driver picker for the add and edit vehicle dialogs.
///
/// A vehicle can have any number of drivers, and at most one of them is
/// primary. The star is what sets primary; ticking a driver never changes
/// who the primary is, except when it's the first one selected.
class DriverAssignmentField extends ConsumerStatefulWidget {
  final List<VehicleAssignmentInput> initial;
  final ValueChanged<List<VehicleAssignmentInput>> onChanged;

  const DriverAssignmentField({
    super.key,
    this.initial = const [],
    required this.onChanged,
  });

  @override
  ConsumerState<DriverAssignmentField> createState() =>
      _DriverAssignmentFieldState();
}

class _DriverAssignmentFieldState extends ConsumerState<DriverAssignmentField> {
  late Set<String> _selected;
  String? _primaryId;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial.map((a) => a.driverId).toSet();
    for (final a in widget.initial) {
      if (a.isPrimary) _primaryId = a.driverId;
    }
  }

  void _emit() {
    widget.onChanged(
      _selected
          .map((id) => VehicleAssignmentInput(
        driverId: id,
        isPrimary: id == _primaryId,
      ))
          .toList(),
    );
  }

  void _toggle(String driverId) {
    setState(() {
      if (_selected.contains(driverId)) {
        _selected.remove(driverId);
        // Unassigning the primary leaves the vehicle with no primary rather
        // than silently promoting someone the admin didn't choose.
        if (_primaryId == driverId) _primaryId = null;
      } else {
        _selected.add(driverId);
        // The first driver added is the obvious primary; after that the
        // admin decides with the star.
        _primaryId ??= driverId;
      }
    });
    _emit();
  }

  void _setPrimary(String driverId) {
    setState(() {
      if (!_selected.contains(driverId)) _selected.add(driverId);
      // Tapping the star of the current primary clears it — a vehicle is
      // allowed to have drivers but no designated primary.
      _primaryId = _primaryId == driverId ? null : driverId;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(assignableDriversProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ASSIGNED DRIVERS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              _selected.isEmpty ? 'Optional' : '${_selected.length} selected',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1442),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: driversAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Could not load drivers.\n$err',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 11),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(assignableDriversProvider),
                    child: const Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            data: (drivers) {
              if (drivers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'No approved drivers yet. Approve one in the Drivers '
                        'screen first.',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                );
              }

              return ConstrainedBox(
                // Scrolls rather than stretching the dialog off-screen once
                // the campus has more than a handful of drivers.
                constraints: const BoxConstraints(maxHeight: 190),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    final isSelected = _selected.contains(driver.id);
                    final isPrimary = _primaryId == driver.id;

                    return _DriverRow(
                      driver: driver,
                      isSelected: isSelected,
                      isPrimary: isPrimary,
                      onToggle: () => _toggle(driver.id),
                      onSetPrimary: () => _setPrimary(driver.id),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap the star to mark the primary driver. This is for records only '
              '— any driver can still be booked on any vehicle.',
          style: TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}

class _DriverRow extends StatelessWidget {
  final VehicleDriver driver;
  final bool isSelected;
  final bool isPrimary;
  final VoidCallback onToggle;
  final VoidCallback onSetPrimary;

  const _DriverRow({
    required this.driver,
    required this.isSelected,
    required this.isPrimary,
    required this.onToggle,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConfig.mediaUrl(driver.avatarUrl);

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                activeColor: const Color(0xFF29B6F6),
                side: BorderSide(color: Colors.white.withOpacity(0.4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF29B6F6).withOpacity(0.25),
              backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                driver.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  if (driver.driverCode != null)
                    Text(
                      driver.driverCode!,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onSetPrimary,
              tooltip: isPrimary ? 'Primary driver' : 'Set as primary',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                isPrimary ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: isPrimary ? Colors.amber : Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}