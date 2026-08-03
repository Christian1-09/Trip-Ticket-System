class RequestorInformationModel {
   final String tripId;
   final String requestingOfficer;
   final String department;
   final String requestedOn;
   final String destination;
   final String time;
   final String vehicleAssigned;
   final String plate;
   final String returnTime;
   final String purpose;
   final String driverName;
   final String driverNumber;

   const RequestorInformationModel({
     required this.tripId,
     required this.requestingOfficer,
     required this.department,
     required this.requestedOn,
     required this.destination,
     required this.time,
     required this.vehicleAssigned,
     required this.plate,
     required this.returnTime,
     required this.purpose,
     required this.driverName,
     required this.driverNumber

  });
}