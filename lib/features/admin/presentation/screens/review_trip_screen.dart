// features/admin/presentation/screens/review_trip_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/features/admin/data/models/admin_trip_model.dart';

import '../../../../core/theme/admin_colors.dart';
import '../providers/trip_request_provider.dart';

/// Light admin palette (matches the Drivers screen).
class _AdminColors {
  static const pageBg = Color(0xFFF4F6FB);
  static const card = Colors.white;
  static const navy = Color(0xFF1A237E);
  static const accent = Color(0xFF9C27F0);
  static const textPrimary = Color(0xFF1F2937);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const panelBg = Color(0xFFF7F8FC);
  static const greyButton = Color(0xFFEEF0F6);
  static const danger = Color(0xFFDC2626);
  static const warnBg = Color(0xFFFFF4DB);
  static const warnBorder = Color(0xFFF5D38A);
  static const warnText = Color(0xFFB7791F);
}

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

    return Container(
      color: _AdminColors.pageBg,
      child: tripsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _AdminColors.navy),
        ),
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
      ),
    );
  }

  Widget _buildDetail(BuildContext context, AdminTripModel trip) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: _AdminColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _backButton(),
            const SizedBox(height: 12),

            // ── Header ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Review Trip',
                  style: TextStyle(
                    color: _AdminColors.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                _pill('Pending', _AdminColors.warnBg, _AdminColors.warnText),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${trip.ticketNumber} · requested on ${trip.requestedOnLabel}',
              style: const TextStyle(color: _AdminColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 20),

            if (trip.isUrgent) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _AdminColors.warnBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _AdminColors.warnBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.priority_high_rounded,
                        color: _AdminColors.warnText, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'URGENT REQUEST — ${trip.urgentReason ?? 'No reason given'}',
                        style: const TextStyle(
                            color: _AdminColors.warnText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Body ────────────────────────────────────────────────
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
                          _infoSection('Requestor Information', [
                            _infoLine('Trip ID', trip.ticketNumber),
                            _infoLine('Requesting Officer', trip.requester.fullName),
                            _infoLine('Department', trip.departmentName),
                            _infoLine('Contact #', trip.requester.contact),
                            _infoLine('Requested on', trip.requestedOnLabel, isLast: true),
                          ]),
                          const SizedBox(height: 16),
                          _infoSection('Trip Details', [
                            _infoLine('Date', trip.dateLabel),
                            _infoLine('Departure Time', trip.departureLabel),
                            _infoLine(
                                trip.endTimeTitle.replaceAll(':', ''), trip.endTimeLabel),
                            _infoLine('Service Mode', trip.serviceModeLabel),
                            _infoLine('Route', trip.routeLabel),
                            _infoLine('Purpose', trip.purpose),
                            _infoLine('Passengers', trip.passengersLabel, isLast: true),
                          ]),
                          const SizedBox(height: 16),
                          _infoSection('Driver & Vehicle', [
                            _infoLine(
                              'Driver Name',
                              trip.driver.fullName,
                              trailing: trip.driver.isHeadDriver
                                  ? const Text(
                                'Head Driver',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                                  : null,
                            ),
                            _infoLine('Driver Contact #', trip.driver.contact),
                            _infoLine('Vehicle Assigned', trip.vehicleModel),
                            _infoLine('Plate #', trip.vehiclePlate, isLast: true),
                          ]),
                          if (trip.stops.any((s) => s.isCustom)) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Note: one or more stops were typed by the requester and '
                                  'are not on the official location list, so their travel '
                                  'time is only an estimate.',
                              style: TextStyle(color: _AdminColors.warnText, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // RIGHT COLUMN
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _AdminColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _panelHeader('Authorization Letter'),
                          Expanded(child: _letterPanel(trip)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Actions ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  label: 'Reject',
                  background: AdminColors.orange,
                  foreground: AdminColors.surface,
                  onPressed: busy ? null : () => onReject(trip),
                ),
                const SizedBox(width: 10),
                _actionButton(
                  label: 'Approve',
                  background: AdminColors.green,
                  foreground: Colors.white,
                  onPressed: busy ? null : () => onApprove(trip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Images are shown inline. Other file types (PDF, DOCX) cannot be
  /// previewed here, so the link is shown for the admin to open or copy.
  Widget _letterPanel(AdminTripModel trip) {
    if (!trip.hasLetter) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail_outline, size: 36, color: _AdminColors.textMuted),
              SizedBox(height: 8),
              Text(
                'No authorization letter was uploaded.\n'
                    'This trip was submitted as urgent instead.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _AdminColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final url = ApiConfig.mediaUrl(trip.authorizationLetterUrl)!;
    final lower = url.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _AdminColors.panelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: isImage
                  ? InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('Could not load the image.',
                        style: TextStyle(color: _AdminColors.textMuted, fontSize: 13)),
                  ),
                ),
              )
                  : const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 42, color: _AdminColors.navy),
                    SizedBox(height: 8),
                    Text('Document uploaded',
                        style: TextStyle(
                            color: _AdminColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text('Open the link below to view it',
                        style: TextStyle(color: _AdminColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            url,
            style: const TextStyle(color: _AdminColors.navy, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: onBack,
      borderRadius: BorderRadius.circular(6),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: _AdminColors.navy, size: 18),
            SizedBox(width: 6),
            Text('Back to Trips',
                style: TextStyle(
                    color: _AdminColors.navy, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _panelHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: _AdminColors.panelBg,
        border: Border(bottom: BorderSide(color: _AdminColors.border)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// A bordered panel with a grey header row, like the Drivers table.
  Widget _infoSection(String title, List<Widget> lines) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _AdminColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader(title),
          ...lines,
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value, {Widget? trailing, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: _AdminColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(color: _AdminColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: _AdminColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background.withAlpha(120),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label,
          style: TextStyle(
              color: onPressed == null ? foreground.withAlpha(150) : foreground,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _messageView(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _AdminColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _backButton(),
            const SizedBox(height: 40),
            Center(
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _AdminColors.textMuted, fontSize: 14)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}