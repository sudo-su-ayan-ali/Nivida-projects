class Notice {
  final String id;
  final String title;
  final String description;
  final String category;
  final String audience;
  final DateTime publishDate;
  final DateTime expiryDate;
  final String priority;
  String status;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.audience,
    required this.publishDate,
    required this.expiryDate,
    required this.priority,
    required this.status,
  });
}
