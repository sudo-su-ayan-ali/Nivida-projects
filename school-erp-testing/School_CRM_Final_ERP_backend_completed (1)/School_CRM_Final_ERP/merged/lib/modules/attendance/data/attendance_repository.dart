import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_record.dart';

class AttendanceRepository extends ChangeNotifier {
  final SupabaseClient? _injectedClient;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  List<AttendanceRecord> records = [];
  bool isLoading = true;

  AttendanceRepository({SupabaseClient? client}) : _injectedClient = client;

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

  Future<void> loadForDate(DateTime date) async {
    isLoading = true;
    notifyListeners();
    final dateStr = date.toIso8601String().split('T').first;
    final institutionId = await _resolveInstitutionId();

    var query = _client
        .from('attendance_records')
        .select('*, students(full_name, enrollment_no, class_num, section)')
        .eq('session_date', dateStr);

    if (institutionId != null) {
      query = query.eq('institution_id', institutionId);
    }

    final data = await query;
    records = (data as List).map((row) => AttendanceRecord.fromMap(row)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> markAttendance(String studentId, String className, DateTime date, String status) async {
    final userId = _client.auth.currentUser?.id;
    final institutionId = await _resolveInstitutionId();
    final payload = <String, dynamic>{
      'student_id': studentId,
      'session_date': date.toIso8601String().split('T').first,
      'status': status,
      'marked_by': userId,
    };
    if (institutionId != null) {
      payload['institution_id'] = institutionId;
    }

    await _client.from('attendance_records').upsert(payload, onConflict: 'student_id,session_date');
  }

  Future<List<AttendanceRecord>> loadAllStudentsForMarking() async {
    final institutionId = await _resolveInstitutionId();
    var query = _client.from('students').select('id, full_name, enrollment_no, class_num, section');
    if (institutionId != null) {
      query = query.eq('institution_id', institutionId);
    }
    final data = await query;
    return (data as List).map((row) => AttendanceRecord(
    id: row['id'],
    studentName: row['full_name'] ?? '',
    rollNo: row['enrollment_no'] ?? '',
    studentClass: row['class_num']?.toString() ?? '',
    section: row['section'] ?? '',
    status: AttendanceStatus.present,
    checkIn: '',
    checkOut: '',
    remarks: '',
    avatarSeed: row['id'],
  )).toList();
}

  /// Real "Class 1".."Class 12" style options built from whatever classes
  /// actually exist in the `students` table — not a hardcoded list.
  Future<List<String>> fetchClassOptions() async {
    final institutionId = await _resolveInstitutionId();
    var query = _client.from('students').select('class_num');
    if (institutionId != null) {
      query = query.eq('institution_id', institutionId);
    }
    final rows = await query;
    final classes = <int>{};
    for (final r in rows as List) {
      final c = r['class_num'];
      if (c != null) classes.add(c is int ? c : int.tryParse(c.toString()) ?? -1);
    }
    final sorted = classes.where((c) => c > 0).toList()..sort();
    return sorted.map((c) => 'Class $c').toList();
  }

  /// Real distinct section letters from the `students` table.
  Future<List<String>> fetchSectionOptions() async {
    final institutionId = await _resolveInstitutionId();
    var query = _client.from('students').select('section');
    if (institutionId != null) {
      query = query.eq('institution_id', institutionId);
    }
    final rows = await query;
    final sections = <String>{};
    for (final r in rows as List) {
      final s = r['section']?.toString();
      if (s != null && s.isNotEmpty) sections.add(s);
    }
    final sorted = sections.toList()..sort();
    return sorted;
  }

  /// Real attendance trend: % present per day, aggregated from
  /// `attendance_records` for the given date window.
  Future<List<AttendanceTrendPoint>> fetchTrend(TrendRange range) async {
    final now = DateTime.now();
    final DateTime from;
    switch (range) {
      case TrendRange.today:
        from = DateTime(now.year, now.month, now.day);
        break;
      case TrendRange.week:
        from = now.subtract(const Duration(days: 6));
        break;
      case TrendRange.month:
        from = now.subtract(const Duration(days: 29));
        break;
      case TrendRange.year:
        from = DateTime(now.year - 1, now.month, now.day);
        break;
    }
    final fromStr = from.toIso8601String().split('T').first;
    final institutionId = await _resolveInstitutionId();

    var query = _client
        .from('attendance_records')
        .select('session_date, status')
        .gte('session_date', fromStr);

    if (institutionId != null) {
      query = query.eq('institution_id', institutionId);
    }

    final rows = await query.order('session_date');

    // Group by day: percentage present = present_count / total_count * 100
    final byDay = <String, List<String>>{};
    for (final r in rows as List) {
      final day = r['session_date'] as String;
      byDay.putIfAbsent(day, () => []).add(r['status'] as String);
    }

    final points = <AttendanceTrendPoint>[];
    final sortedDays = byDay.keys.toList()..sort();
    for (final day in sortedDays) {
      final statuses = byDay[day]!;
      final present = statuses.where((s) => s == 'present').length;
      final pct = statuses.isEmpty ? 0.0 : (present / statuses.length) * 100;
      final label = _shortLabel(DateTime.parse(day), range);
      points.add(AttendanceTrendPoint(label, pct));
    }
    return points;
  }

  String _shortLabel(DateTime d, TrendRange range) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    if (range == TrendRange.year) return months[d.month - 1];
    return '${months[d.month - 1]} ${d.day}';
  }

  /// Bulk-import attendance from parsed CSV rows.
  ///
  /// [rows] is a list of maps already parsed from the CSV, each expected to
  /// have 'roll_no' (matches students.enrollment_no) and 'status'
  /// ('present' | 'absent' | 'late' | 'leave'). Rows whose roll number
  /// doesn't match any student are skipped and counted as [skipped].
  ///
  /// Returns the number of rows successfully written.
  Future<({int imported, int skipped})> bulkImportAttendance(
    List<Map<String, String>> rows,
    DateTime date,
  ) async {
    final institutionId = await _resolveInstitutionId();
    var studentsQuery = _client.from('students').select('id, enrollment_no');
    if (institutionId != null) {
      studentsQuery = studentsQuery.eq('institution_id', institutionId);
    }
    final studentRows = await studentsQuery;

    final rollToId = <String, String>{
      for (final s in studentRows as List)
        (s['enrollment_no'] ?? '').toString(): s['id'] as String,
    };

    final userId = _client.auth.currentUser?.id;
    final dateStr = date.toIso8601String().split('T').first;
    final validStatuses = {'present', 'absent', 'late', 'leave'};

    final upserts = <Map<String, dynamic>>[];
    var skipped = 0;
    for (final row in rows) {
      final roll = (row['roll_no'] ?? '').trim();
      final status = (row['status'] ?? '').trim().toLowerCase();
      final studentId = rollToId[roll];
      if (studentId == null || !validStatuses.contains(status)) {
        skipped++;
        continue;
      }
      final payload = <String, dynamic>{
        'student_id': studentId,
        'session_date': dateStr,
        'status': status,
        'marked_by': userId,
      };
      if (institutionId != null) {
        payload['institution_id'] = institutionId;
      }
      upserts.add(payload);
    }

    if (upserts.isNotEmpty) {
      await _client
          .from('attendance_records')
          .upsert(upserts, onConflict: 'student_id,session_date');
    }

    return (imported: upserts.length, skipped: skipped);
  }
  
}