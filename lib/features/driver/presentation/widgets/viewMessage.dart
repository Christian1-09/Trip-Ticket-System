import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

/// A single "label : value" line inside the Trip Details bullet list.
class TripDetailItem {
  final String label;
  final String value;

  const TripDetailItem({required this.label, required this.value});
}

class ViewMessage extends StatelessWidget {
  const ViewMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        backgroundColor: AppColors.background,
        title: Text(
          "Admin",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              TicketDetailCard(
                title: 'Trip Ticket Approved',
                greeting: 'Hello Driver,',
                intro:
                'God news! The trip ticket request has been approved by the admin.',
                details: const [
                  TripDetailItem(label: 'Ticket ID', value: 'TT-2026-00123'),
                  TripDetailItem(label: 'Requestor Name', value: 'Ms.Flawless'),
                  TripDetailItem(label: 'Vehicle', value: 'Innova'),
                  TripDetailItem(label: 'Destination', value: 'Dapitan'),
                  TripDetailItem(
                    label: 'Departure Date & Time',
                    value: 'March 12,2026 at 3:30PM',
                  ),
                  TripDetailItem(label: 'Purpose', value: 'Seminar'),
                ],
                notes: const [
                  'Please make sure to prepare and check the vihicle to used and be ready before the scheduled departure time.',
                  'If you have any questions or need further assistance,fell free to contact the admin .',
                ],
                closingLine: 'Safe travels 🛡️',
                signature: '— Admin',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Reusable card for message-detail screens (trip approvals, cancellations,
/// reminders, etc.) — pass whatever title/body/details fit the message.
class TicketDetailCard extends StatelessWidget {
  final String title;
  final String greeting;
  final String intro;
  final List<TripDetailItem> details;
  final List<String> notes;
  final String? closingLine;
  final String? signature;

  const TicketDetailCard({
    super.key,
    required this.title,
    required this.greeting,
    required this.intro,
    this.details = const [],
    this.notes = const [],
    this.closingLine,
    this.signature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDeepBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusBlue.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.statusBlue.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            greeting,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            intro,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),

          if (details.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Trip Details:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...details.map((item) => _DetailBullet(item: item)),
          ],

          for (final note in notes) ...[
            const SizedBox(height: 14),
            Text(
              note,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],

          if (closingLine != null) ...[
            const SizedBox(height: 14),
            Text(
              closingLine!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (signature != null) ...[
            const SizedBox(height: 18),
            Text(
              signature!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailBullet extends StatelessWidget {
  final TripDetailItem item;

  const _DetailBullet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '${item.label} : ',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: item.value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}