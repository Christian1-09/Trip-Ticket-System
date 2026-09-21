// features/admin/presentation/widgets/reject_trip_dialog.dart
import 'package:flutter/material.dart';

/// The reason is required: it is sent to the requester in the rejection
/// notification, so an empty one would leave them guessing.
class RejectTripDialog extends StatefulWidget {
  final String ticketNumber;
  final VoidCallback onCancel;
  final void Function(String reason) onSubmit;

  const RejectTripDialog({
    required this.ticketNumber,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  @override
  State<RejectTripDialog> createState() => _RejectTripDialogState();
}

class _RejectTripDialogState extends State<RejectTripDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Please give a reason for the rejection.');
      return;
    }
    widget.onSubmit(reason);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE53935), width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Reject ${widget.ticketNumber}',
                    style: const TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Text(
                'The requester will see this reason in their notification.',
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                maxLines: 3,
                autofocus: true,
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Reason for rejection *',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                  errorText: _error,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reject Trip',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}