import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fetches the real numbers shown on the main Dashboard's KPI cards
/// (Total Students, Total Teachers, Total Users, Today's Attendance %,
/// Monthly Collection) directly from Supabase.
///
/// IMPORTANT: this ERP is multi-school (every table has an
/// `institution_id` column), so every query here is scoped to the
/// current logged-in user's own institution_id — otherwise counts
/// would leak across schools.
class DashboardRepository extends ChangeNotifier {
  final SupabaseClient? _customClient;

  DashboardRepository({SupabaseClient? client}) : _customClient = client;

  SupabaseClient get _client => _customClient ?? Supabase.instance.client;

  int totalStudents = 0;
  int totalTeachers = 0;
  int totalUsers = 0;
  double todayAttendancePercent = 0;
  double monthlyCollection = 0;
  double feeCollected = 0;
  double feePending = 0;
  double feeOverdue = 0;
  bool isLoading = true;
  String? error;
 
// 👇 NEW — Admission chart ke liye
List<String> admissionMonths = [];
List<double> admissionCounts = [];
int totalAdmissionsThisSession = 0;

  /// Designation values in `employees` that count as "teaching staff".
  /// Adjust/expand this list to match your actual designation values
  /// (e.g. add 'Lecturer', 'PGT', 'TGT', 'Vice Principal' etc. if used).
  static const _teachingDesignationKeywords = [
    'professor',
    'teacher',
    'head of department',
    'hod',
    'lecturer',
  ];

    Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final userId = _client.auth.currentUser?.id;
    debugPrint('DASHBOARD DEBUG: current userId = $userId');
    String? institutionId;
    try {
      if (userId != null) {
        final profileRow = await _client
            .from('profiles')
            .select('institution_id')
            .eq('id', userId)
            .maybeSingle();
        debugPrint('DASHBOARD DEBUG: profileRow = $profileRow');
        institutionId = profileRow?['institution_id'] as String?;
      }
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: profile lookup failed: $e');
    }
    debugPrint('DASHBOARD DEBUG: institutionId = $institutionId');

    try {
      var studentsQuery = _client.from('students').select('id');
      if (institutionId != null) {
        studentsQuery = studentsQuery.eq('institution_id', institutionId);
      }
      final studentsData = await studentsQuery;
      totalStudents = (studentsData as List).length;
      debugPrint('DASHBOARD DEBUG: totalStudents = $totalStudents');
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: students query failed: $e');
    }

    try {
      var employeesQuery = _client.from('employees').select('designation');
      if (institutionId != null) {
        employeesQuery = employeesQuery.eq('institution_id', institutionId);
      }
      final employeesData = await employeesQuery;
      totalTeachers = (employeesData as List).where((row) {
        final designation = (row['designation'] as String?)?.toLowerCase();
        if (designation == null) return false;
        return _teachingDesignationKeywords.any(
          (keyword) => designation.contains(keyword),
        );
      }).length;
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: employees query failed: $e');
    }

    try {
      var usersQuery = _client.from('profiles').select('id');
      if (institutionId != null) {
        usersQuery = usersQuery.eq('institution_id', institutionId);
      }
      final usersData = await usersQuery;
      totalUsers = (usersData as List).length;
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: users query failed: $e');
    }

    try {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      var attendanceQuery = _client
          .from('attendance_records')
          .select('status')
          .eq('session_date', todayStr);
      if (institutionId != null) {
        attendanceQuery = attendanceQuery.eq('institution_id', institutionId);
      }
      final attendanceData = await attendanceQuery;
      final attendanceRows = attendanceData as List;
      if (attendanceRows.isNotEmpty) {
        final presentCount =
            attendanceRows.where((r) => r['status'] == 'present').length;
        todayAttendancePercent = (presentCount / attendanceRows.length) * 100;
      } else {
        todayAttendancePercent = 0;
      }
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: attendance query failed: $e');
    }

    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);
      var paymentsQuery = _client
          .from('payments')
          .select('amount, status, confirmed_at')
          .gte('confirmed_at', monthStart.toIso8601String())
          .lt('confirmed_at', monthEnd.toIso8601String());
      if (institutionId != null) {
        paymentsQuery = paymentsQuery.eq('institution_id', institutionId);
      }
      final paymentsData = await paymentsQuery;
      final paymentsRows = paymentsData as List;
      monthlyCollection = paymentsRows
          .where((row) => row['status'] == 'success')
          .fold<double>(
            0,
            (sum, row) => sum + ((row['amount'] as num?)?.toDouble() ?? 0),
          );
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: monthly collection query failed: $e');
    }

        try {
      var installmentsQuery = _client
          .from('student_fees')
          .select('amount_due, amount_paid, due_date, status');
      if (institutionId != null) {
        installmentsQuery =
            installmentsQuery.eq('institution_id', institutionId);
      }
      final installmentsData = await installmentsQuery;
      final installmentRows = installmentsData as List;

      double collected = 0;
      double pending = 0;
      double overdue = 0;
      final today = DateTime.now();

      for (final row in installmentRows) {
        final amount = (row['amount_due'] as num?)?.toDouble() ?? 0;
        final paid = (row['amount_paid'] as num?)?.toDouble() ?? 0;
        final remaining = amount - paid;
        collected += paid;
        if (remaining > 0.01) {
          final dueDate = row['due_date'] != null
              ? DateTime.tryParse(row['due_date'] as String)
              : null;
          if (dueDate != null && today.isAfter(dueDate)) {
            overdue += remaining;
          } else {
            pending += remaining;
          }
        }
      }
      feeCollected = collected;
      feePending = pending;
      feeOverdue = overdue;
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: fee query failed: $e');
    }

    try {
      final monthLabels = ['Jan','Feb','Mar','Apr','May','Jun','Jul',
                            'Aug','Sep','Oct','Nov','Dec'];
      final now2 = DateTime.now();
      final months = <DateTime>[
        for (int i = 6; i >= 0; i--)
          DateTime(now2.year, now2.month - i, 1),
      ];
      final rangeStart = months.first;

      var admissionsQuery = _client
          .from('students')
          .select('created_at')
          .gte('created_at', rangeStart.toIso8601String());
      if (institutionId != null) {
        admissionsQuery =
            admissionsQuery.eq('institution_id', institutionId);
      }
      final admissionsData = await admissionsQuery;
      final admissionRows = admissionsData as List;

      final counts = List<double>.filled(months.length, 0);
      for (final row in admissionRows) {
        final dateStr = row['created_at'] as String?;
        if (dateStr == null) continue;
        final d = DateTime.tryParse(dateStr);
        if (d == null) continue;
        for (int i = 0; i < months.length; i++) {
          if (d.year == months[i].year && d.month == months[i].month) {
            counts[i] += 1;
            break;
          }
        }
      }
      admissionMonths = [for (final m in months) monthLabels[m.month - 1]];
      admissionCounts = counts;
      totalAdmissionsThisSession = counts.fold(0, (a, b) => a + b.toInt());
      debugPrint('DASHBOARD DEBUG: admissionCounts = $admissionCounts');
    } catch (e) {
      debugPrint('DASHBOARD DEBUG: admissions query failed: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}