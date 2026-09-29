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
    return AttendanceRecord(
      id: row['id'],
      studentName: student['name'] ?? '',
      rollNo: student['admission_no'] ?? '',
      studentClass: student['class_num']?.toString() ?? '',
      section: student['section'] ?? '',
      status: AttendanceStatus.values.firstWhere((s) => s.name == row['status']),
      checkIn: '',
      checkOut: '',
      remarks: '',
      avatarSeed: row['student_id'],
    );
  }
}


class AttendanceTrendPoint {
  final String label; // e.g. "Apr 11"
  final double value; // percentage 0-100
  const AttendanceTrendPoint(this.label, this.value);
}

enum TrendRange { today, week, month, year }
