enum StudentStatus { active, inactive }

enum RiskLevel { high, medium, low, none }

class Student {
  final String id;
  final String admissionNo;
  final String name;
  final String email;
  final int classNum;
  final String section;
  final String mobile;
  final String parentName;
  final String parentMobile;
  final StudentStatus status;
  final String gender; // 'Male' | 'Female'
  final String bloodGroup; // O+, A+, B+, AB+, Others
  final String category; // General, OBC, SC, ST
  final DateTime dob;
  final DateTime admissionDate;
  final String address;
  final bool usesTransport;
  final String? transportRoute;
  final bool livesInHostel;
  final String? hostelName;
  final bool documentsVerified;
  final bool idCardGenerated;
  final double attendancePercent;
  final double examAveragePercent;
  final double feeDue;
  final RiskLevel riskLevel;
  final String riskReason;
  final bool isBirthdayToday;

  const Student({
    required this.id,
    required this.admissionNo,
    required this.name,
    required this.email,
    required this.classNum,
    required this.section,
    required this.mobile,
    required this.parentName,
    required this.parentMobile,
    required this.status,
    required this.gender,
    required this.bloodGroup,
    required this.category,
    required this.dob,
    required this.admissionDate,
    required this.address,
    required this.usesTransport,
    this.transportRoute,
    required this.livesInHostel,
    this.hostelName,
    required this.documentsVerified,
    required this.idCardGenerated,
    required this.attendancePercent,
    required this.examAveragePercent,
    required this.feeDue,
    required this.riskLevel,
    required this.riskReason,
    required this.isBirthdayToday,
  });

  Student copyWith({
    String? name,
    String? email,
    int? classNum,
    String? section,
    String? mobile,
    String? parentName,
    String? parentMobile,
    StudentStatus? status,
    String? gender,
    String? bloodGroup,
    String? category,
    String? address,
    bool? usesTransport,
    String? transportRoute,
    bool? livesInHostel,
    String? hostelName,

  }) {
    return Student(
      id: id,
      admissionNo: admissionNo,
      name: name ?? this.name,
      email: email ?? this.email,
      classNum: classNum ?? this.classNum,
      section: section ?? this.section,
      mobile: mobile ?? this.mobile,
      parentName: parentName ?? this.parentName,
      parentMobile: parentMobile ?? this.parentMobile,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      category: category ?? this.category,
      dob: dob,
      admissionDate: admissionDate,
      address: address ?? this.address,
      usesTransport: usesTransport ?? this.usesTransport,
      transportRoute: transportRoute ?? this.transportRoute,
      livesInHostel: livesInHostel ?? this.livesInHostel,
      hostelName: hostelName ?? this.hostelName,
      documentsVerified: documentsVerified,
      idCardGenerated: idCardGenerated,
      attendancePercent: attendancePercent,
      examAveragePercent: examAveragePercent,
      feeDue: feeDue,
      riskLevel: riskLevel,
      riskReason: riskReason,
      isBirthdayToday: isBirthdayToday,
    );
  }
  factory Student.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value as String) ?? DateTime.now();
    }

    final dobParsed = parseDate(map['date_of_birth']);

    return Student(
      id: map['id'] as String? ?? '',
      admissionNo: map['enrollment_no'] as String? ?? '',
      name: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      classNum: (map['class_num'] as num?)?.toInt() ?? 0,
      section: map['section'] as String? ?? '',
      mobile: map['contact_phone'] as String? ?? '',
      parentName: map['guardian_name'] as String? ?? '',
      parentMobile: map['parent_mobile'] as String? ?? '',
      status: (map['status'] == 'active') ? StudentStatus.active : StudentStatus.inactive,
      gender: map['gender'] as String? ?? '',
      bloodGroup: map['blood_group'] as String? ?? '',
      category: map['category'] as String? ?? '',
      dob: dobParsed,
      admissionDate: parseDate(map['admission_date']),
      address: map['address'] as String? ?? '',
      usesTransport: map['uses_transport'] as bool? ?? false,
      transportRoute: map['transport_route'] as String?,
      livesInHostel: map['lives_in_hostel'] as bool? ?? false,
      hostelName: map['hostel_name'] as String?,
      documentsVerified: map['documents_verified'] as bool? ?? false,
      idCardGenerated: map['id_card_generated'] as bool? ?? false,
      attendancePercent: (map['attendance_percent'] as num?)?.toDouble() ?? 0,
      examAveragePercent: (map['exam_average_percent'] as num?)?.toDouble() ?? 0,
      feeDue: (map['fee_due'] as num?)?.toDouble() ?? 0,
      riskLevel: RiskLevel.values.firstWhere(
        (r) => r.name == (map['risk_level'] ?? 'none'),
        orElse: () => RiskLevel.none,
      ),
      riskReason: map['risk_reason'] as String? ?? '',
      isBirthdayToday: dobParsed.month == DateTime.now().month &&
          dobParsed.day == DateTime.now().day,
    );
  }
Map<String, dynamic> toMap() {
  return {
    
    'enrollment_no': admissionNo,
    'full_name': name,
    'email': email,
      'class_num': classNum,
      'section': section,
      'contact_phone': mobile,
      'guardian_name': parentName,
      'parent_mobile': parentMobile,
      'status': status == StudentStatus.active ? 'active' : 'inactive',
      'gender': gender,
      'blood_group': bloodGroup,
      'category': category,
      'date_of_birth': dob.toIso8601String().split('T').first,
      'admission_date': admissionDate.toIso8601String().split('T').first,
      'address': address,
      'uses_transport': usesTransport,
      'transport_route': transportRoute,
      'lives_in_hostel': livesInHostel,
      'hostel_name': hostelName,
      'documents_verified': documentsVerified,
      'id_card_generated': idCardGenerated,
      'attendance_percent': attendancePercent,
      'exam_average_percent': examAveragePercent,
      'fee_due': feeDue,
      'risk_level': riskLevel.name,
      'risk_reason': riskReason,
    };
  }
}