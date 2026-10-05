import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/LoginPage.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:jtrips_app/features/profile/widgets/account_menu.dart';
// TODO: adjust this import to wherever your AppMedia class lives.

import '../../core/theme/media.dart';
import '../driver/presentation/screens/driver_profile_screen.dart';
import 'widgets/profile_header.dart';
import 'profile_controller.dart';

class _Palette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1E6FE0);
  static const yellow = Color(0xFFFFC629);
  static const pageBg = Color(0xFFF4F7FC);
  static const border = Color(0xFFE3E9F3);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
  static const red = Color(0xFFE53935);
}

/// The one profile screen for every role.
///
/// Requester uses `const ProfileScreen()`.
/// Driver / Head Driver use the same screen and pass their own extra rows
/// through [extraSections] — same design, one implementation.
class ProfileScreen extends ConsumerWidget {
  /// Role-specific groups rendered between the header and "Accounts".
  final List<ProfileMenuSection> extraSections;

  /// Optional line under the email (driver code, etc.).
  final String? headerSubtitle;

  const ProfileScreen({
    super.key,
    this.extraSections = const [],
    this.headerSubtitle,
  });

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _Palette.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: _Palette.red, size: 28),
        ),
        title: const Text(
          'Log out?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _Palette.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'You will need to sign in again to book or manage trips.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _Palette.textMuted, fontSize: 14, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textDark,
                    side: const BorderSide(color: _Palette.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Log out',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    // Grab the navigator BEFORE the await — `context` may be gone after it.
    final navigator = Navigator.of(context, rootNavigator: true);

    // Clears the stored access + refresh tokens and flips auth state.
    await ref.read(authControllerProvider.notifier).logout();

    // Drop the cached profile so the next user who logs in on this device
    // never sees the previous user's name or avatar for a frame.
    ref.invalidate(profileControllerProvider);

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _Palette.pageBg,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const _ProfileBanner(),

              // ---------- Profile card (overlaps the banner) ----------
              Transform.translate(
                offset: const Offset(0, -56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _WhiteCard(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: profileState.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: CircularProgressIndicator(color: _Palette.blue),
                        ),
                      ),
                      error: (err, _) => Column(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: _Palette.red, size: 34),
                          const SizedBox(height: 8),
                          const Text(
                            'Could not load profile',
                            style: TextStyle(
                              color: _Palette.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: _Palette.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () =>
                                ref.read(profileControllerProvider.notifier).load(),
                            icon: const Icon(Icons.refresh_rounded,
                                color: _Palette.blue, size: 18),
                            label: const Text(
                              'Retry',
                              style: TextStyle(
                                color: _Palette.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      data: (user) =>
                          ProfileHeader(user: user, subtitle: headerSubtitle),
                    ),
                  ),
                ),
              ),

              // ---------- Menu sections ----------
              Transform.translate(
                offset: const Offset(0, -36),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in extraSections) ...[
                        _SectionTitle(section.title),
                        _SectionCard(children: section.items),
                      ],
                      const _SectionTitle('Account'),
                      _SectionCard(
                        children: [
                          AccountMenu(
                            label: 'Dark mode',
                            icon: Icons.dark_mode_outlined,
                            onTap: () => _notYet(context, 'Dark mode'),
                          ),
                          AccountMenu(
                            label: 'Notification',
                            icon: Icons.notifications_outlined,
                            onTap: () => _notYet(context, 'Notification settings'),
                          ),
                          AccountMenu(
                            label: 'Data and Privacy',
                            icon: Icons.privacy_tip_outlined,
                            onTap: () => _notYet(context, 'Data and Privacy'),
                          ),
                        ],
                      ),
                      const _SectionTitle('Safety & Support'),
                      _SectionCard(
                        children: [
                          AccountMenu(
                            label: 'Report technical problem',
                            icon: Icons.warning_amber_rounded,
                            onTap: () => _notYet(context, 'Reporting'),
                          ),
                          AccountMenu(
                            label: 'Help & support',
                            icon: Icons.support_agent_outlined,
                            onTap: () => _notYet(context, 'Help & support'),
                          ),
                          AccountMenu(
                            label: 'Legal & policies',
                            icon: Icons.policy_outlined,
                            onTap: () => _notYet(context, 'Legal & policies'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _LogoutButton(onTap: () => _confirmAndLogout(context, ref)),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'JTRIPS • Travel made easy',
                          style: TextStyle(color: _Palette.textMuted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _notYet(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Blue photo banner at the top, same style as the Trip Ticket header.
class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 200 + topInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppMedia.scheduleHeaderImage,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF0B5ED7).withOpacity(0.95),
                  const Color(0xFF1E88E5).withOpacity(0.70),
                  const Color(0xFF1E88E5).withOpacity(0.10),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'JTRIPS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Transform.rotate(
                      angle: -0.5,
                      child: const Icon(Icons.send_rounded,
                          color: _Palette.yellow, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your account and settings',
                  style: TextStyle(color: Colors.white, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _WhiteCard({required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _Palette.navy.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, top: 20, bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _Palette.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    ),
  );
}

/// White rounded card that stacks menu rows with thin dividers between them.
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(const Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: _Palette.border,
        ));
      }
      rows.add(children[i]);
    }

    return _WhiteCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: rows),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log out',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _Palette.red,
          backgroundColor: _Palette.red.withOpacity(0.06),
          side: BorderSide(color: _Palette.red.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}