import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

class StudentRepository extends ChangeNotifier {
  final _client = Supabase.instance.client;
  final List<Student> _students = [];
  bool isLoading = true;
  int pendingTcRequests = 0;
  int presentTodayCount = 0;
  int activeHostelBlocksCount = 0;

  List<Student> get all => List.unmodifiable(_students);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final data = await _client.from('students').select().order('created_at');
    _students
      ..clear()
      ..addAll(
        (data as List).map((row) => Student.fromMap(row as Map<String, dynamic>)),
      );

    final tcRows = await _client.from('tc_requests').select().eq('status', 'pending');
    pendingTcRequests = (tcRows as List).length;

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final presentRows = await _client
        .from('attendance_records')
        .select('id')
        .eq('session_date', todayStr)
        .eq('status', 'present');
    presentTodayCount = (presentRows as List).length;

    final hostelBlockRows = await _client.from('hostel_blocks').select('id');
    activeHostelBlocksCount = (hostelBlockRows as List).length;

    isLoading = false;
    notifyListeners();
  }
  // ... baaki sab methods same rahenge

  Future<void> addStudent(Student student) async {
  const institutionId = 'd0000000-0000-0000-0000-000000000001';
  const courseId = 'd0000000-0000-0000-0000-000000000020';
  const sectionId = 'd0000000-0000-0000-0000-000000000040';

  // Step A: pehle 'admissions' table mein entry banao — students.admission_id
  // NOT NULL hai, aur har student ke liye alag admission record chahiye.
  final admissionInsert = await _client.from('admissions').insert({
    'institution_id': institutionId,
    'course_id': courseId,
    'applicant_name': student.name,
    'contact_email': student.email.isNotEmpty ? student.email : null,
    'contact_phone': student.mobile,
    'date_of_birth': student.dob.toIso8601String().split('T').first,
  }).select().single();

  final admissionId = admissionInsert['id'];

  // Step B: ab students table mein insert karo — student.toMap() ke data
  // ke saath institution/course/section/admission IDs bhi jodo.
  final studentMap = student.toMap()
    ..addAll({
      'institution_id': institutionId,
      'admission_id': admissionId,
      'course_id': courseId,
      'section_id': sectionId,
      'current_semester': 1,
    });

  final inserted = await _client
      .from('students')
      .insert(studentMap)
      .select()
      .single();

  _students.insert(0, Student.fromMap(inserted));
  notifyListeners();
}

  Future<void> updateStudent(Student updated) async {
    await _client.from('students').update(updated.toMap()).eq('id', updated.id);
    final idx = _students.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      _students[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    await _client.from('students').delete().eq('id', id);
    _students.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Student? byId(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  int get total => _students.length;
  int get boys => _students.where((s) => s.gender == 'Male').length;
  int get girls => _students.where((s) => s.gender == 'Female').length;
 int get presentToday => presentTodayCount;
double get presentPercent => total == 0 ? 0 : (presentToday / total) * 100;
  int get newAdmissionsThisMonth {
    final now = DateTime.now();
    return _students
        .where(
          (s) =>
              s.admissionDate.year == now.year &&
              s.admissionDate.month == now.month,
        )
        .length;
  }

  Map<int, int> get classWiseCounts {
    final map = <int, int>{};
    for (final s in _students) {
      map[s.classNum] = (map[s.classNum] ?? 0) + 1;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Map<String, int> get bloodGroupCounts {
    final map = <String, int>{};
    for (final s in _students) {
      map[s.bloodGroup] = (map[s.bloodGroup] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get categoryCounts {
    final map = <String, int>{};
    for (final s in _students) {
      map[s.category] = (map[s.category] ?? 0) + 1;
    }
    return map;
  }

  int get transportUsers => _students.where((s) => s.usesTransport).length;
  int get activeRoutes =>
      transportUsers == 0 ? 0 : (transportUsers / 19).ceil();
  int get hostelResidents => _students.where((s) => s.livesInHostel).length;
  int get activeHostels => activeHostelBlocksCount;
  double get docVerifiedPercent => total == 0
      ? 0
      : (_students.where((s) => s.documentsVerified).length / total) * 100;
  int get idCardsGenerated => _students.where((s) => s.idCardGenerated).length;
  int get idCardsPending => total - idCardsGenerated;

  List<Student> get birthdaysToday =>
      _students.where((s) => s.isBirthdayToday).toList();
  List<Student> get feeDueStudents =>
      _students.where((s) => s.feeDue > 0).toList();
  List<Student> get lowAttendanceStudents =>
      _students.where((s) => s.attendancePercent < 75).toList();

  List<Student> get topPerformers {
    final sorted = [..._students]
      ..sort((a, b) => b.examAveragePercent.compareTo(a.examAveragePercent));
    return sorted.take(3).toList();
  }

  List<Student> get atRiskStudents {
    final risky = _students
        .where((s) => s.riskLevel != RiskLevel.none)
        .toList();
    risky.sort((a, b) => a.riskLevel.index.compareTo(b.riskLevel.index));
    return risky.take(5).toList();
  }

  List<double> get weeklyAttendance {
    final base = total == 0
        ? 90.0
        : _students.map((s) => s.attendancePercent).reduce((a, b) => a + b) /
              total;
    return [
      base - 3,
      base - 0.5,
      base - 1.5,
      base + 1,
      base + 2,
      base - 4,
    ].map((v) => v.clamp(0, 100).toDouble()).toList();
  }

  List<double> get growthTrend => [
    total * 0.7,
    total * 0.8,
    total * 0.85,
    total * 0.9,
    total * 0.95,
    total.toDouble(),
  ];
}
