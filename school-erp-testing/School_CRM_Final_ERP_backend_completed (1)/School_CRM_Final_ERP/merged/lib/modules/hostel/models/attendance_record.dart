class AttendanceRecord {
  final String id;
  final String studentName;
  final String room;
  final String block;
  String status; // Present, Absent, Late, Leave, Not Marked
  final String checkInTime;
  final String markedBy;

  AttendanceRecord({
    required this.id,
    required this.studentName,
    required this.room,
    required this.block,
    required this.status,
    required this.checkInTime,
    required this.markedBy,
  });
}
