enum AttendanceStatus { present, absent, late, leave }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }
}

class AttendanceRecord {
  final String id;
  final String studentName;
  final String rollNo;
  final String studentClass;
  final String section;
  final AttendanceStatus status;
  final String checkIn;
  final String checkOut;
  final String remarks;
  final String avatarSeed;

  const AttendanceRecord({
    required this.id,
    required this.studentName,
    required this.rollNo,
    required this.studentClass,
    required this.section,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.remarks,
    required this.avatarSeed,
  });

  AttendanceRecord copyWith({AttendanceStatus? status}) => AttendanceRecord(
    
        id: id,
        studentName: studentName,
        rollNo: rollNo,
        studentClass: studentClass,
        section: section,
        status: status ?? this.status,
        checkIn: checkIn,
        checkOut: checkOut,
        remarks: remarks,
        avatarSeed: avatarSeed,
      );
      
  factory AttendanceRecord.fromMap(Map<String, dynamic> row) {
    final student = row['students'] ?? {};
    final statusStr = (row['status'] ?? 'present').toString().toLowerCase();
    final status = AttendanceStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => AttendanceStatus.present,
    );
    return AttendanceRecord(
      id: row['id']?.toString() ?? '',
      studentName: (student['full_name'] ?? student['name'] ?? '').toString(),
      rollNo: (student['enrollment_no'] ?? student['admission_no'] ?? '').toString(),
      studentClass: student['class_num']?.toString() ?? '',
      section: student['section']?.toString() ?? '',
      status: status,
      checkIn: row['check_in']?.toString() ?? '',
      checkOut: row['check_out']?.toString() ?? '',
      remarks: row['remarks']?.toString() ?? '',
      avatarSeed: row['student_id']?.toString() ?? '',
    );
  }
}


class AttendanceTrendPoint {
  final String label; // e.g. "Apr 11"
  final double value; // percentage 0-100
  const AttendanceTrendPoint(this.label, this.value);
}

enum TrendRange { today, week, month, year }
