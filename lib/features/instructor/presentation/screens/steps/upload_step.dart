// features/trip_ticket/presentation/screens/steps/upload_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

import '../../providers/trip_ticket_provider.dart';

class UploadStep extends ConsumerWidget {
  const UploadStep({super.key});

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      ref.read(tripTicketProvider.notifier).updateFormData(
            (data) => data.copyWith(uploadedFile: result.files.first),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadedFile = ref.watch(tripTicketProvider).formData.uploadedFile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, color: AppColors.accentYellow, size: 20),
              const SizedBox(width: 8),
              const Text(
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
                        TextSpan(text: ' or supporting document to proceed with the trip request'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _pickFile(ref),
            child: DottedUploadBox(fileName: uploadedFile?.name),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: uploadedFile == null
                  ? null
                  : () => ref.read(tripTicketProvider.notifier).nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                disabledBackgroundColor: AppColors.accentYellow.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Continue to Review',
                      style: TextStyle(color: AppColors.cardDeepBlue, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: AppColors.cardDeepBlue, size: 18),
                ],
              ),
            ),
          ),
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
                  style: TextStyle(color: AppColors.statusBlue, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['PDF', '.JPG', '.PNG', '.DOCX']
                  .map((e) => Chip(
                label: Text(e, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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