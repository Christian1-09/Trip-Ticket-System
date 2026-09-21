// features/admin/presentation/screens/review_trip_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

import '../providers/trip_request_provider.dart';

class ReviewTripScreen extends ConsumerWidget {
  final String tripId;
  final bool busy;
  final VoidCallback onBack;
  final void Function(AdminTripModel) onApprove;
  final void Function(AdminTripModel) onReject;

  const ReviewTripScreen({
    required this.tripId,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
    this.busy = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(pendingTripsProvider);

    return tripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _messageView('Could not load this trip request.'),
      data: (trips) {
        AdminTripModel? trip;
        for (final t in trips) {
          if (t.id == tripId) {
            trip = t;
            break;
          }
        }

        if (trip == null) {
          return _messageView(
              'This request is no longer pending. It may have just been approved or rejected.');
        }

        return _buildDetail(context, trip);
      },
    );
  }

  Widget _buildDetail(BuildContext context, AdminTripModel trip) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(),
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
                  if (trip.isUrgent) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF9A825)),
                      ),
                      child: Text(
                        'URGENT REQUEST — ${trip.urgentReason ?? 'No reason given'}',
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT COLUMN
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle('REQUESTOR INFORMATION'),
                                const SizedBox(height: 10),
                                _infoBox([
                                  _infoLine('Trip ID:', trip.ticketNumber),
                                  _infoLine('Requesting Officer:', trip.requester.fullName),
                                  _infoLine('Department:', trip.departmentName),
                                  _infoLine('Contact #:', trip.requester.contact),
                                  _infoLine('Requested on:', trip.requestedOnLabel),
                                ]),
                                const SizedBox(height: 20),
                                _sectionTitle('TRIP DETAILS'),
                                const SizedBox(height: 10),
                                _infoBox([
                                  _infoLine('Date:', trip.dateLabel),
                                  _infoLine('Departure Time:', trip.departureLabel),
                                  _infoLine(trip.endTimeTitle, trip.endTimeLabel),
                                  _infoLine('Service Mode:', trip.serviceModeLabel),
                                  _infoLine('Route:', trip.routeLabel),
                                  _infoLine('Purpose:', trip.purpose),
                                  _infoLine('Passengers:', trip.passengersLabel),
                                ]),
                                const SizedBox(height: 20),
                                _sectionTitle('DRIVER & VEHICLE'),
                                const SizedBox(height: 10),
                                _infoBox([
                                  _infoLine(
                                      'Driver Name:',
                                      trip.driver.isHeadDriver
                                          ? '${trip.driver.fullName} (Head Driver)'
                                          : trip.driver.fullName),
                                  _infoLine('Driver Contact #:', trip.driver.contact),
                                  _infoLine('Vehicle Assigned:', trip.vehicleModel),
                                  _infoLine('Plate #:', trip.vehiclePlate),
                                ]),
                                if (trip.stops.any((s) => s.isCustom)) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Note: one or more stops were typed by the requester and '
                                        'are not on the official location list, so their travel '
                                        'time is only an estimate.',
                                    style: TextStyle(
                                        color: Color(0xFFB26A00), fontSize: 11.5),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // RIGHT COLUMN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('AUTHORIZATION LETTER'),
                              const SizedBox(height: 10),
                              Expanded(child: _letterPanel(trip)),
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
                        onPressed: busy ? null : () => onReject(trip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reject',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: busy ? null : () => onApprove(trip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        ],
      ),
    );
  }

  /// Images are shown inline. Other file types (PDF, DOCX) cannot be
  /// previewed here, so the link is shown for the admin to open or copy.
  Widget _letterPanel(AdminTripModel trip) {
    if (!trip.hasLetter) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No authorization letter was uploaded.\n'
                  'This trip was submitted as urgent instead.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ),
      );
    }

    final url = ApiConfig.mediaUrl(trip.authorizationLetterUrl)!;
    final lower = url.toLowerCase();
    final isImage = lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: isImage
                ? InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('Could not load the image.',
                      style: TextStyle(color: Colors.black54, fontSize: 13)),
                ),
              ),
            )
                : const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 42, color: Colors.black45),
                  SizedBox(height: 8),
                  Text('Document uploaded',
                      style: TextStyle(color: Colors.black87, fontSize: 14)),
                  Text('Open the link below to view it',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            url,
            style: const TextStyle(color: Color(0xFF1A237E), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: onBack,
      child: const Row(
        children: [
          Icon(Icons.arrow_back, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Back to Trips',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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

  Widget _messageView(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(),
          const SizedBox(height: 40),
          Center(
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}