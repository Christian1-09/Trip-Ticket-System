// features/instructor/presentation/screens/steps/upload_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

import '../../providers/trip_ticket_provider.dart';

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
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx'],
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.upload_file, color: AppColors.accentYellow, size: 20),
              SizedBox(width: 8),
              Text(
                'Authorization Letter',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardDeepBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.statusBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                      children: [
                        TextSpan(text: 'Upload your '),
                        TextSpan(
                          text: 'authorization letter',
                          style: TextStyle(color: AppColors.statusBlue, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                            text: ' to continue — or, if there is no time to prepare one, '
                                'mark the trip as urgent and explain why.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickFile,
            child: DottedUploadBox(fileName: uploadedFile?.name),
          ),
          if (uploadedFile != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => notifier.setUploadedFile(null),
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                label: const Text('Remove file',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            ),
          ],

          // ---------- OR: urgent without a letter ----------
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.4))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.4))),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardDeepBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: formData.manualUrgent
                    ? Colors.redAccent.withOpacity(0.6)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: formData.manualUrgent,
                      onChanged: (val) => notifier.setManualUrgent(val ?? false),
                      activeColor: Colors.redAccent,
                      side: BorderSide(color: AppColors.textSecondary.withOpacity(0.6)),
                    ),
                    const Expanded(
                      child: Text(
                        'This trip is urgent (no letter available)',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    'Urgent requests are shown to the admin first. Use this only for '
                        'genuine last-minute trips.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
                if (formData.manualUrgent) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urgentReasonController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Why is this urgent? *',
                      hintStyle:
                      TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13),
                      filled: true,
                      fillColor: AppColors.cardDeepBlue,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.statusBlue.withOpacity(0.4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.statusBlue.withOpacity(0.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accentYellow),
                      ),
                    ),
                    onChanged: (val) => ref
                        .read(tripTicketProvider.notifier)
                        .updateFormData((d) => d.copyWith(urgentReason: val)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canContinue ? () => notifier.nextStep() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                disabledBackgroundColor: AppColors.accentYellow.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Continue to Details',
                      style: TextStyle(color: AppColors.cardDeepBlue, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: AppColors.cardDeepBlue, size: 18),
                ],
              ),
            ),
          ),
          if (!canContinue) ...[
            const SizedBox(height: 8),
            const Text(
              'Upload a letter, or tick "urgent" and give a reason, to continue.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dashed-border box, built with CustomPaint so no extra package is needed.
class DottedUploadBox extends StatelessWidget {
  final String? fileName;
  const DottedUploadBox({this.fileName, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: AppColors.statusBlue, size: 40),
            const SizedBox(height: 12),
            Text(
              fileName ?? 'Upload File',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            if (fileName == null) ...[
              const Text('Drag & drop your file here, or',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Text('click to browse',
                  style: TextStyle(
                      color: AppColors.statusBlue, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['PDF', '.JPG', '.PNG', '.DOCX']
                  .map((e) => Chip(
                label: Text(e,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
                backgroundColor: AppColors.cardDeepBlue,
                side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.statusBlue.withOpacity(0.6)
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