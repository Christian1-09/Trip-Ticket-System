// features/admin/data/models/trip_ticket_log_model.dart
class TripTicketLogModel {
  final String dateOfTravel;
  final String driver;
  final String vehicle;
  final String purpose;
  final String destination;
  final String passengers;
  final String timestamp;

  const TripTicketLogModel({
    required this.dateOfTravel,
    required this.driver,
    required this.vehicle,
    required this.purpose,
    required this.destination,
    required this.passengers,
    required this.timestamp,
  });
}