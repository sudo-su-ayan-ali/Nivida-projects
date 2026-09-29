class Bed {
  final String id;
  final String label;
  String status; // Occupied, Vacant, Maintenance, Reserved
  String? studentName;

  Bed({required this.id, required this.label, required this.status, this.studentName});
}
