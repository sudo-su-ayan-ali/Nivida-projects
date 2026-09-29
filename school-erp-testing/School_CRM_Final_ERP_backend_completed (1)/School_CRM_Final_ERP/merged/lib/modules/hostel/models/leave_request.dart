class LeaveRequest {
  final String id;
  final String studentName;
  final String room;
  final String leaveType; // Home Town, Medical, Personal, Emergency
  final String reason;
  final DateTime from;
  final DateTime to;
  final String emergencyContact;
  final String destination;
  String status; // Pending, Approved, Rejected, Cancelled, Completed

  LeaveRequest({
    required this.id,
    required this.studentName,
    required this.room,
    required this.leaveType,
    required this.reason,
    required this.from,
    required this.to,
    required this.emergencyContact,
    required this.destination,
    required this.status,
  });
}
