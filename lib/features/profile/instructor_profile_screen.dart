import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';
import 'profile_controller.dart';

/// Top-level function (required by compute()) that center-crops the image
/// to a square using its shorter side, resizes it down to a standard
/// avatar size, and re-encodes it as a compressed JPEG. Runs in a
/// background isolate so a large phone photo doesn't jank the UI thread.
Uint8List _prepareAvatarImage(Uint8List inputBytes) {
  final decoded = img.decodeImage(inputBytes);
  if (decoded == null) {
    // Couldn't decode (corrupt/unsupported format) — fall back to the
    // original bytes rather than crashing; the backend will reject it
    // with a clear error if it's genuinely not an image.
    return inputBytes;
  }

  final size = decoded.width < decoded.height ? decoded.width : decoded.height;
  final offsetX = (decoded.width - size) ~/ 2;
  final offsetY = (decoded.height - size) ~/ 2;
  final cropped = img.copyCrop(decoded, x: offsetX, y: offsetY, width: size, height: size);

  final resized = img.copyResize(cropped, width: 512, height: 512);

  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            profileState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Could not load profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    TextButton(
                      onPressed: () => ref.read(profileControllerProvider.notifier).load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (user) => _ProfileHeader(user: user),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Accounts",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                          child: Column(
                            children: [
                              AccountMenu(
                                label: "Dark mode",
                                icon: Icons.shield_moon,
                                onTap: () {},
                              ),
                              AccountMenu(
                                label: "Notification",
                                icon: Icons.notifications_outlined,
                                onTap: () {},
                              ),
                              AccountMenu(
                                label: "Data and Privacy",
                                icon: Icons.home_outlined,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Safety",
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                          child: Column(
                            children: [
                              AccountMenu(
                                label: "Report technical problem",
                                icon: Icons.warning_amber_outlined,
                                onTap: () {},
                              ),
                              AccountMenu(
                                label: "Help & support",
                                icon: Icons.support_agent_outlined,
                                onTap: () {},
                              ),
                              AccountMenu(
                                label: "Legal & policies",
                                icon: Icons.policy_outlined,
                                onTap: () {},
                              ),
                              AccountMenu(
                                label: "Log out",
                                icon: Icons.logout_outlined,
                                onTap: () {},
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
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerStatefulWidget {
  final AppUser user;
  const _ProfileHeader({required this.user});

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _isUploading = false;

  Future<void> _pickAndUploadAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    final pickedBytes = result.files.single.bytes!;

    setState(() => _isUploading = true);
    try {
      // Runs in a background isolate — won't freeze the UI even on a
      // large phone camera photo.
      final processedBytes = await compute(_prepareAvatarImage, pickedBytes);

      await ref.read(profileControllerProvider.notifier).uploadAvatar(
        bytes: processedBytes,
        filename: 'avatar.jpg', // always jpg now, since we re-encode it
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final avatarUrl = ApiConfig.mediaUrl(user.avatarUrl);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.statusBlue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.statusBlue.withOpacity(0.70),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 34, color: Color(0xFFB0B0B0))
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadAvatar,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: _isUploading
                          ? const Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF071166),
                        ),
                      )
                          : const Icon(Icons.add, size: 14, color: Color(0xFF071166)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user.fullName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }
}

class AccountMenu extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const AccountMenu({
    super.key,
    required this.label,
    this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}