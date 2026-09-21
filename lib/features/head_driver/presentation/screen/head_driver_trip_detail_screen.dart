// features/head_driver/presentation/screens/head_driver_trip_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

import '../../data/head_driver_models.dart';
import '../head_driver_actions.dart';

/// Full details before the Head Driver commits a vehicle and a driver.
/// [isDeclined] switches the bottom buttons from Approve/Reject to
/// "Assign Driver" for trips whose driver declined.
class HeadDriverTripDetailScreen extends ConsumerWidget {
  final HeadDriverTrip item;
  final bool isDeclined;

  const HeadDriverTripDetailScreen({
    super.key,
    required this.item,
    required this.isDeclined,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = item.trip;

    Future<void> runAndClose(Future<bool> Function() action) async {
      final ok = await action();
      if (ok && context.mounted) Navigator.of(context).pop();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(trip.ticketNumber,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (trip.isUrgent)
                    _banner(
                      color: AppColors.accentYellow,
                      text: 'URGENT — ${trip.urgentReason ?? 'No reason given'}',
                    ),
                  if (isDeclined && item.declines.isNotEmpty) ...[
                    _card('DECLINED BY', [
                      for (final d in item.declines)
                        _line(d.driverName, '${d.reason}  ·  ${d.whenLabel}'),
                    ]),
                    const SizedBox(height: 12),
                  ],
                  _card('REQUESTER', [
                    _line('Name', trip.requester.fullName),
                    _line('Department', trip.departmentName),
                    _line('Contact', trip.requester.contact),
                    _line('Requested on', trip.requestedOnLabel),
                  ]),
                  const SizedBox(height: 12),
                  _card('SCHEDULE', [
                    _line('Date', trip.dateLabel),
                    _line('Departure', trip.departureLabel),
                    _line(trip.endTimeTitle.replaceAll(':', ''), trip.endTimeLabel),
                    _line('Service', trip.serviceModeLabel),
                  ]),
                  const SizedBox(height: 12),
                  _card('ROUTE', [
                    for (final stop in trip.stops)
                      _line(
                        stop.type == 'ORIGIN'
                            ? 'From'
                            : stop.type == 'DESTINATION'
                            ? 'To'
                            : 'Stop',
                        stop.isCustom && stop.type != 'ORIGIN'
                            ? '${stop.address} (typed, ~${stop.travelMinutes} min)'
                            : stop.address,
                      ),
                  ]),
                  const SizedBox(height: 12),
                  _card('VEHICLE & DRIVER', [
                    _line('Vehicle', '${trip.vehicleModel} (${trip.vehiclePlate})'),
                    _line('Driver', isDeclined ? 'Needs a replacement' : trip.driver.fullName),
                    if (!isDeclined) _line('Driver contact', trip.driver.contact),
                  ]),
                  const SizedBox(height: 12),
                  _card('PURPOSE & PASSENGERS', [
                    _line('Purpose', trip.purpose),
                    _line('Passengers', trip.passengersLabel),
                  ]),
                  const SizedBox(height: 12),
                  _letterCard(trip.authorizationLetterUrl),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.cardDeepBlue,
                border: Border(top: BorderSide(color: AppColors.statusBlue.withOpacity(0.3))),
              ),
              child: isDeclined
                  ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      runAndClose(() => HeadDriverActions.assignDriver(context, ref, item)),
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                  label: const Text('Assign Driver',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: _buttonStyle(AppColors.statusBlue),
                ),
              )
                  : Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          runAndClose(() => HeadDriverActions.reject(context, ref, item)),
                      style: _buttonStyle(Colors.redAccent),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          runAndClose(() => HeadDriverActions.approve(context, ref, item)),
                      style: _buttonStyle(const Color(0xFF2E7D32)),
                      child: const Text('Approve',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) => ElevatedButton.styleFrom(
    backgroundColor: color,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _banner({required Color color, required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDeepBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.statusBlue.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _letterCard(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) {
      return _card('AUTHORIZATION LETTER', [
        const Text('No letter — submitted as urgent.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ]);
    }

    final url = ApiConfig.mediaUrl(relativeUrl)!;
    final lower = url.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');

    return _card('AUTHORIZATION LETTER', [
      if (isImage)
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text('Could not load the image.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        )
      else
        const Text('A document was uploaded (PDF/DOCX).',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      const SizedBox(height: 6),
      SelectableText(url,
          style: const TextStyle(color: AppColors.statusBlue, fontSize: 11)),
    ]);
  }
}