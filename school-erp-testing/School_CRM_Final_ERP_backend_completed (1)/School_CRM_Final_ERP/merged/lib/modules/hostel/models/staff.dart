class StaffMember {
  final String id;
  final String name;
  final String employeeId;
  final String role;
  final String phone;
  final String email;
  final DateTime joiningDate;
  final String status;

  const StaffMember({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.role,
    required this.phone,
    required this.email,
    required this.joiningDate,
    required this.status,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? role,
    String? phone,
    String? email,
    DateTime? joiningDate,
    String? status,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      joiningDate: joiningDate ?? this.joiningDate,
      status: status ?? this.status,
    );
  }
}
