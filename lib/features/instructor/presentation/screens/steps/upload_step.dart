// features/instructor/presentation/screens/steps/upload_step.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/trip_ticket_provider.dart';

class _Palette {
  static const navy = Color(0xFF0B1E5B);
  static const blue = Color(0xFF1E6FE0);
  static const yellow = Color(0xFFFFC629);
  static const lightBlue = Color(0xFFE6F0FD);
  static const boxFill = Color(0xFFF6FAFF);
  static const border = Color(0xFFE3E9F3);
  static const textDark = Color(0xFF0F1B3D);
  static const textMuted = Color(0xFF6B7489);
  static const urgentRed = Color(0xFFE53935);
}

class UploadStep extends ConsumerStatefulWidget {
  const UploadStep({super.key});

  @override
  ConsumerState<UploadStep> createState() => _UploadStepState();
}

class _UploadStepState extends ConsumerState<UploadStep> {
  final _urgentReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urgentReasonController.text =
        ref.read(tripTicketProvider).formData.urgentReason ?? '';
  }

  @override
  void dispose() {
    _urgentReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      // Required: without this, `bytes` is null and the upload silently fails.
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      ref.read(tripTicketProvider.notifier).setUploadedFile(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(tripTicketProvider.notifier);
    final formData = ref.watch(tripTicketProvider).formData;
    final uploadedFile = formData.uploadedFile;
    final canContinue = formData.uploadStepComplete;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Section header ----------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _Palette.lightBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: _Palette.blue, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authorization Letter',
                          style: TextStyle(
                            color: _Palette.textDark,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload your authorization letter to continue — or, '
                              'if there is no time to prepare one, mark the trip '
                              'as urgent and explain why.',
                          style: TextStyle(
                            color: _Palette.textMuted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------- Upload box ----------
              DottedUploadBox(
                fileName: uploadedFile?.name,
                onTap: _pickFile,
              ),
              if (uploadedFile != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => notifier.setUploadedFile(null),
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: _Palette.urgentRed),
                    label: const Text(
                      'Remove file',
                      style: TextStyle(
                        color: _Palette.urgentRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              // ---------- OR ----------
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: _Palette.textMuted.withOpacity(0.25),
                          thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: _Palette.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                          color: _Palette.textMuted.withOpacity(0.25),
                          thickness: 1)),
                ],
              ),
              const SizedBox(height: 16),

              // ---------- Urgent card ----------
              _UrgentCard(
                isUrgent: formData.manualUrgent,
                onToggle: () => notifier.setManualUrgent(!formData.manualUrgent),
                reasonField: TextField(
                  controller: _urgentReasonController,
                  maxLines: 3,
                  minLines: 2,
                  style: const TextStyle(
                      color: _Palette.textDark, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Why is this urgent? *',
                    hintStyle: const TextStyle(
                        color: _Palette.textMuted, fontSize: 13.5),
                    filled: true,
                    fillColor: _Palette.boxFill,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _Palette.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _Palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: _Palette.blue, width: 1.5),
                    ),
                  ),
                  onChanged: (val) => notifier
                      .updateFormData((d) => d.copyWith(urgentReason: val)),
                ),
              ),

              // ---------- Continue ----------
              const SizedBox(height: 24),
              _ContinueButton(
                enabled: canContinue,
                onTap: () => notifier.nextStep(),
              ),
              if (!canContinue) ...[
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Upload a letter, or tick "urgent" and give a reason, to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _Palette.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgentCard extends StatelessWidget {
  final bool isUrgent;
  final VoidCallback onToggle;
  final Widget reasonField;

  const _UrgentCard({
    required this.isUrgent,
    required this.onToggle,
    required this.reasonField,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? _Palette.urgentRed.withOpacity(0.6)
              : _Palette.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _Palette.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isUrgent ? _Palette.urgentRed : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isUrgent
                            ? _Palette.urgentRed
                            : _Palette.navy.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: isUrgent
                        ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This trip is urgent (no letter available)',
                          style: TextStyle(
                            color: _Palette.textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Urgent requests are shown to the admin first. '
                              'Use this only for urgent cases.',
                          style: TextStyle(
                            color: _Palette.textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUrgent)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: reasonField,
            ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ContinueButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
          BoxShadow(
            color: _Palette.yellow.withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Palette.yellow,
          disabledBackgroundColor: _Palette.yellow.withOpacity(0.35),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Continue to Details',
              style: TextStyle(
                color: _Palette.textDark.withOpacity(enabled ? 1 : 0.5),
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: _Palette.textDark.withOpacity(enabled ? 1 : 0.5),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed-border upload box, built with CustomPaint so no extra package is needed.
class DottedUploadBox extends StatelessWidget {
  final String? fileName;
  final VoidCallback? onTap;

  const DottedUploadBox({this.fileName, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return Material(
      color: _Palette.boxFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 22),
            child: Column(
              children: [
                Icon(
                  hasFile
                      ? Icons.check_circle_rounded
                      : Icons.cloud_upload_outlined,
                  color: hasFile ? const Color(0xFF22A06B) : _Palette.blue,
                  size: 52,
                ),
                const SizedBox(height: 10),
                Text(
                  fileName ?? 'Upload File',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Palette.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                if (!hasFile) ...[
                  const Text(
                    'Drag & drop your file here, or',
                    style: TextStyle(color: _Palette.textMuted, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'click to browse',
                    style: TextStyle(
                      color: _Palette.blue,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else
                  const Text(
                    'Tap to replace file',
                    style: TextStyle(
                      color: _Palette.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: _FileTypeChip(
                        label: 'PDF',
                        icon: Icons.picture_as_pdf_outlined,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _FileTypeChip(
                        label: '.JPG',
                        icon: Icons.image_rounded,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _FileTypeChip(
                        label: '.PNG',
                        icon: Icons.image_rounded,
                        color: Color(0xFF22A06B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FileTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _FileTypeChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _Palette.lightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _Palette.textDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _Palette.blue.withOpacity(0.45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}