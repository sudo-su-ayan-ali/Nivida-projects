class Visitor {
  final String id;
  final String visitorName;
  final String studentName;
  final String relation;
  final String phone;
  final String idType;
  final String idNumber;
  final String purpose;
  final DateTime checkIn;
  DateTime? checkOut;
  String status;

  Visitor({
    required this.id,
    required this.visitorName,
    required this.studentName,
    required this.relation,
    required this.phone,
    required this.idType,
    required this.idNumber,
    required this.purpose,
    required this.checkIn,
    this.checkOut,
    required this.status,
  });
}
