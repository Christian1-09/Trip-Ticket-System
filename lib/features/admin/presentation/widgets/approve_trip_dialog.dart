// features/admin/presentation/widgets/approve_trip_dialog.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/confirm_approve_dialog.dart';
import 'package:signature/signature.dart';
import 'package:jtrips_app/features/admin/data/models/requestor_Information_model.dart';

class ApproveTripDialog extends StatefulWidget {
  final RequestorInformationModel info;
  final VoidCallback onCancel;
  final void Function(Uint8List signatureBytes) onSubmit;

  const ApproveTripDialog({
    required this.info,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  @override
  State<ApproveTripDialog> createState() => _ApproveTripDialogState();
}

class _ApproveTripDialogState extends State<ApproveTripDialog> {
  late final SignatureController _signatureController;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black87,
      exportBackgroundColor: Colors.white,
    );
    _signatureController.addListener(() {
      final isNotEmpty = _signatureController.isNotEmpty;
      if (isNotEmpty != _hasSignature) {
        setState(() => _hasSignature = isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF29B6F6), width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Approve Trip Request',
                    style: TextStyle(color: Color(0xFF1A237E), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              const Text('Requestor Information',
                  style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _infoLine('Trip ID:', info.tripId),
              _infoLine('Requesting Officer:', info.requestingOfficer),
              _infoLine('Department:', info.department),
              _infoLine('', '${info.requestedOn} | ${info.time}'),

              const SizedBox(height: 14),
              const Text('Driver Information',
                  style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _infoLine('Vehicle Assigned:', info.vehicleAssigned),
              _infoLine('Driver Name:', info.driverName),
              _infoLine('Driver Contact #:', '${info.driverName.split(' ').first} ${info.driverNumber}'),

              const SizedBox(height: 14),
              const Text('Requestor e-Signature',
                  style: TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Signature(controller: _signatureController, backgroundColor: Colors.white),
                    if (!_hasSignature)
                      const Center(
                        child: Text('Please sign the from to approve trip request',
                            style: TextStyle(color: Colors.black38, fontSize: 12)),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.refresh, size: 18, color: Colors.black38),
                        onPressed: () => _signatureController.clear(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _hasSignature
                        ? () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (confirmContext) => ConfirmApproveDialog(
                          onCancel: () => Navigator.of(confirmContext).pop(), // closes confirm only, signature dialog stays open
                          onConfirm: () async {
                            Navigator.of(confirmContext).pop(); // close confirm dialog
                            final bytes = await _signatureController.toPngBytes();
                            if (bytes != null) widget.onSubmit(bytes); // this closes the signature dialog too (see step 3)
                          },
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: const Color(0xFF2E7D32).withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 12.5),
          children: [
            if (label.isNotEmpty) TextSpan(text: '$label '),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}