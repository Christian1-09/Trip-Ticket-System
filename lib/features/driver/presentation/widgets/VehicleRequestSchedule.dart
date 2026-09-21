// features/driver/presentation/widgets/VehicleRequestSchedule.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// A trip request card for the Head Driver's approval list.
///
/// Shows what he needs to decide: who is asking, when, where, which
/// vehicle and which driver. Approve/Reject are optional — pass neither and
/// use [extraActionLabel] instead (for example "Assign Driver").
class VehicleRequestSchedule extends StatelessWidget {
  final String requesterName;
  final String department;
  final String date;
  final String time;
  final String destination;
  final String vehicleLabel;
  final String driverName;
  final bool isUrgent;
  final String headerLabel;

  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final String? extraActionLabel;
  final VoidCallback? onExtraAction;

  const VehicleRequestSchedule({
    super.key,
    required this.requesterName,
    required this.department,
    required this.date,
    required this.time,
    required this.destination,
    required this.vehicleLabel,
    required this.driverName,
    this.isUrgent = false,
    this.headerLabel = 'Vehicle Request',
    this.onTap,
    this.onDetailsTap,
    this.onApprove,
    this.onReject,
    this.extraActionLabel,
    this.onExtraAction,
  });

  String get _initials {
    final parts = requesterName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  bool get _hasActions =>
      onApprove != null || onReject != null || onExtraAction != null;

  @override
  Widget build(BuildContext context) {
    final borderColor = isUrgent ? AppColors.accentYellow : AppColors.statusBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDeepBlue,
          border: Border.all(color: borderColor.withOpacity(0.75)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(label: headerLabel, isUrgent: isUrgent),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.statusBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(CupertinoIcons.calendar,
                                  size: 14, color: CupertinoColors.systemGrey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  date,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            requesterName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            department,
                            style: const TextStyle(
                                color: CupertinoColors.systemGrey, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          _infoRow(CupertinoIcons.location_solid, destination),
                          _infoRow(CupertinoIcons.car_detailed, vehicleLabel),
                          _infoRow(CupertinoIcons.person_crop_circle, driverName),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDetailsTap ?? onTap,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.statusBlue.withOpacity(0.2),
                          border: Border.all(color: AppColors.statusBlue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.chevron_forward,
                          color: CupertinoColors.activeBlue,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasActions)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onReject != null) ...[
                        _ActionButton(
                          label: 'Reject',
                          color: CupertinoColors.systemRed,
                          onTap: onReject,
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (onApprove != null)
                        _ActionButton(
                          label: 'Approve',
                          color: CupertinoColors.activeGreen,
                          onTap: onApprove,
                        ),
                      if (onExtraAction != null)
                        _ActionButton(
                          label: extraActionLabel ?? 'Open',
                          color: CupertinoColors.activeBlue,
                          onTap: onExtraAction,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: CupertinoColors.systemGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String label;
  final bool isUrgent;

  const _CardHeader({required this.label, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.statusBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(CupertinoIcons.calendar,
                size: 16, color: CupertinoColors.activeBlue),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'URGENT',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}