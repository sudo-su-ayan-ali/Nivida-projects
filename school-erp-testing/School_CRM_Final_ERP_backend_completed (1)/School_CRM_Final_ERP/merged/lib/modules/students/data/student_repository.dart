import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

class StudentRepository extends ChangeNotifier {
  final SupabaseClient? _customClient;

  StudentRepository({SupabaseClient? client}) : _customClient = client;

  SupabaseClient get _client => _customClient ?? Supabase.instance.client;

  final List<Student> _students = [];
  bool isLoading = true;
  int pendingTcRequests = 0;
  int presentTodayCount = 0;
  int activeHostelBlocksCount = 0;

  List<Student> get all => List.unmodifiable(_students);

  Future<String?> _resolveInstitutionId() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;
      final profile = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', userId)
          .maybeSingle();
      return profile?['institution_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final institutionId = await _resolveInstitutionId();

    var studentsQuery = _client.from('students').select();
    if (institutionId != null) {
      studentsQuery = studentsQuery.eq('institution_id', institutionId);
    }
    final data = await studentsQuery.order('created_at');

    _students
      ..clear()
      ..addAll(
        (data as List).map((row) => Student.fromMap(row as Map<String, dynamic>)),
      );

    dynamic tcRows;
    try {
      var tcQuery = _client.from('tc_requests').select().eq('status', 'pending');
      if (institutionId != null) {
        tcQuery = tcQuery.eq('institution_id', institutionId);
      }
      tcRows = await tcQuery;
    } on PostgrestException catch (e) {
      if (e.code == '42703' || e.message.contains('institution_id')) {
        tcRows = await _client.from('tc_requests').select().eq('status', 'pending');
      } else {
        rethrow;
      }
    }
    pendingTcRequests = (tcRows as List).length;

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    dynamic presentRows;
    try {
      var presentQuery = _client
          .from('attendance_records')
          .select('id')
          .eq('session_date', todayStr)
          .eq('status', 'present');
      if (institutionId != null) {
        presentQuery = presentQuery.eq('institution_id', institutionId);
      }
      presentRows = await presentQuery;
    } on PostgrestException catch (e) {
      if (e.code == '42703' || e.message.contains('institution_id')) {
        presentRows = await _client
            .from('attendance_records')
            .select('id')
            .eq('session_date', todayStr)
            .eq('status', 'present');
      } else {
        rethrow;
      }
    }
    presentTodayCount = (presentRows as List).length;

    dynamic hostelBlockRows;
    try {
      var hostelQuery = _client.from('hostel_blocks').select('id');
      if (institutionId != null) {
        hostelQuery = hostelQuery.eq('institution_id', institutionId);
      }
      hostelBlockRows = await hostelQuery;
    } on PostgrestException catch (e) {
      if (e.code == '42703' || e.message.contains('institution_id')) {
        hostelBlockRows = await _client.from('hostel_blocks').select('id');
      } else {
        rethrow;
      }
    }
    activeHostelBlocksCount = (hostelBlockRows as List).length;

    isLoading = false;
    notifyListeners();
  }
  // ... baaki sab methods same rahenge

  Future<void> addStudent(Student student) async {
    final currentInstId = await _resolveInstitutionId();
    final institutionId = currentInstId ?? '00000000-0000-0000-0000-000000000001';

    // Resolve a real course/section for this tenant (never invent phantom UUIDs).
    String? courseId;
    String? sectionId;
    try {
      final course = await _client
          .from('courses')
          .select('id')
          .eq('institution_id', institutionId)
          .limit(1)
          .maybeSingle();
      courseId = course?['id'] as String?;
      if (courseId != null) {
        final section = await _client
            .from('sections')
            .select('id')
            .eq('course_id', courseId)
            .limit(1)
            .maybeSingle();
        sectionId = section?['id'] as String?;
      }
    } catch (_) {}

    // Step A: pehle 'admissions' table mein entry banao — students.admission_id
    // NOT NULL hai, aur har student ke liye alag admission record chahiye.
    final admissionPayload = <String, dynamic>{
      'institution_id': institutionId,
      'applicant_name': student.name,
      'contact_email': student.email.isNotEmpty ? student.email : null,
      'contact_phone': student.mobile,
      'date_of_birth': student.dob.toIso8601String().split('T').first,
    };
    if (courseId != null) admissionPayload['course_id'] = courseId;

    final admissionInsert =
        await _client.from('admissions').insert(admissionPayload).select().single();

    final admissionId = admissionInsert['id'];

    // Step B: students insert — class_num/section come from student.toMap().
    // Do NOT send current_semester (column does not exist on provisioned schema).
    final studentMap = student.toMap()
      ..addAll({
        'institution_id': institutionId,
        'admission_id': admissionId,
        if (courseId != null) 'course_id': courseId,
        if (sectionId != null) 'section_id': sectionId,
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
    // In live PostgreSQL instances where child tables were created without ON DELETE CASCADE,
    // foreign key constraint 23503 is raised. We cleanly delete or detach child records first.
    final childTables = [
      'student_transport',
      'hostel_students',
      'tc_requests',
      'homework_submissions',
      'parent_student_links',
      'attendance_records',
      'attendance',
      'student_fees',
      'fee_transactions',
      'fee_waivers',
      'results',
    ];
    for (final table in childTables) {
      try {
        await _client.from(table).delete().eq('student_id', id);
      } catch (e) {
        debugPrint('Note: cleanup on $table for student $id: $e');
      }
    }
    try {
      await _client.from('library_books').update({'student_id': null}).eq('student_id', id);
    } catch (e) {
      debugPrint('Note: detach library_books for student $id: $e');
    }

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
