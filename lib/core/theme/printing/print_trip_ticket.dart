// core/printing/print_trip_ticket.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_client.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:jtrips_app/core/theme/storage/token_storage.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;
import 'package:printing/printing.dart';

import 'trip_ticket_data.dart';
import 'trip_ticket_pdf.dart';

/// Calls POST /api/trips/:id/print (which records the first print), builds
/// the PDF and opens the system print / share dialog. Works on Android,
/// iOS and the web, so the requester, driver and admin all use this.
///
/// Returns true when the sheet was opened.
Future<bool> printTripTicket(
    BuildContext context,
    WidgetRef ref,
    String tripId,
    ) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final ApiClient apiClient = ref.read(apiClientProvider);
    final TokenStorage tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getAccessToken();

    final response = await apiClient.post('/trips/$tripId/print', accessToken: token);
    final data = TripTicketData.fromJson(
      response['trip'] as Map<String, dynamic>,
      approver: response['approver'] as Map<String, dynamic>?,
    );
    final bytes = await buildTripTicketPdf(data);

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    await Printing.layoutPdf(
      onLayout: (_) async => Uint8List.fromList(bytes),
      name: 'Trip Ticket ${data.ticketNumber}',
    );
    return true;
  } on ApiException catch (e) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    _error(context, e.message);
  } catch (_) {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    _error(context, 'Could not prepare the trip ticket. Please try again.');
  }
  return false;
}

void _error(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 6),
    ),
  );
}