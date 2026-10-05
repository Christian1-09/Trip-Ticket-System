// features/instructor/presentation/widgets/rate_driver_dialog.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// Star rating plus an optional written message, shown once the trip is
/// completed. Returns (score, comment) or null when cancelled.
class RateDriverDialog extends StatefulWidget {
  final String driverName;
  final String ticketNumber;

  const RateDriverDialog({
    super.key,
    required this.driverName,
    required this.ticketNumber,
  });

  @override
  State<RateDriverDialog> createState() => _RateDriverDialogState();
}

class _RateDriverDialogState extends State<RateDriverDialog> {
  int _score = 0;
  final _controller = TextEditingController();
  String? _error;

  static const _labels = {
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very good',
    5: 'Excellent',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDeepBlue,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rate your driver',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${widget.driverName} · ${widget.ticketNumber}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() {
                  _score = value;
                  _error = null;
                }),
                icon: Icon(
                  value <= _score ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.accentYellow,
                  size: 34,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                constraints: const BoxConstraints(),
              );
            }),
          ),
          Center(
            child: Text(
              _score == 0 ? 'Tap a star' : _labels[_score]!,
              style: TextStyle(
                color: _score == 0 ? AppColors.textSecondary : AppColors.accentYellow,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(_error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 300,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Leave a message for the driver (optional)',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              counterStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const Text(
            'Your rating is shown to the driver and counts towards their average.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_score == 0) {
              setState(() => _error = 'Please choose a star rating.');
              return;
            }
            Navigator.pop(context, (score: _score, comment: _controller.text));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Submit',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}