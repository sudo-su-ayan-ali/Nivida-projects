class Payment {
  final String id;
  final String studentName;
  final String room;
  final double amount;
  final String type; // Cash, UPI, Card, Bank Transfer, Online
  final DateTime date;
  String status; // Paid, Pending, Failed, Partial
  final String invoiceNo;

  Payment({
    required this.id,
    required this.studentName,
    required this.room,
    required this.amount,
    required this.type,
    required this.date,
    required this.status,
    required this.invoiceNo,
  });
}
