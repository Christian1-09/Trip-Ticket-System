// features/head_driver/presentation/widgets/hd_trip_card.dart
//
// Head Driver approval card. Same look as the driver's DriverScheduleCard
// (white card, blue date column, blue strip, real vehicle photo) plus the
// Reject / Approve (or Assign Driver) buttons.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _navy = Color(0xFF0B1B3F);
const _blue = Color(0xFF1E6FE8);
const _muted = Color(0xFF6B7385);
const _yellow = Color(0xFFFFC928);
const _red = Color(0xFFE5394A);
const _green = Color(0xFF22A45D);

enum HdCardStatus { pending, declined }

class HdTripCard extends StatelessWidget {
  final DateTime date;
  final String route; // "Katipunan  →  Dipolog"
  final String time; // "1:30 PM - 3:33 PM"
  final String requesterName;
  final String detailLine; // "Driver: Juan · Van (ABC 123)"
  final String? vehicleImageUrl; // full URL (already passed through ApiConfig.mediaUrl)
  final bool isUrgent;
  final HdCardStatus status;

  final VoidCallback? onTap;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;
  final VoidCallback? onAssign;

  const HdTripCard({
    super.key,
    required this.date,
    required this.route,
    required this.time,
    required this.requesterName,
    required this.detailLine,
    this.vehicleImageUrl,
    this.isUrgent = false,
    this.status = HdCardStatus.pending,
    this.onTap,
    this.onReject,
    this.onApprove,
    this.onAssign,
  });

  bool get _hasActions => onReject != null || onApprove != null || onAssign != null;

  @override
  Widget build(BuildContext context) {
    final declined = status == HdCardStatus.declined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DateColumn(date: date, urgent: isUrgent),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Strip(
                          title: declined ? 'Needs New Driver' : 'Vehicle Request',
                          label: declined ? 'DECLINED' : 'PENDING',
                          icon: declined
                              ? Icons.person_off_rounded
                              : Icons.hourglass_top_rounded,
                          fg: declined ? const Color(0xFFC62835) : const Color(0xFFB07C00),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12, 10, 8, _hasActions ? 6 : 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Line(
                                      icon: Icons.location_on,
                                      iconColor: _blue,
                                      text: route,
                                      bold: true,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    _Line(icon: Icons.schedule, text: time),
                                    const SizedBox(height: 5),
                                    _Line(
                                      icon: Icons.person,
                                      text: requesterName,
                                      bold: true,
                                    ),
                                    const SizedBox(height: 5),
                                    _Line(
                                      icon: Icons.airport_shuttle_rounded,
                                      text: detailLine,
                                      small: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _Photo(url: vehicleImageUrl),
                              const SizedBox(width: 6),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F0FD),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_right,
                                    size: 18, color: _blue),
                              ),
                            ],
                          ),
                        ),
                        if (_hasActions)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 2, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (onReject != null)
                                  _PillButton(
                                    label: 'Reject',
                                    icon: Icons.cancel_rounded,
                                    background: Colors.white,
                                    foreground: _red,
                                    borderColor: _red,
                                    onTap: onReject,
                                  ),
                                if (onReject != null && onApprove != null)
                                  const SizedBox(width: 8),
                                if (onApprove != null)
                                  _PillButton(
                                    label: 'Approve',
                                    icon: Icons.check_circle_rounded,
                                    background: _green,
                                    foreground: Colors.white,
                                    onTap: onApprove,
                                  ),
                                if (onAssign != null)
                                  _PillButton(
                                    label: 'Assign Driver',
                                    icon: Icons.person_add_alt_1_rounded,
                                    background: _blue,
                                    foreground: Colors.white,
                                    onTap: onAssign,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final DateTime date;
  final bool urgent;

  const _DateColumn({required this.date, required this.urgent});

  @override
  Widget build(BuildContext context) {
    final showYear = date.year != DateTime.now().year;

    return Container(
      width: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B4FD6), Color(0xFF0A2C8F)],
        ),
        border: urgent
            ? const Border(left: BorderSide(color: _yellow, width: 4))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEE').format(date).toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '${date.day}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          if (showYear)
            Text(
              '${date.year}',
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10),
            ),
          if (urgent) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'URGENT',
                style: TextStyle(
                  color: _navy,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  final String title;
  final String label;
  final IconData icon;
  final Color fg;

  const _Strip({
    required this.title,
    required this.label,
    required this.icon,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1B3FB0)]),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 11, color: fg),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
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

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final bool bold;
  final bool small;
  final int maxLines;

  const _Line({
    required this.icon,
    required this.text,
    this.iconColor = _navy,
    this.bold = false,
    this.small = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: small ? _muted : _navy,
              fontSize: small ? 10.5 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

/// Real vehicle photo from the server; van icon while loading or if missing.
class _Photo extends StatelessWidget {
  final String? url;
  const _Photo({required this.url});

  static const _placeholder = Icon(
    Icons.airport_shuttle_rounded,
    color: Color(0xFFA9B3C4),
    size: 30,
  );

  @override
  Widget build(BuildContext context) {
    final u = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 74,
        height: 50,
        color: const Color(0xFFF1F4F9),
        alignment: Alignment.center,
        child: u == null
            ? _placeholder
            : Image.network(
          u,
          width: 74,
          height: 50,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder,
          errorBuilder: (_, __, ___) => _placeholder,
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = StadiumBorder(
      side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
    );
    return Material(
      color: background,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}