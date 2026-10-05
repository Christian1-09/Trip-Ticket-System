import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/features/auth/presentation/data/app_user.dart';

import '../profile_controller.dart';

class _Palette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1E6FE0);
  static const lightBlue = Color(0xFFE6F0FD);
  static const yellow = Color(0xFFFFC629);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
}

/// Top-level function (required by compute()) that center-crops the image
/// to a square using its shorter side, resizes it to a standard avatar
/// size, and re-encodes it as a compressed JPEG. Runs in a background
/// isolate so a large phone photo doesn't jank the UI thread.
Uint8List prepareAvatarImage(Uint8List inputBytes) {
  final decoded = img.decodeImage(inputBytes);
  if (decoded == null) return inputBytes;

  final size = decoded.width < decoded.height ? decoded.width : decoded.height;
  final offsetX = (decoded.width - size) ~/ 2;
  final offsetY = (decoded.height - size) ~/ 2;
  final cropped =
  img.copyCrop(decoded, x: offsetX, y: offsetY, width: size, height: size);

  final resized = img.copyResize(cropped, width: 512, height: 512);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

/// Avatar + name + email + the yellow "change photo" badge.
/// Identical for every role, so it lives here instead of in each screen.
class ProfileHeader extends ConsumerStatefulWidget {
  final AppUser user;

  /// Optional line under the email — the driver uses it for his driver code.
  final String? subtitle;

  const ProfileHeader({super.key, required this.user, this.subtitle});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
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
      final processedBytes = await compute(prepareAvatarImage, pickedBytes);
      await ref.read(profileControllerProvider.notifier).uploadAvatar(
        bytes: processedBytes,
        filename: 'avatar.jpg',
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

    return Column(
      children: [
        // ---------- Avatar with gradient ring + camera badge ----------
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadAvatar,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_Palette.blue, _Palette.yellow],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.blue.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: _Palette.lightBlue,
                    backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person_rounded,
                        size: 48, color: _Palette.blue)
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _Palette.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.navy.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploading
                      ? const Padding(
                    padding: EdgeInsets.all(6),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _Palette.navy,
                    ),
                  )
                      : const Icon(Icons.photo_camera_rounded,
                      size: 15, color: _Palette.navy),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ---------- Name + email ----------
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _Palette.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline_rounded,
                size: 15, color: _Palette.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                user.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _Palette.textMuted,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),

        // ---------- Optional subtitle as a pill (e.g. driver code) ----------
        if (widget.subtitle != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _Palette.lightBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.subtitle!,
              style: const TextStyle(
                color: _Palette.blue,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}