// core/printing/trip_ticket_pdf.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'trip_ticket_data.dart';

/// Builds the JRMSU trip ticket, following the printed form section by
/// section. Fields the system does not record are printed as blank lines
/// for the driver to fill in by hand.
Future<List<int>> buildTripTicketPdf(TripTicketData data) async {
  final doc = pw.Document();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 28, 36, 28),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(data),
          pw.SizedBox(height: 10),
          _sectionA(data),
          pw.SizedBox(height: 8),
          _sectionB(data),
          pw.Spacer(),
          _signatures(data),
        ],
      ),
    ),
  );

  return doc.save();
}

// ─────────────────────────────────────────────────────────────────────────────

pw.Widget _header(TripTicketData data) {
  return pw.Column(
    children: [
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('ANNEX A', style: const pw.TextStyle(fontSize: 8)),
      ),
      pw.Text('Republic of the Philippines', style: const pw.TextStyle(fontSize: 9)),
      pw.Text('JOSE RIZAL MEMORIAL STATE UNIVERSITY',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      pw.Text('The Premier University in Zamboanga del Norte',
          style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
      pw.Text('Katipunan Campus', style: const pw.TextStyle(fontSize: 9)),
      pw.SizedBox(height: 10),
      pw.Text('OFFICE OF THE GENERAL SERVICES/OPERATIONS',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      pw.Text('TRIP TICKET',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.Text('No.: ${data.ticketNumber}', style: const pw.TextStyle(fontSize: 9)),
      pw.SizedBox(height: 6),
      pw.Align(
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(data.dateLabel, style: const pw.TextStyle(fontSize: 9)),
      ),
    ],
  );
}

/// Filled from the approved request.
pw.Widget _sectionA(TripTicketData data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionTitle('A. To be filled by the GSO Personnel:'),
      _filledRow('1.', "Driver's Name", data.driverName.toUpperCase()),
      _filledRow('2.', "Vehicle's Plate Number",
          '${data.vehiclePlate} - ${data.vehicleModel}'.toUpperCase()),
      _filledRow('3.', "Passenger's Name", data.passengersLabel.toUpperCase()),
      _filledRow('4.', 'Place (s) to be visited', data.placesLabel.toUpperCase()),
      _filledRow('5.', 'Purpose', data.purpose),
      pw.SizedBox(height: 14),
      pw.Row(
        children: [
          pw.Text('Approved: ', style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(
            child: pw.Column(
              children: [
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.7)),
                  ),
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    (data.approverName ?? '').toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Text(data.approverTitle,
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

/// Filled from the driver's departure and return logs. Items 2 and 3 are
/// left blank: the system records leaving the garage and arriving back,
/// not the times at the destination itself.
pw.Widget _sectionB(TripTicketData data) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _sectionTitle('B. To be filled by the Driver:'),
      _valueRow('1.', 'Time of departure from office/garage',
          data.time(data.departureFromGarage), 'am/pm'),
      _valueRow('2.', 'Time of Arrival (per No. 4A)',
          data.time(data.arrivedAtDestination), 'am/pm'),
      _valueRow('3.', 'Time of Departure (per No. 4A)',
          data.time(data.departedFromDestination), 'am/pm'),
      _valueRow('4.', 'Time of Arrival Back to the Office/Garage',
          data.time(data.arrivalBackAtGarage), 'am/pm'),
      _valueRow('5.', 'Approximate Distance Travelled (to and from)',
          data.km(data.distanceTraveledKm), 'km/mi'),
      _labelOnly('6.', 'Gasoline Issued, Purchased and Consumed:'),
      _valueRow('', 'a. Balance in Tank', data.liters(data.fuelBalanceInTank), 'liter',
          indent: 18),
      _valueRow('', 'b. Issued by Office from Stock',
          data.liters(data.fuelIssuedByOffice), 'liter',
          indent: 18),
      _valueRow('', 'c. Purchased during Trip',
          data.liters(data.fuelPurchasedDuring), 'liter',
          indent: 18),
      _valueRow('', 'TOTAL', data.liters(data.totalAvailableLiters), 'liter',
          indent: 18, bold: true),
      _valueRow('', 'd. Deduct Used During Trip (to and from)',
          data.liters(data.gasolineUsedLiters), 'liter',
          indent: 18),
      _valueRow('', 'e. Balance in Tank at the End of Trip',
          data.liters(data.balanceAtEndLiters), 'liter',
          indent: 18),
      _valueRow('7.', 'Gear Oil Used', data.liters(data.gearOilUsedLiters), 'liter'),
      _valueRow('8.', 'Lub. Oil Used', data.liters(data.lubricatingOilUsedLiters), 'liter'),
      _valueRow('9.', 'Grease Issued', data.liters(data.greaseIssuedLiters), 'liter'),
      _labelOnly('10.', 'Speedometer Readings (if any):'),
      _valueRow('', 'a. At Beginning of the Trip', data.km(data.odometerStart), 'km/mi',
          indent: 18),
      _valueRow('', 'b. At End of the Trip', data.km(data.odometerEnd), 'km/mi', indent: 18),
      _valueRow('', 'c. Distance Travelled (per 5A)', data.km(data.distanceTraveledKm),
          'km/mi',
          indent: 18),
      _valueRow('11.', 'Remarks', data.remarks ?? '', ''),
    ],
  );
}

pw.Widget _signatures(TripTicketData data) {
  pw.Widget block(String name, String caption) => pw.Expanded(
    child: pw.Column(
      children: [
        pw.Text(
          'I hereby certify to the correctness of the above statement of record of travel.',
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 7),
        ),
        pw.SizedBox(height: 26),
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 14),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(width: 0.7)),
          ),
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Column(
            children: [
              pw.Text(name.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text(caption,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7)),
            ],
          ),
        ),
      ],
    ),
  );

  return pw.Column(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          block(data.driverName, "Driver's Signature Over Printed Name"),
          block(data.requesterName, "Passenger's Signature Over Printed Name"),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        data.printedAt == null
            ? 'Generated by JTRIPS'
            : 'Generated by JTRIPS · first printed ${data.printedLabel}',
        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Small building blocks
// ─────────────────────────────────────────────────────────────────────────────

pw.Widget _sectionTitle(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
  );
}

/// Section A style: label on the left, the value underlined on the right.
pw.Widget _filledRow(String number, String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(width: 16, child: pw.Text(number, style: const pw.TextStyle(fontSize: 9))),
        pw.SizedBox(
          width: 130,
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Expanded(
          child: pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
            ),
            padding: const pw.EdgeInsets.only(left: 4, bottom: 1.5),
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
      ],
    ),
  );
}

/// Section B style: label, a filled-in blank, then the unit.
pw.Widget _valueRow(
    String number,
    String label,
    String value,
    String unit, {
      double indent = 0,
      bool bold = false,
    }) {
  final style = pw.TextStyle(
    fontSize: 9,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(width: 20, child: pw.Text(number, style: style)),
        pw.SizedBox(width: indent),
        pw.Expanded(child: pw.Text(label, style: style)),
        pw.Container(
          width: 110,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(bottom: 1.5),
          child: pw.Text(value, textAlign: pw.TextAlign.center, style: style),
        ),
        pw.SizedBox(
          width: 34,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 4),
            child: pw.Text(unit, style: const pw.TextStyle(fontSize: 8)),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _labelOnly(String number, String label) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 3, bottom: 1),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 20, child: pw.Text(number, style: const pw.TextStyle(fontSize: 9))),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
}