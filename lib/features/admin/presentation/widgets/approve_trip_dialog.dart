// features/admin/presentation/widgets/approve_trip_dialog.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/confirm_approve_dialog.dart';

class ApproveTripDialog extends StatelessWidget {
  final AdminTripModel trip;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ApproveTripDialog({
    required this.trip,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              if (trip.isUrgent) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF9A825)),
                  ),
                  child: Text(
                    'URGENT: ${trip.urgentReason ?? 'No reason given'}',
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const Text('Requestor Information',
                  style: TextStyle(
                      color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _infoLine('Trip ID:', trip.ticketNumber),
              _infoLine('Requesting Officer:', trip.requester.fullName),
              _infoLine('Department:', trip.departmentName),
              _infoLine('Schedule:', '${trip.dateLabel} | ${trip.departureLabel}'),
              _infoLine(trip.endTimeTitle, trip.endTimeLabel),
              _infoLine('Service:', trip.serviceModeLabel),

              const SizedBox(height: 14),
              const Text('Driver Information',
                  style: TextStyle(
                      color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _infoLine('Vehicle Assigned:', '${trip.vehicleModel} (${trip.vehiclePlate})'),
              _infoLine('Driver Name:',
                  trip.driver.isHeadDriver
                      ? '${trip.driver.fullName} (Head Driver)'
                      : trip.driver.fullName),
              _infoLine('Driver Contact #:', trip.driver.contact),

              if (trip.driver.isHeadDriver) ...[
                const SizedBox(height: 10),
                const Text(
                  'The head driver is the assigned driver, so his approval step is '
                      'skipped and this trip goes straight to him to accept.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (confirmContext) => ConfirmApproveDialog(
                          onCancel: () => Navigator.of(confirmContext).pop(),
                          onConfirm: () {
                            Navigator.of(confirmContext).pop();
                            onSubmit(); // caller closes this dialog and calls the API
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Approve',
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