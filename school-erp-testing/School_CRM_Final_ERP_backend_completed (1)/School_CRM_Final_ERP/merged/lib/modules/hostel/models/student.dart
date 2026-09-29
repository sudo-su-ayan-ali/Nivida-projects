class Student {
  final String id;
  final String name;
  final String photoInitials;
  final String className;
  final String section;
  final String gender;
  final int age;
  final String phone;
  final String guardianName;
  final String guardianPhone;
  final String room;
  final String block;
  final String status; // Active, Inactive
  final DateTime admissionDate;
  final String bloodGroup;
  final String address;
  final String email;

  const Student({
    required this.id,
    required this.name,
    required this.photoInitials,
    required this.className,
    required this.section,
    required this.gender,
    required this.age,
    required this.phone,
    required this.guardianName,
    required this.guardianPhone,
    required this.room,
    required this.block,
    required this.status,
    required this.admissionDate,
    required this.bloodGroup,
    required this.address,
    required this.email,
  });
}
