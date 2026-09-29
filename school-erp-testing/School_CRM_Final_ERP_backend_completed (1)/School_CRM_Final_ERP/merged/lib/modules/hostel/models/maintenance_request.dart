class MaintenanceRequest {
  final String id;
  final String room;
  final String block;
  final String category;
  final String issue;
  final String priority;
  final String assignedStaff;
  final DateTime createdDate;
  final DateTime expectedDate;
  String status;

  MaintenanceRequest({
    required this.id,
    required this.room,
    required this.block,
    required this.category,
    required this.issue,
    required this.priority,
    required this.assignedStaff,
    required this.createdDate,
    required this.expectedDate,
    required this.status,
  });
}
