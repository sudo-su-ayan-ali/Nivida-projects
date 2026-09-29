class Complaint {
  final String id;
  final String studentName;
  final String room;
  final String category;
  final String description;
  final String priority;
  final DateTime date;
  final String assignedTo;
  String status;

  Complaint({
    required this.id,
    required this.studentName,
    required this.room,
    required this.category,
    required this.description,
    required this.priority,
    required this.date,
    required this.assignedTo,
    required this.status,
  });
}
