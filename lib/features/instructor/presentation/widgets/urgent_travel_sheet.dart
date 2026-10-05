import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// Asks the one thing the backend cannot do without: why the trip is urgent.
///
/// Returns the reason, or null if the requester backed out.
/// Keep this sheet tiny — it is the whole cost of skipping the Upload step.
Future<String?> showUrgentTravelSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _UrgentTravelSheet(),
  );
}

class _UrgentTravelSheet extends StatefulWidget {
  const _UrgentTravelSheet();

  @override
  State<_UrgentTravelSheet> createState() => _UrgentTravelSheetState();
}

class _UrgentTravelSheetState extends State<_UrgentTravelSheet> {
  final _controller = TextEditingController();
  bool _touched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reason = _controller.text.trim();
    final isValid = reason.length >= 10;

    return Padding(
      // Lifts the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFF0B1A4D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt,
                      color: AppColors.accentYellow, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Urgent travel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Urgent requests skip the authorization letter, so the '
                  'approver needs to know why. Be specific — this appears on '
                  'the trip ticket.',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              maxLength: 300,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (_) => setState(() => _touched = true),
              decoration: InputDecoration(
                hintText:
                'e.g. Student needs transport to Dipolog hospital for an '
                    'emergency medical referral',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                counterStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                errorText: _touched && !isValid
                    ? 'Please give at least a short sentence (10+ characters).'
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                isValid ? () => Navigator.of(context).pop(reason) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  disabledBackgroundColor: Colors.white12,
                  foregroundColor: const Color(0xFF071166),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to trip details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}