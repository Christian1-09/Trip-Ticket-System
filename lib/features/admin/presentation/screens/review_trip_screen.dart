// features/admin/presentation/screens/review_trip_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/admin/data/models/requestor_Information_model.dart';
import 'package:jtrips_app/features/admin/presentation/providers/requestor_information_provider.dart';
import 'package:jtrips_app/features/admin/presentation/widgets/approve_trip_dialog.dart';

class ReviewTripScreen extends ConsumerWidget {
  final String tripId;
  final VoidCallback onBack;

  const ReviewTripScreen({
    required this.tripId,
    required this.onBack,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestorList = ref.watch(requestorInformationProvider);
    final RequestorInformationModel? info = requestorList
        .where((r) => r.tripId == tripId)
        .cast<RequestorInformationModel?>()
        .firstWhere((_) => true, orElse: () => null);

    if (info == null) {
      return _notFoundView();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Back to Trips',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT COLUMN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('REQUESTOR INFORMATION'),
                              const SizedBox(height: 10),
                              _infoBox([
                                _infoLine('Trip ID:', info.tripId),
                                _infoLine('Requesting Officer:', info.requestingOfficer),
                                _infoLine('Department:', info.department),
                              ]),
                              const SizedBox(height: 20),
                              _sectionTitle('TRIP DETAILS'),
                              const SizedBox(height: 10),
                              _infoBox([
                                _infoLine('Requested on:', info.requestedOn),
                                _infoLine('Destination:', info.destination),
                                _infoLine('Department Time:', info.time),
                                _infoLine('Vehicle Assigned:', info.vehicleAssigned),
                                _infoLine('Plate#:', info.plate),
                                _infoLine('Return Time:', info.returnTime),
                                _infoLine('Purpose:', info.purpose),
                                _infoLine('Driver Name:', info.driverName),
                                _infoLine('Driver Contact #:', 'Steve ${info.driverNumber}'),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // RIGHT COLUMN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('REQUEST LETTER'),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Supporting Documents',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                        const Text('[photo]',
                                            style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          children: ['PDF', 'JPG', 'PNG', 'DOCX']
                                              .map((e) => Chip(
                                            label: Text(e, style: const TextStyle(fontSize: 10)),
                                            backgroundColor: Colors.grey.shade200,
                                            side: BorderSide(color: Colors.grey.shade300),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                        onPressed: () {}, // placeholder — matches your instruction from earlier
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(context: context,
                              barrierDismissible: false,
                          builder: (dialogContext) => ApproveTripDialog(info: info, onCancel: () => Navigator.of(dialogContext).pop(),
                            onSubmit: (signatureBytes) {
                            Navigator.of(dialogContext).pop();
                            onBack();
                          }
                          ),
                          );
                        }, // placeholder
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5));
  }

  Widget _infoBox(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(text: '$label '),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _notFoundView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Back to Trips', style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text('No request details found for this trip.',
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}