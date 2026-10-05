import 'package:flutter/material.dart';

class _Palette {
  static const blue = Color(0xFF1E6FE0);
  static const lightBlue = Color(0xFFE6F0FD);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF9AA3B5);
  static const red = Color(0xFFE53935);
}

/// The ONE AccountMenu in the app.
///
/// Previously this class was declared twice — once in
/// instructor_profile_screen.dart and once in driver_profile_screen.dart.
/// Two classes with the same name is the exact defect that already broke
/// the build with TripStopEntry and VehicleCard, so it now lives in a
/// single file that every profile screen imports.
class AccountMenu extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  /// Red styling + no chevron. Used for destructive rows like "Log out".
  final bool isDestructive;

  /// Replaces the chevron (e.g. a Switch for Dark mode, or a spinner).
  final Widget? trailing;

  const AccountMenu({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? _Palette.red : _Palette.blue;
    final tileColor =
    isDestructive ? _Palette.red.withOpacity(0.1) : _Palette.lightBlue;
    final textColor = isDestructive ? _Palette.red : _Palette.textDark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                (isDestructive
                    ? const SizedBox.shrink()
                    : const Icon(Icons.chevron_right_rounded,
                    color: _Palette.textMuted, size: 24)),
          ],
        ),
      ),
    );
  }
}

/// A titled group of [AccountMenu] rows. Lets a role add its own section
/// (e.g. the driver's "Driving" section) without copying the screen.
class ProfileMenuSection {
  final String title;
  final List<Widget> items;
  const ProfileMenuSection({required this.title, required this.items});
}