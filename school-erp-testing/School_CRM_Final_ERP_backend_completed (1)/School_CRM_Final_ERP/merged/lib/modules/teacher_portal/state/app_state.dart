import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/dashboard_models.dart';
import '../theme/app_colors.dart';
import '../screens/nav_indices.dart' show navIndicesForRole, kDashboardNavIndex;

/// Single source of truth for the whole app. Every interactive element in
/// the ERP reads from / writes to this instead of static dummy data, so
/// marking attendance, creating an assignment, sending a message, etc. all
/// genuinely change what's shown across every screen.
class AppState extends ChangeNotifier {
  /// Set by the host app (see `main.dart`'s `EduSmartApp`) so a real
  /// "Logout" tap can hand control back to the main ERP's login screen
  /// instead of just showing a demo snackbar.
  VoidCallback? onLogout;
  final _client = Supabase.instance.client;

  AppState() {
        students = [];
    unawaited(_loadStudents().then((_) {
  _loadAttendanceToday();
  _loadGradebook();
}));
       assignments = [];
    unawaited(_loadAssignments());
    exams = [];
unawaited(_loadExams());
    messages = [];
unawaited(_loadMessages());
    notifications = [];
unawaited(_loadNotifications());
    studyMaterials = [];
    questionBank = [];
    library = [];
    lessonPlans = [];
    unawaited(_loadResources());
    unawaited(_loadLessonPlans());
    gradebook = {};
    syllabus = [];
unawaited(_loadSyllabus());
    ptmSlots = [];
unawaited(_loadPtmSlots());
    todos = [];
unawaited(_loadTodos());
   homework = [];
unawaited(_loadHomework());
    onlineClasses = _seedOnlineClasses();
    feeRecords = _seedFeeRecords();
    notices = [];
unawaited(_loadNotices());
timetableData = {for (final d in _weekdayShort) d: []};
unawaited(_loadTimetable());
calendarEvents = _seedCalendarEvents();
leaveRequests = [];
unawaited(_loadLeaveRequests());
accessRequests = _seedAccessRequests();
payslips = [];
unawaited(_loadPayslips());
studentDocuments = [];
unawaited(_loadDocuments());
totalStaff = 0;
unawaited(_loadStaffCount());
weeklyAttendanceLabels = [];
weeklyAttendance = [];
unawaited(_loadWeeklyAttendance());
}
Future<void> _loadAssignments() async {
  final rows = await _client
      .from('assignments')
      .select()
      .order('created_at', ascending: false);

  const icons = [
    Icons.description_outlined,
    Icons.functions_outlined,
    Icons.calculate_outlined,
    Icons.menu_book_outlined,
  ];
  const palette = [
    [AppColors.purple, AppColors.purpleBg],
    [AppColors.blue, AppColors.blueBg],
    [AppColors.pink, AppColors.pinkBg],
    [AppColors.green, AppColors.greenBg],
  ];

  assignments = (rows as List).asMap().entries.map((entry) {
    final i = entry.key % palette.length;
    final row = entry.value;
    return AssignmentItem(
      id: row['id'] as String,
      icon: icons[i],
      color: palette[i][0],
      bgColor: palette[i][1],
      title: row['title'] as String,
      className: row['class_name'] as String,
      dueDate: row['due_date'] as String,
      pendingCount: row['pending_count'] as int,
      totalCount: row['total_count'] as int,
      graded: row['graded'] as bool,
    );
  }).toList();
  notifyListeners();
}
Future<void> _loadMessages() async {
  final rows = await _client
      .from('staff_messages')
      .select()
      .order('created_at', ascending: false);

  messages = (rows as List).map((row) {
    return MessageItem(
      id: row['id'] as String,
      icon: Icons.send_outlined,
      color: AppColors.blue,
      bgColor: AppColors.blueBg,
      title: 'Message to ${row['recipient']}',
      meta: row['body'] as String,
      time: _formatDate(row['created_at'] as String),
      unread: row['unread'] as bool? ?? false,
    );
  }).toList();

  notifyListeners();
}
Future<void> _loadNotices() async {
    final data = await _client
        .from('notices')
        .select()
        .order('pinned', ascending: false)
        .order('created_at', ascending: false);

    notices = (data as List).map((row) {
      return NoticeItem(
        id: row['id'] as String,
        title: row['title'] as String,
        body: row['body'] as String,
        audience: row['audience'] as String,
        date: _formatDate(row['created_at'] as String),
        pinned: row['pinned'] as bool? ?? false,
      );
    }).toList();
    notifyListeners();
  }
Future<void> _loadHomework() async {
  final hwRows = await _client.from('homework').select().order('created_at', ascending: false);
  final subRows = await _client.from('homework_submissions').select();

  homework = (hwRows as List).map((row) {
    final subs = <String, String>{
      for (final s in (subRows as List).where((s) => s['homework_id'] == row['id']))
        s['student_id'] as String: s['status'] as String,
    };
    return HomeworkItem(
      id: row['id'] as String,
      title: row['title'] as String,
      className: row['class_name'] as String,
      subject: row['subject'] as String,
      dueDate: row['due_date'] as String,
      submissions: subs,
    );
  }).toList();
  notifyListeners();
}
  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate).toLocal();
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
  int _idCounter = 100;
  String _newId(String prefix) => '$prefix-${_idCounter++}';

  // -------------------------------------------------------------------
  // Navigation / chrome
  // -------------------------------------------------------------------
  int navIndex = 0;
  bool sidebarExpanded = true;
  String searchQuery = '';

  void setNavIndex(int i) {
    navIndex = i;
    notifyListeners();
  }

  void toggleSidebar() {
    sidebarExpanded = !sidebarExpanded;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Role-Based Access Control
  // -------------------------------------------------------------------
  // No live backend/auth yet, so the signed-in role is switchable from the
  // sidebar for demo purposes — everything downstream (nav visibility,
  // dashboard shown, approval rights) reacts to it live.
  UserRole currentRole = UserRole.teacher;
  String department = 'Mathematics Department';

  void setRole(UserRole role) {
    currentRole = role;
    // If the page currently open isn't visible to the new role, fall back
    // to the dashboard instead of leaving the shell on a blank/locked page.
    if (!navIndicesForRole(role).contains(navIndex)) {
      navIndex = kDashboardNavIndex;
    }
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Profile
  // -------------------------------------------------------------------
  String teacherName = 'Priya Sharma';
  String teacherRole = 'Mathematics Teacher';
  String teacherEmail = 'priya.sharma@edusmart.school';
  String teacherPhone = '+91 98765 43210';
  String teacherQualification = 'M.Sc. Mathematics, B.Ed.';
  bool notifyEmail = true;
  bool notifyPush = true;
  bool notifySms = false;

  void updateProfile({
    required String name,
    required String role,
    required String email,
    required String phone,
    required String qualification,
  }) {
    teacherName = name;
    teacherRole = role;
    teacherEmail = email;
    teacherPhone = phone;
    teacherQualification = qualification;
    notifyListeners();
  }

  void updateNotificationPrefs({bool? email, bool? push, bool? sms}) {
    if (email != null) notifyEmail = email;
    if (push != null) notifyPush = push;
    if (sms != null) notifySms = sms;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Students & Attendance
  // -------------------------------------------------------------------
  late List<StudentItem> students;

  List<String> get classNames =>
      students.map((s) => s.className).toSet().toList()..sort();

  List<StudentItem> studentsFiltered({String? className, String? query}) {
    final q = (query ?? '').trim().toLowerCase();
    return students.where((s) {
      final matchesClass =
          className == null ||
          className == 'All Classes' ||
          s.className == className;
      final matchesQuery =
          q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.className.toLowerCase().contains(q);
      return matchesClass && matchesQuery;
    }).toList();
  }

 Future<void> markAttendance(String studentId, AttendanceStatus status) async {
  final s = students.firstWhere((e) => e.id == studentId);
  s.attendanceToday = status;
  notifyListeners();

  await _client.from('attendance_records').upsert({
    'student_id': studentId,
    'session_date': DateTime.now().toIso8601String().split('T')[0],
    'status': status.name,
    'marked_by': _client.auth.currentUser?.id,
  }, onConflict: 'student_id,session_date');
}

Future<void> markAllAttendance(String className, AttendanceStatus status) async {
  final today = DateTime.now().toIso8601String().split('T')[0];
  final targeted = students.where((s) => className == 'All Classes' || s.className == className);

  for (final s in targeted) {
    s.attendanceToday = status;
  }
  notifyListeners();

  await _client.from('attendance_records').upsert([
    for (final s in targeted)
      {
        'student_id': s.id,
        'session_date': today,
        'status': status.name,
        'marked_by': _client.auth.currentUser?.id,
      }
  ], onConflict: 'student_id,session_date');
}

  void updateStudentScore(String studentId, int score) {
    final s = students.firstWhere((e) => e.id == studentId);
    s.score = score.clamp(0, 100).toInt();
    notifyListeners();
  }

  void addStudent(String name, String className) {
    students.add(
      StudentItem(
        id: _newId('s'),
        name: name,
        className: className,
        score: 0,
        avatarSeed: name,
      ),
    );
    notifyListeners();
  }

  int get presentCount => students
      .where((s) => s.attendanceToday == AttendanceStatus.present)
      .length;
  int get absentCount => students
      .where((s) => s.attendanceToday == AttendanceStatus.absent)
      .length;
  int get lateCount =>
      students.where((s) => s.attendanceToday == AttendanceStatus.late).length;

  // -------------------------------------------------------------------
  // Staff count (real headcount from the `teachers` table, used by the
  // Principal Dashboard's "Total Staff" KPI instead of a fudged number).
  // -------------------------------------------------------------------
  late int totalStaff;

  Future<void> _loadStaffCount() async {
    final rows = await _client.from('teachers').select('id');
    totalStaff = (rows as List).length;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Weekly attendance trend — last 7 days computed from the real
  // `attendance` table (same table markAttendance/markAllAttendance
  // write to), used by the dashboard's Attendance Overview card and the
  // Reports screen's Attendance Trend chart.
  // -------------------------------------------------------------------
  late List<String> weeklyAttendanceLabels;
  late List<double> weeklyAttendance;

  Future<void> _loadWeeklyAttendance() async {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 6));
    final startStr = start.toIso8601String().split('T')[0];
    final rows = await _client.from('attendance_records').select().gte('session_date', startStr);

    final byDate = <String, List<String>>{};
    for (final r in rows as List) {
      final d = r['session_date'] as String;
      byDate.putIfAbsent(d, () => []).add(r['status'] as String);
    }

    final labels = <String>[];
    final values = <double>[];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = day.toIso8601String().split('T')[0];
      labels.add(_weekdayShort[day.weekday - 1]);
      final statuses = byDate[key] ?? [];
      if (statuses.isEmpty) {
        values.add(0);
      } else {
        final presentOrLate = statuses.where((s) => s == 'present' || s == 'late').length;
        values.add(presentOrLate / statuses.length * 100);
      }
    }
    weeklyAttendanceLabels = labels;
    weeklyAttendance = values;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Dashboard action-tile menus — static UI config (icon/label per
  // tile), so no Supabase table backs these, but they're exposed here
  // (instead of screens importing DummyData directly) so AppState stays
  // the single source every screen reads from.
  // -------------------------------------------------------------------
  List<ActionTile> get teachingResources => DummyData.teachingResources;
  List<ActionTile> get quickActions => DummyData.quickActions;
  List<ActionTile> get otherTools => DummyData.otherTools;

  List<StudentItem> get topPerformers {
    final list = List<StudentItem>.from(students)
      ..sort((a, b) => b.score.compareTo(a.score));
    return list.take(5).toList();
  }

  List<StudentItem> get needsAttention {
    final list = List<StudentItem>.from(students)
      ..sort((a, b) => a.score.compareTo(b.score));
    return list.take(5).toList();
  }

  double get classAverageScore {
    if (students.isEmpty) return 0;
    return students.fold<int>(0, (a, s) => a + s.score) / students.length;
  }

  // -------------------------------------------------------------------
  // Assignments
  // -------------------------------------------------------------------
  late List<AssignmentItem> assignments;

  Future<void> addAssignment({
    required String title,
    required String className,
    required String dueDate,
    required int totalCount,
  }) async {
    const icons = [
      Icons.description_outlined,
      Icons.functions_outlined,
      Icons.calculate_outlined,
      Icons.menu_book_outlined,
    ];
    const palette = [
      [AppColors.purple, AppColors.purpleBg],
      [AppColors.blue, AppColors.blueBg],
      [AppColors.pink, AppColors.pinkBg],
      [AppColors.green, AppColors.greenBg],
    ];
    final i = assignments.length % palette.length;

    final inserted = await _client.from('assignments').insert({
      'title': title,
      'class_name': className,
      'due_date': dueDate,
      'pending_count': totalCount,
      'total_count': totalCount,
      'graded': false,
      'teacher_id': _client.auth.currentUser?.id,
    }).select().single();

    assignments.insert(
      0,
      AssignmentItem(
        id: inserted['id'] as String,
        icon: icons[i],
        color: palette[i][0],
        bgColor: palette[i][1],
        title: title,
        className: className,
        dueDate: dueDate,
        pendingCount: totalCount,
        totalCount: totalCount,
      ),
    );
    notifyListeners();
  }

    Future<void> setAssignmentPending(String id, int pending) async {
    final a = assignments.firstWhere((e) => e.id == id);
    a.pendingCount = pending.clamp(0, a.totalCount).toInt();
    a.graded = a.pendingCount == 0;
    notifyListeners();
    await _client.from('assignments').update({
      'pending_count': a.pendingCount,
      'graded': a.graded,
    }).eq('id', id);
  }

  Future<void> markAssignmentGraded(String id) async {
    final a = assignments.firstWhere((e) => e.id == id);
    a.pendingCount = 0;
    a.graded = true;
    notifyListeners();
    await _client.from('assignments').update({
      'pending_count': 0,
      'graded': true,
    }).eq('id', id);
  }

  Future<void> deleteAssignment(String id) async {
    assignments.removeWhere((e) => e.id == id);
    notifyListeners();
    await _client.from('assignments').delete().eq('id', id);
  }

  int get pendingAssignmentsCount => assignments.where((a) => !a.graded).length;

  // -------------------------------------------------------------------
  // Exams
  // -------------------------------------------------------------------
  late List<ExamItem> exams;

  Future<void> _loadExams() async {
    final rows = await _client.from('tp_exams').select().order('created_at', ascending: false);
    const icons = [
      Icons.assignment_turned_in_outlined,
      Icons.edit_note_outlined,
      Icons.fact_check_outlined,
      Icons.quiz_outlined,
    ];
    const palette = [
      [AppColors.purple, AppColors.purpleBg],
      [AppColors.blue, AppColors.blueBg],
      [AppColors.green, AppColors.greenBg],
      [AppColors.pink, AppColors.pinkBg],
    ];
    exams = (rows as List).asMap().entries.map((entry) {
      final i = entry.key % palette.length;
      final row = entry.value;
      return ExamItem(
        id: row['id'] as String,
        icon: icons[i],
        color: palette[i][0],
        bgColor: palette[i][1],
        title: row['title'] as String,
        className: row['class_name'] as String,
        subject: row['subject'] as String,
        date: row['date'] as String,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addExam({
    required String title,
    required String className,
    required String subject,
    required String date,
  }) async {
    await _client.from('tp_exams').insert({
      'title': title,
      'class_name': className,
      'subject': subject,
      'date': date,
    });
    await _loadExams();
  }

  Future<void> deleteExam(String id) async {
    exams.removeWhere((e) => e.id == id);
    notifyListeners();
    await _client.from('tp_exams').delete().eq('id', id);
  }

  // -------------------------------------------------------------------
  // Messages / Communication
  // -------------------------------------------------------------------
  late List<MessageItem> messages;

  Future<void> sendMessage({required String recipient, required String body}) async {
  final inserted = await _client.from('staff_messages').insert({
    'sender_id': _client.auth.currentUser?.id,
    'recipient': recipient,
    'body': body,
    'unread': true,
  }).select().single();

  messages.insert(
    0,
    MessageItem(
      id: inserted['id'] as String,
      icon: Icons.send_outlined,
      color: AppColors.blue,
      bgColor: AppColors.blueBg,
      title: 'Message to $recipient',
      meta: body,
      time: 'Just now',
    ),
  );
  notifyListeners();
}
Future<void> markMessageRead(String id) async {
  final m = messages.firstWhere((e) => e.id == id);
  if (m.unread) {
    m.unread = false;
    notifyListeners();
    await _client.from('staff_messages').update({'unread': false}).eq('id', id);
  }
}

  int get unreadMessagesCount => messages.where((m) => m.unread).length;

  // -------------------------------------------------------------------
  // Notifications
  // -------------------------------------------------------------------
  late List<NotificationItem> notifications;

  Future<void> _loadNotifications() async {
    final rows = await _client.from('tp_notifications').select().order('created_at', ascending: false);
    const icons = [
      Icons.assignment_turned_in_outlined,
      Icons.event_note_outlined,
      Icons.family_restroom_outlined,
      Icons.how_to_reg_outlined,
      Icons.campaign_outlined,
    ];
    const palette = [
      [AppColors.green, AppColors.greenBg],
      [AppColors.pink, AppColors.pinkBg],
      [AppColors.orange, AppColors.orangeBg],
      [AppColors.blue, AppColors.blueBg],
      [AppColors.teal, AppColors.tealBg],
    ];
    notifications = (rows as List).asMap().entries.map((entry) {
      final i = entry.key % palette.length;
      final row = entry.value;
      return NotificationItem(
        id: row['id'] as String,
        icon: icons[i],
        color: palette[i][0],
        bgColor: palette[i][1],
        title: row['title'] as String,
        subtitle: row['subtitle'] as String? ?? '',
        time: _formatDate(row['created_at'] as String),
        read: row['read'] as bool? ?? false,
      );
    }).toList();
    notifyListeners();
  }

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.read).length;

  Future<void> markNotificationRead(String id) async {
    final n = notifications.firstWhere((e) => e.id == id);
    if (!n.read) {
      n.read = true;
      notifyListeners();
      await _client.from('tp_notifications').update({'read': true}).eq('id', id);
    }
  }

  Future<void> markAllNotificationsRead() async {
    final unreadIds = notifications.where((n) => !n.read).map((n) => n.id).toList();
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
    if (unreadIds.isNotEmpty) {
      await _client.from('tp_notifications').update({'read': true}).inFilter('id', unreadIds);
    }
  }

  // -------------------------------------------------------------------
  // Staff Leave & Payroll — the teacher's own leave balance / history, and
  // an Approvals queue for whoever's role can sign off on them.
  // -------------------------------------------------------------------
  late List<LeaveRequest> leaveRequests;

  List<LeaveRequest> _seedLeaveRequests() {
    return [
      LeaveRequest(
        id: _newId('lv'),
        staffName: teacherName,
        leaveType: 'Sick',
        reason: 'Fever',
        date: '2 Jun 2026',
        toDate: '3 Jun 2026',
        days: 2,
        appliedOn: '30 May 2026',
        status: 'Approved',
        approverNote: 'Get well soon.',
      ),
      LeaveRequest(
        id: _newId('lv'),
        staffName: teacherName,
        leaveType: 'Casual',
        reason: 'Family function',
        date: '18 Jul 2026',
        toDate: '18 Jul 2026',
        days: 1,
        appliedOn: '10 Jul 2026',
        status: 'Approved',
      ),
      // A couple of other staff members' requests, so an HOD/Principal has
      // something real to review in the Approvals tab.
      LeaveRequest(
        id: _newId('lv'),
        staffName: 'Rohan Mehta',
        leaveType: 'Casual',
        reason: 'Personal work',
        date: '20 Aug 2026',
        toDate: '20 Aug 2026',
        days: 1,
        appliedOn: '15 Aug 2026',
        status: 'Pending',
      ),
      LeaveRequest(
        id: _newId('lv'),
        staffName: 'Kavita Nair',
        leaveType: 'Earned',
        reason: 'Family vacation',
        date: '2 Sep 2026',
        toDate: '6 Sep 2026',
        days: 5,
        appliedOn: '14 Aug 2026',
        status: 'Pending',
      ),
    ];
  }

  static const int casualLeaveTotal = 12;
  static const int sickLeaveTotal = 10;
  static const int earnedLeaveTotal = 15;

  List<LeaveRequest> get myLeaveRequests => leaveRequests
      .where((l) => l.staffName == teacherName || l.staffName.isEmpty)
      .toList();

  int _usedDays(String type) => myLeaveRequests
      .where((l) => l.leaveType == type && l.status == 'Approved')
      .fold(0, (a, l) => a + l.days);

  int get casualLeaveUsed => _usedDays('Casual');
  int get sickLeaveUsed => _usedDays('Sick');
  int get earnedLeaveUsed => _usedDays('Earned');

  Future<void> addLeaveRequest(
  String reason,
  String date, {
  String leaveType = 'Casual',
  String toDate = '',
  int days = 1,
}) async {
  final finalToDate = toDate.trim().isEmpty ? date : toDate;
  final finalDays = days < 1 ? 1 : days;

  final inserted = await _client.from('staff_leave_requests').insert({
    'staff_id': _client.auth.currentUser?.id,
    'staff_name': teacherName,
    'leave_type': leaveType,
    'reason': reason,
    'from_date': date,
    'to_date': finalToDate,
    'days': finalDays,
    'status': 'Pending',
  }).select().single();

  leaveRequests.insert(
    0,
    LeaveRequest(
      id: inserted['id'] as String,
      staffName: teacherName,
      leaveType: leaveType,
      reason: reason,
      date: date,
      toDate: finalToDate,
      days: finalDays,
      appliedOn: 'Just now',
    ),
  );
  notifyListeners();
}
  List<LeaveRequest> get pendingApprovals =>
      leaveRequests.where((l) => l.status == 'Pending').toList();

  Future<void> approveLeaveRequest(String id, {String note = ''}) async {
  final l = leaveRequests.firstWhere((e) => e.id == id);
  l.status = 'Approved';
  l.approverNote = note;
  notifyListeners();

  await _client.from('staff_leave_requests')
      .update({'status': 'Approved', 'approver_note': note})
      .eq('id', id);
}

Future<void> rejectLeaveRequest(String id, {String note = ''}) async {
  final l = leaveRequests.firstWhere((e) => e.id == id);
  l.status = 'Rejected';
  l.approverNote = note;
  notifyListeners();

  await _client.from('staff_leave_requests')
      .update({'status': 'Rejected', 'approver_note': note})
      .eq('id', id);
}

  // -------------------------------------------------------------------
  // Role-Based Access Control — a Principal/Vice Principal-raised queue of
  // "please change this staff member's role" requests. This is a review &
  // approval workflow only: approving a request here just records a
  // decision, it does not itself flip anyone's UserRole in the app.
  // -------------------------------------------------------------------
  late List<AccessRequest> accessRequests;

  List<AccessRequest> _seedAccessRequests() {
    return [
      AccessRequest(
        id: _newId('rbac'),
        staffName: 'Rohan Mehta',
        currentRole: 'Teacher',
        requestedRole: 'HOD',
        reason: 'Taking over as Science department coordinator this term.',
        raisedBy: teacherName,
        raisedByRole: 'Principal',
        appliedOn: '12 Aug 2026',
        status: 'Pending',
      ),
      AccessRequest(
        id: _newId('rbac'),
        staffName: 'Kavita Nair',
        currentRole: 'Teacher',
        requestedRole: 'Admin',
        reason: 'Needs document-vault verification rights during audit week.',
        raisedBy: teacherName,
        raisedByRole: 'Principal',
        appliedOn: '8 Aug 2026',
        status: 'Approved',
        reviewerNote: 'Approved for audit week only.',
      ),
      AccessRequest(
        id: _newId('rbac'),
        staffName: 'Suresh Iyer',
        currentRole: 'HOD',
        requestedRole: 'Admin',
        reason: 'Requested full admin access for the exams portal.',
        raisedBy: 'Meera Rao',
        raisedByRole: 'Vice Principal',
        appliedOn: '2 Aug 2026',
        status: 'Rejected',
        reviewerNote: 'Scope too broad — HOD access is sufficient for now.',
      ),
    ];
  }

  List<AccessRequest> get pendingAccessRequests =>
      accessRequests.where((r) => r.status == 'Pending').toList();

  void submitAccessRequest({
    required String staffName,
    required String currentRole,
    required String requestedRole,
    required String reason,
    String raisedBy = '',
    String raisedByRole = 'Principal',
  }) {
    accessRequests.insert(
      0,
      AccessRequest(
        id: _newId('rbac'),
        staffName: staffName,
        currentRole: currentRole,
        requestedRole: requestedRole,
        reason: reason,
        raisedBy: raisedBy.trim().isEmpty ? teacherName : raisedBy,
        raisedByRole: raisedByRole,
        appliedOn: 'Just now',
      ),
    );
    notifyListeners();
  }

  void approveAccessRequest(String id, {String note = ''}) {
    final r = accessRequests.firstWhere((e) => e.id == id);
    r.status = 'Approved';
    r.reviewerNote = note;
    notifyListeners();
  }

  void rejectAccessRequest(String id, {String note = ''}) {
    final r = accessRequests.firstWhere((e) => e.id == id);
    r.status = 'Rejected';
    r.reviewerNote = note;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Payroll — salary slips, one per month, viewable/"downloadable" by the
  // teacher who owns them.
  // -------------------------------------------------------------------
  late List<PayslipItem> payslips;

  List<PayslipItem> _seedPayslips() {
    const months = ['March', 'April', 'May', 'June', 'July', 'August'];
    final list = <PayslipItem>[];
    for (int i = 0; i < months.length; i++) {
      list.add(
        PayslipItem(
          id: _newId('ps'),
          staffName: teacherName,
          month: months[i],
          year: '2026',
          basic: 42000,
          hra: 12600,
          allowances: 4500 + (i % 3) * 500,
          providentFund: 5040,
          tax: 3200,
          otherDeductions: i == 2 ? 500 : 0,
          status: i == months.length - 1 ? 'Processing' : 'Paid',
        ),
      );
    }
    return list.reversed.toList();
  }

  double get lastNetPay => payslips.isEmpty ? 0 : payslips.first.netPay;

  // -------------------------------------------------------------------
  // Teaching resources / question bank / library / lesson plans
  // -------------------------------------------------------------------
  late List<ResourceItem> studyMaterials;
  late List<ResourceItem> questionBank;
  late List<ResourceItem> library;
  late List<LessonPlanItem> lessonPlans;

  Future<void> _loadResources() async {
    final rows = await _client.from('tp_resources').select().order('created_at', ascending: false);
    ResourceItem toItem(Map<String, dynamic> row, IconData icon, Color color, Color bg) => ResourceItem(
          id: row['id'] as String,
          icon: icon,
          color: color,
          bgColor: bg,
          title: row['title'] as String,
          subtitle: row['subtitle'] as String? ?? '',
        );
    studyMaterials = (rows as List)
        .where((r) => r['category'] == 'study_material')
        .map((r) => toItem(r, Icons.insert_drive_file_outlined, AppColors.blue, AppColors.blueBg))
        .toList();
    questionBank = rows
        .where((r) => r['category'] == 'question_bank')
        .map((r) => toItem(r, Icons.quiz_outlined, AppColors.purple, AppColors.purpleBg))
        .toList();
    library = rows
        .where((r) => r['category'] == 'library')
        .map((r) => toItem(r, Icons.menu_book_outlined, AppColors.teal, AppColors.tealBg))
        .toList();
    notifyListeners();
  }

  Future<void> addStudyMaterial(String title, String subtitle) async {
    await _client.from('tp_resources').insert({'category': 'study_material', 'title': title, 'subtitle': subtitle});
    await _loadResources();
  }

  Future<void> addQuestionBankEntry(String title, String subtitle) async {
    await _client.from('tp_resources').insert({'category': 'question_bank', 'title': title, 'subtitle': subtitle});
    await _loadResources();
  }

  Future<void> addLessonPlan(String title, String className, String date) async {
    await _client.from('tp_lesson_plans').insert({'title': title, 'class_name': className, 'date': date});
    await _loadLessonPlans();
  }

  Future<void> _loadLessonPlans() async {
    final rows = await _client.from('tp_lesson_plans').select().order('created_at', ascending: false);
    lessonPlans = (rows as List)
        .map((row) => LessonPlanItem(
              id: row['id'] as String,
              title: row['title'] as String,
              className: row['class_name'] as String,
              date: row['date'] as String,
            ))
        .toList();
    notifyListeners();
  }

 // -------------------------------------------------------------------
// Timetable
// -------------------------------------------------------------------
late Map<String, List<ScheduleItem>> timetableData;

Map<String, List<ScheduleItem>> get weekTimetable => timetableData;

Future<void> _loadStudents() async {
  final rows = await _client
      .from('students')
      .select()
      .order('full_name');

  students = (rows as List).map((row) {
    return StudentItem(
      id: row['id'] as String,
      name: row['full_name'] as String,
      className: 'Class ${row['class_num']}-${row['section']}',
      score: 0, // abhi exam module wire nahi hua, so placeholder
      avatarSeed: row['full_name'] as String,
      email: (row['email'] as String?) ?? '',
      phone: (row['contact_phone'] as String?) ?? '',
    );
  }).toList();

  notifyListeners();
}
Future<void> _loadPayslips() async {
  final rows = await _client
      .from('payslips')
      .select()
      .eq('staff_name', teacherName)
      .order('created_at', ascending: false);

  payslips = (rows as List).map((row) {
    return PayslipItem(
      id: row['id'] as String,
      staffName: row['staff_name'] as String,
      month: row['month'] as String,
      year: row['year'] as String,
      basic: (row['basic'] as num).toDouble(),
      hra: (row['hra'] as num).toDouble(),
      allowances: (row['allowances'] as num).toDouble(),
      providentFund: (row['provident_fund'] as num).toDouble(),
      tax: (row['tax'] as num).toDouble(),
      otherDeductions: (row['other_deductions'] as num?)?.toDouble() ?? 0,
      status: row['status'] as String,
    );
  }).toList();

  notifyListeners();
}
Future<void> _loadDocuments() async {
  final rows = await _client
      .from('documents')
      .select()
      .order('uploaded_on', ascending: false);

  studentDocuments = (rows as List).map((row) {
    return DocumentItem(
      id: row['id'] as String,
      studentId: (row['student_id'] as String?) ?? '',
      type: row['type'] as String,
      fileName: row['file_name'] as String,
      uploadedOn: row['uploaded_on'] != null
          ? _formatDate(row['uploaded_on'] as String)
          : 'Just now',
           status: (row['status'] as String?) ?? 'Pending Verification',
      fileUrl: row['file_url'] as String?,
    );
  }).toList();

  notifyListeners();
}
Future<void> _loadLeaveRequests() async {
  final rows = await _client
      .from('staff_leave_requests')
      .select()
      .order('applied_on', ascending: false);

  leaveRequests = (rows as List).map((row) {
    return LeaveRequest(
      id: row['id'] as String,
      staffName: row['staff_name'] as String,
      leaveType: row['leave_type'] as String,
      reason: row['reason'] as String,
      date: row['from_date'] as String,
      toDate: row['to_date'] as String,
      days: row['days'] as int,
      appliedOn: _formatDate(row['applied_on'] as String),
      status: row['status'] as String,
      approverNote: (row['approver_note'] as String?) ?? '',
    );
  }).toList();

  notifyListeners();
}
Future<void> _loadGradebook() async {
  final rows = await _client.from('assessment_records').select();

  final grouped = <String, List<AssessmentRecord>>{};
  for (final row in rows as List) {
    final studentId = row['student_id'] as String;
    grouped.putIfAbsent(studentId, () => []);
    grouped[studentId]!.add(AssessmentRecord(
      id: row['id'] as String,
      title: row['title'] as String,
      category: row['category'] as String,
      maxMarks: (row['max_marks'] as num).toDouble(),
      obtained: (row['obtained'] as num).toDouble(),
      date: row['date'] as String,
    ));
  }

  gradebook = grouped;
  notifyListeners();
}
Future<void> _loadAttendanceToday() async {
  final today = DateTime.now().toIso8601String().split('T')[0];
  final rows = await _client
      .from('attendance_records')
      .select()
      .eq('session_date', today);

  final statusMap = {
    for (final r in rows as List)
      r['student_id'] as String: r['status'] as String,
  };

  for (final s in students) {
    final st = statusMap[s.id];
    if (st != null) {
      s.attendanceToday = AttendanceStatus.values.firstWhere((e) => e.name == st);
    }
  }
  notifyListeners();
}

Future<void> _loadTimetable() async {
  final rows = await _client
      .from('class_timetable')
      .select()
      .order('day')
      .order('period_order');

  final grouped = {for (final d in _weekdayShort) d: <ScheduleItem>[]};

  for (final row in rows as List) {
    final day = row['day'] as String;
    grouped[day]?.add(ScheduleItem(
      time: row['time'] as String,
      className: row['class_name'] as String,
      subject: row['subject'] as String,
      room: (row['room'] as String?) ?? '',
      status: _computeTimetableStatus(day, row['time'] as String),
    ));
  }

  timetableData = grouped;
  notifyListeners();
}

ScheduleStatus _computeTimetableStatus(String day, String timeStr) {
  if (day != todayLabel) return ScheduleStatus.upcoming;
  final now = DateTime.now();
  final parsed = _parseTimetableTime(timeStr);
  if (parsed == null) return ScheduleStatus.upcoming;
  final slot =
      DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
  final diff = now.difference(slot).inMinutes;
  if (diff >= 60) return ScheduleStatus.completed;
  if (diff >= 0) return ScheduleStatus.ongoing;
  return ScheduleStatus.upcoming;
}

DateTime? _parseTimetableTime(String timeStr) {
  // parses "08:00 AM" / "01:30 PM"
  final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false)
      .firstMatch(timeStr);
  if (match == null) return null;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final period = match.group(3)!.toUpperCase();
  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;
  return DateTime(0, 1, 1, hour, minute);
}

static const List<String> _weekdayShort = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

  String get todayLabel => _weekdayShort[DateTime.now().weekday - 1];

  List<ScheduleItem> get todaySchedule =>
      weekTimetable[todayLabel] ?? weekTimetable['Mon'] ?? const [];

  List<ClassSlice> get classSlices {
    const palette = [AppColors.primary, AppColors.blue, AppColors.green, AppColors.orange, AppColors.purple, AppColors.pink];
    final byClass = <String, int>{};
    for (final s in students) {
      byClass[s.className] = (byClass[s.className] ?? 0) + 1;
    }
    final names = byClass.keys.toList()..sort();
    return [
      for (var i = 0; i < names.length; i++)
        ClassSlice(name: names[i], students: byClass[names[i]]!, color: palette[i % palette.length]),
    ];
  }

  // -------------------------------------------------------------------
  // Live dashboard stats / analytics (derived from real state)
  // -------------------------------------------------------------------
  List<StatItem> get stats {
    final attendancePct = students.isEmpty
        ? 0
        : ((presentCount + lateCount) / students.length * 100).round();
    return [
      StatItem(
        icon: Icons.school_outlined,
        value: '${classSlices.length}',
        label: 'My Classes',
        sub: 'Active Classes',
        color: AppColors.purple,
        bgColor: AppColors.purpleBg,
      ),
      StatItem(
        icon: Icons.groups_outlined,
        value: '${students.length}',
        label: 'Total Students',
        sub: 'Across all classes',
        color: AppColors.blue,
        bgColor: AppColors.blueBg,
      ),
      StatItem(
        icon: Icons.how_to_reg_outlined,
        value: '$attendancePct%',
        label: "Today's Attendance",
        sub: '${presentCount + lateCount} / ${students.length} Present',
        color: AppColors.green,
        bgColor: AppColors.greenBg,
      ),
      StatItem(
        icon: Icons.assignment_outlined,
        value: '$pendingAssignmentsCount',
        label: 'Pending Assignments',
        sub: 'Needs Grading',
        color: AppColors.orange,
        bgColor: AppColors.orangeBg,
      ),
      StatItem(
        icon: Icons.event_note_outlined,
        value: '${exams.length}',
        label: 'Upcoming Exams',
        sub: 'This Term',
        color: AppColors.pink,
        bgColor: AppColors.pinkBg,
      ),
      StatItem(
        icon: Icons.menu_book_outlined,
        value: '${todaySchedule.length}',
        label: "Today's Lessons",
        sub: 'Scheduled',
        color: AppColors.teal,
        bgColor: AppColors.tealBg,
      ),
      StatItem(
        icon: Icons.forum_outlined,
        value: '$unreadMessagesCount',
        label: 'Unread Messages',
        sub: 'New',
        color: const Color(0xFFC98A0A),
        bgColor: AppColors.yellowBg,
      ),
    ];
  }

  List<AnalyticsItem> get analytics => [
    AnalyticsItem(
      icon: Icons.groups_2_outlined,
      color: AppColors.purple,
      bgColor: AppColors.purpleBg,
      value: '${classSlices.length}',
      label: 'Classes Handled',
    ),
    AnalyticsItem(
      icon: Icons.groups_outlined,
      color: AppColors.blue,
      bgColor: AppColors.blueBg,
      value: '${students.length}',
      label: 'Students Taught',
    ),
    AnalyticsItem(
      icon: Icons.fact_check_outlined,
      color: AppColors.green,
      bgColor: AppColors.greenBg,
      value: '${weekTimetable.values.fold<int>(0, (a, l) => a + l.length)}',
      label: 'Lessons / Week',
    ),
    AnalyticsItem(
      icon: Icons.assignment_outlined,
      color: AppColors.orange,
      bgColor: AppColors.orangeBg,
      value: '${assignments.length}',
      label: 'Assignments Given',
    ),
    AnalyticsItem(
      icon: Icons.event_note_outlined,
      color: AppColors.pink,
      bgColor: AppColors.pinkBg,
      value: '${exams.length}',
      label: 'Exams Conducted',
    ),
  ];

  // -------------------------------------------------------------------
  // Gradebook & Report Cards
  // -------------------------------------------------------------------
  late Map<String, List<AssessmentRecord>> gradebook;

  List<AssessmentRecord> recordsFor(String studentId) =>
      gradebook[studentId] ?? const [];

  Future<void> addAssessment({
  required String studentId,
  required String title,
  required String category,
  required double maxMarks,
  required double obtained,
  required String date,
}) async {
  final inserted = await _client.from('assessment_records').insert({
    'student_id': studentId,
    'title': title,
    'category': category,
    'max_marks': maxMarks,
    'obtained': obtained.clamp(0, maxMarks).toDouble(),
    'date': date,
  }).select().single();

  gradebook.putIfAbsent(studentId, () => []);
  gradebook[studentId]!.insert(
    0,
    AssessmentRecord(
      id: inserted['id'] as String,
      title: title,
      category: category,
      maxMarks: maxMarks,
      obtained: obtained.clamp(0, maxMarks).toDouble(),
      date: date,
    ),
  );
  notifyListeners();
}

Future<void> deleteAssessment(String studentId, String recordId) async {
  await _client.from('assessment_records').delete().eq('id', recordId);
  gradebook[studentId]?.removeWhere((r) => r.id == recordId);
  notifyListeners();
}

  double overallPercent(String studentId) {
    final list = recordsFor(studentId);
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (a, r) => a + r.percent);
    return total / list.length;
  }

  String letterGrade(double percent) {
    if (percent >= 90) return 'A+';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B+';
    if (percent >= 60) return 'B';
    if (percent >= 50) return 'C';
    if (percent >= 40) return 'D';
    return 'F';
  }

  double gradebookClassAverage(String className) {
    final list = studentsFiltered(className: className);
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (a, s) => a + overallPercent(s.id));
    return total / list.length;
  }

  /// Synthetic last-5-weeks trend + this week's live computed average, so
  /// the Gradebook trend chart has something meaningful to plot.
  List<double> classAverageTrend(String className) {
    final seed = [68.0, 71.0, 73.0, 75.0, 77.0];
    return [...seed, gradebookClassAverage(className)];
  }

  // -------------------------------------------------------------------
  // Syllabus / curriculum tracker
  // -------------------------------------------------------------------
  late List<SyllabusChapter> syllabus;

  Future<void> _loadSyllabus() async {
    final rows = await _client.from('tp_syllabus_chapters').select().order('created_at');
    syllabus = (rows as List)
        .map((row) => SyllabusChapter(
              id: row['id'] as String,
              className: row['class_name'] as String,
              subject: row['subject'] as String,
              title: row['title'] as String,
              totalTopics: row['total_topics'] as int,
              completedTopics: row['completed_topics'] as int? ?? 0,
            ))
        .toList();
    notifyListeners();
  }

  List<SyllabusChapter> syllabusFor(String className) =>
      syllabus.where((c) => c.className == className).toList();

  double syllabusProgressFor(String className) {
    final list = syllabusFor(className);
    if (list.isEmpty) return 0;
    final total = list.fold<double>(0, (a, c) => a + c.progress);
    return total / list.length;
  }

  Future<void> addSyllabusChapter({
    required String className,
    required String subject,
    required String title,
    required int totalTopics,
  }) async {
    await _client.from('tp_syllabus_chapters').insert({
      'class_name': className,
      'subject': subject,
      'title': title,
      'total_topics': totalTopics,
      'completed_topics': 0,
    });
    await _loadSyllabus();
  }

  Future<void> updateSyllabusProgress(String id, int completed) async {
    final c = syllabus.firstWhere((e) => e.id == id);
    final clamped = completed.clamp(0, c.totalTopics).toInt();
    c.completedTopics = clamped;
    notifyListeners();
    await _client.from('tp_syllabus_chapters').update({'completed_topics': clamped}).eq('id', id);
  }

  Future<void> deleteSyllabusChapter(String id) async {
    syllabus.removeWhere((e) => e.id == id);
    notifyListeners();
    await _client.from('tp_syllabus_chapters').delete().eq('id', id);
  }

  // -------------------------------------------------------------------
  // Seating chart
  // -------------------------------------------------------------------
  static const int seatRows = 5;
  static const int seatCols = 6;
  final Map<String, List<String?>> _seating = {};

  List<String?> seatsForClass(String className) {
    return _seating.putIfAbsent(
      className,
      () => List<String?>.filled(seatRows * seatCols, null),
    );
  }

  void assignSeat(String className, int seatIndex, String studentId) {
    final seats = seatsForClass(className);
    for (int i = 0; i < seats.length; i++) {
      if (seats[i] == studentId) seats[i] = null;
    }
    seats[seatIndex] = studentId;
    notifyListeners();
  }

  void clearSeat(String className, int seatIndex) {
    seatsForClass(className)[seatIndex] = null;
    notifyListeners();
  }

  void autoArrangeSeats(String className) {
    final classStudents = studentsFiltered(className: className)
      ..sort((a, b) => a.name.compareTo(b.name));
    final seats = List<String?>.filled(seatRows * seatCols, null);
    for (int i = 0; i < classStudents.length && i < seats.length; i++) {
      seats[i] = classStudents[i].id;
    }
    _seating[className] = seats;
    notifyListeners();
  }

  StudentItem? studentById(String id) {
    for (final s in students) {
      if (s.id == id) return s;
    }
    return null;
  }

  // -------------------------------------------------------------------
  // Per-Student Analytics Report (Class-Wide Analytics & Report Builder)
  // — PTM-ready, print-friendly A4 report for one student at a time.
  // -------------------------------------------------------------------
  final Map<String, String> _studentRemarks = {};

  String remarkFor(String studentId) => _studentRemarks[studentId] ?? '';

  void setStudentRemark(String studentId, String note) {
    _studentRemarks[studentId] = note;
    notifyListeners();
  }

  /// The app only tracks *today's* live attendance status per student (no
  /// day-by-day log), so this derives a stable term-to-date % from the
  /// school-wide trend, nudged per-student so every student isn't
  /// identical on the printed report.
  double studentAttendancePercent(String studentId) {
    final wobble = (studentId.hashCode % 11) - 5; // -5..+5, stable per id
    return (schoolAttendancePercent + wobble).clamp(60, 100).toDouble();
  }

  /// Plain-text version of a student's report — used by the "Export" /
  /// "Copy for Print" action, mirroring buildReportCsv's approach for the
  /// class-wide report below.
  String buildStudentReportText(String studentId) {
    final s = studentById(studentId);
    if (s == null) return '';
    final records = recordsFor(studentId);
    final buffer = StringBuffer();
    buffer.writeln('EduSmart School — Student Analytics Report');
    buffer.writeln('Student: ${s.name}   Class: ${s.className}   ID: ${s.id}');
    buffer.writeln(
      'Attendance (term-to-date): ${studentAttendancePercent(studentId).toStringAsFixed(0)}%   Today: ${s.attendanceToday.label}',
    );
    buffer.writeln(
      'Overall Academic Performance: ${overallPercent(studentId).toStringAsFixed(1)}%  (Grade ${letterGrade(overallPercent(studentId))})',
    );
    buffer.writeln(
      'Class Average: ${gradebookClassAverage(s.className).toStringAsFixed(1)}%',
    );
    buffer.writeln();
    buffer.writeln('Assessment,Category,Date,Marks,Percent');
    for (final r in records) {
      buffer.writeln(
        '${r.title},${r.category},${r.date},${r.obtained.toStringAsFixed(0)}/${r.maxMarks.toStringAsFixed(0)},${r.percent.toStringAsFixed(1)}%',
      );
    }
    final fee = feeRecords.where((f) => f.studentId == studentId).toList();
    if (fee.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(
        'Fee Status: ${fee.first.status}   Due: ${fee.first.dueDate}   Amount: ₹${fee.first.amount.toStringAsFixed(0)}',
      );
    }
    final remark = remarkFor(studentId);
    if (remark.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Teacher\'s Remarks: $remark');
    }
    return buffer.toString();
  }

  // -------------------------------------------------------------------
  // Substitute teacher handoff note
  // -------------------------------------------------------------------
  String substituteInstructions = '';

  void updateSubstituteInstructions(String text) {
    substituteInstructions = text;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Parent-Teacher Meeting scheduler
  // -------------------------------------------------------------------
  late List<PTMSlot> ptmSlots;

  Future<void> _loadPtmSlots() async {
    final rows = await _client.from('tp_ptm_slots').select().order('date').order('time');
    ptmSlots = (rows as List)
        .map((row) => PTMSlot(
              id: row['id'] as String,
              date: row['date'] as String,
              time: row['time'] as String,
              parentName: row['parent_name'] as String?,
              studentName: row['student_name'] as String?,
            ))
        .toList();
    notifyListeners();
  }

  Future<void> addPtmSlot(String date, String time) async {
    await _client.from('tp_ptm_slots').insert({'date': date, 'time': time});
    await _loadPtmSlots();
  }

  Future<void> bookPtmSlot(
    String id, {
    required String parentName,
    required String studentName,
  }) async {
    final slot = ptmSlots.firstWhere((s) => s.id == id);
    slot.parentName = parentName;
    slot.studentName = studentName;
    notifyListeners();
    await _client.from('tp_ptm_slots').update({'parent_name': parentName, 'student_name': studentName}).eq('id', id);
  }

  Future<void> cancelPtmSlot(String id) async {
    final slot = ptmSlots.firstWhere((s) => s.id == id);
    slot.parentName = null;
    slot.studentName = null;
    notifyListeners();
    await _client.from('tp_ptm_slots').update({'parent_name': null, 'student_name': null}).eq('id', id);
  }

  Future<void> deletePtmSlot(String id) async {
    ptmSlots.removeWhere((s) => s.id == id);
    notifyListeners();
    await _client.from('tp_ptm_slots').delete().eq('id', id);
  }

  // -------------------------------------------------------------------
  // Behavior / conduct log
  // -------------------------------------------------------------------
  final List<BehaviorNote> behaviorNotes = [];

  List<BehaviorNote> notesForStudent(String studentId) =>
      behaviorNotes.where((n) => n.studentId == studentId).toList();

  void addBehaviorNote({
    required String studentId,
    required String type,
    required String note,
    required String date,
  }) {
    behaviorNotes.insert(
      0,
      BehaviorNote(
        id: _newId('bn'),
        studentId: studentId,
        type: type,
        note: note,
        date: date,
      ),
    );
    notifyListeners();
  }

  void deleteBehaviorNote(String id) {
    behaviorNotes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Teacher's personal to-do list
  // -------------------------------------------------------------------
  late List<TodoItem> todos;

  Future<void> _loadTodos() async {
    final rows = await _client.from('tp_todos').select().order('created_at', ascending: false);
    todos = (rows as List)
        .map((row) => TodoItem(
              id: row['id'] as String,
              title: row['title'] as String,
              done: row['done'] as bool? ?? false,
            ))
        .toList();
    notifyListeners();
  }

  Future<void> addTodo(String title) async {
    await _client.from('tp_todos').insert({'title': title, 'done': false});
    await _loadTodos();
  }

  Future<void> toggleTodo(String id) async {
    final t = todos.firstWhere((e) => e.id == id);
    t.done = !t.done;
    notifyListeners();
    await _client.from('tp_todos').update({'done': t.done}).eq('id', id);
  }

  Future<void> deleteTodo(String id) async {
    todos.removeWhere((e) => e.id == id);
    notifyListeners();
    await _client.from('tp_todos').delete().eq('id', id);
  }

  // -------------------------------------------------------------------
  // Homework / Assignment Submission Tracking
  // -------------------------------------------------------------------
  late List<HomeworkItem> homework;

  List<HomeworkItem> _seedHomework() {
    final samples = [
      ('Algebra Practice Set', 'Mathematics'),
      ('Reading Comprehension Worksheet', 'English'),
    ];
    final classes = classNames;
    final list = <HomeworkItem>[];
    for (int i = 0; i < samples.length && i < classes.length; i++) {
      final cls = classes[i];
      final ids = studentsFiltered(className: cls).map((s) => s.id).toList();
      final subs = <String, String>{};
      for (int j = 0; j < ids.length; j++) {
        subs[ids[j]] = j % 3 == 0
            ? 'Submitted'
            : (j % 5 == 0 ? 'Late' : 'Pending');
      }
      list.add(
        HomeworkItem(
          id: _newId('hw'),
          title: samples[i].$1,
          className: cls,
          subject: samples[i].$2,
          dueDate: 'This Friday',
          submissions: subs,
        ),
      );
    }
    return list;
  }

  Future<void> addHomework({
  required String title,
  required String className,
  required String subject,
  required String dueDate,
}) async {
  final inserted = await _client.from('homework').insert({
    'title': title,
    'class_name': className,
    'subject': subject,
    'due_date': dueDate,
  }).select().single();

  final ids = studentsFiltered(className: className).map((s) => s.id).toList();
  final subs = {for (final id in ids) id: 'Pending'};

  await _client.from('homework_submissions').insert([
    for (final id in ids) {'homework_id': inserted['id'], 'student_id': id, 'status': 'Pending'}
  ]);

  homework.insert(0, HomeworkItem(
    id: inserted['id'] as String,
    title: title,
    className: className,
    subject: subject,
    dueDate: dueDate,
    submissions: subs,
  ));
  notifyListeners();
}

  void setSubmissionStatus(String homeworkId, String studentId, String status) {
    final hw = homework.firstWhere((h) => h.id == homeworkId);
    hw.submissions[studentId] = status;
    notifyListeners();
  }

  Future<void> cycleSubmissionStatus(String homeworkId, String studentId) async {
  const order = ['Pending', 'Submitted', 'Reviewed', 'Late'];
  final hw = homework.firstWhere((h) => h.id == homeworkId);
  final current = hw.submissions[studentId] ?? 'Pending';
  final next = order[(order.indexOf(current) + 1) % order.length];
  hw.submissions[studentId] = next;
  notifyListeners();

  await _client.from('homework_submissions')
      .update({'status': next, 'updated_at': DateTime.now().toIso8601String()})
      .eq('homework_id', homeworkId)
      .eq('student_id', studentId);
}

  Future<void> deleteHomework(String id) async {
  await _client.from('homework').delete().eq('id', id);
  homework.removeWhere((h) => h.id == id);
  notifyListeners();
}

  int get pendingSubmissionsCount =>
      homework.fold(0, (a, h) => a + h.pendingCount);
  int get totalSubmissionsExpected =>
      homework.fold(0, (a, h) => a + h.totalCount);
  int get totalSubmissionsReceived =>
      homework.fold(0, (a, h) => a + h.submittedCount);

  // -------------------------------------------------------------------
  // Online Class / Video Meeting Integration
  // -------------------------------------------------------------------
  late List<OnlineClassItem> onlineClasses;

  List<OnlineClassItem> _seedOnlineClasses() {
    final classes = classNames;
    final data = [
      ('Live Doubt-Clearing Session', 'Mathematics', 'Google Meet', '4:00 PM'),
      ('Revision Class', 'Science', 'Zoom', '5:30 PM'),
      ('Parent Orientation', 'General', 'MS Teams', '6:00 PM'),
    ];
    final list = <OnlineClassItem>[];
    for (int i = 0; i < data.length; i++) {
      final cls = classes.isNotEmpty
          ? classes[i % classes.length]
          : 'All Classes';
      list.add(
        OnlineClassItem(
          id: _newId('oc'),
          title: data[i].$1,
          className: cls,
          subject: data[i].$2,
          date: 'This Week',
          time: data[i].$4,
          platform: data[i].$3,
          link: _generateMeetingLink(data[i].$3),
        ),
      );
    }
    return list;
  }

  String _generateMeetingLink(String platform) {
    final code = (100000 + (_idCounter * 733) % 900000).toString();
    if (platform.toLowerCase().contains('meet'))
      return 'https://meet.google.com/edu-$code';
    if (platform.toLowerCase().contains('teams'))
      return 'https://teams.live.com/meet/$code';
    return 'https://zoom.us/j/$code';
  }

  void addOnlineClass({
    required String title,
    required String className,
    required String subject,
    required String date,
    required String time,
    required String platform,
  }) {
    onlineClasses.insert(
      0,
      OnlineClassItem(
        id: _newId('oc'),
        title: title,
        className: className,
        subject: subject,
        date: date,
        time: time,
        platform: platform,
        link: _generateMeetingLink(platform),
      ),
    );
    notifyListeners();
  }

  void deleteOnlineClass(String id) {
    onlineClasses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  int get upcomingOnlineClassesCount => onlineClasses.length;

  // -------------------------------------------------------------------
  // Fee / Dues Status
  // -------------------------------------------------------------------
  late List<FeeRecord> feeRecords;

  List<FeeRecord> _seedFeeRecords() {
    const statuses = ['Paid', 'Pending', 'Overdue'];
    const months = ['May', 'Jun', 'Jul'];
    final list = <FeeRecord>[];
    for (int i = 0; i < students.length; i++) {
      list.add(
        FeeRecord(
          studentId: students[i].id,
          amount: 4500 + (i % 4) * 500,
          dueDate: '5 ${months[i % months.length]} 2026',
          status: statuses[i % statuses.length],
        ),
      );
    }
    return list;
  }

  FeeRecord? feeRecordFor(String studentId) {
    for (final f in feeRecords) {
      if (f.studentId == studentId) return f;
    }
    return null;
  }

  void markFeePaid(String studentId) {
    final f = feeRecordFor(studentId);
    if (f != null) {
      f.status = 'Paid';
      notifyListeners();
    }
  }

  void sendFeeReminder(String studentId) {
    final s = studentById(studentId);
    if (s != null) {
      sendMessage(
        recipient: '${s.name} (Parent)',
        body:
            'Reminder: School fee payment is pending. Please clear the dues at the earliest.',
      );
    }
  }

  List<FeeRecord> get pendingFeeRecords =>
      feeRecords.where((f) => f.status != 'Paid').toList();
  int get pendingFeesCount => pendingFeeRecords.length;
  double get totalPendingFeeAmount =>
      pendingFeeRecords.fold(0.0, (a, f) => a + f.amount);

  // -------------------------------------------------------------------
  // Notice Board / Announcement Broadcast
  // -------------------------------------------------------------------
  late List<NoticeItem> notices;

  Future<void> postNotice({required String title, required String body, required String audience}) async {
    final inserted = await _client.from('notices').insert({
      'title': title,
      'body': body,
      'audience': audience,
      'pinned': false,
    }).select().single();

    notices.insert(0, NoticeItem(
      id: inserted['id'] as String,
      title: title,
      body: body,
      audience: audience,
      date: 'Just now',
    ));
    sendMessage(recipient: audience, body: '[Notice] $title — $body');
    notifyListeners();
  }

  Future<void> togglePinNotice(String id) async {
    final n = notices.firstWhere((e) => e.id == id);
    n.pinned = !n.pinned;
    await _client.from('notices').update({'pinned': n.pinned}).eq('id', id);
    notifyListeners();
  }

  Future<void> deleteNotice(String id) async {
    await _client.from('notices').delete().eq('id', id);
    notices.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  List<NoticeItem> get sortedNotices {
    final list = List<NoticeItem>.from(notices);
    list.sort((a, b) => (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0));
    return list;
  }

  // -------------------------------------------------------------------
  // Academic Calendar (Holidays + Events + Exam Dates, merged live)
  // -------------------------------------------------------------------
  late List<CalendarEventItem> calendarEvents;

  List<CalendarEventItem> _seedCalendarEvents() {
    return [
      CalendarEventItem(
        id: _newId('cal'),
        title: 'Annual Sports Day',
        date: '20 May 2026',
        type: 'Event',
      ),
      CalendarEventItem(
        id: _newId('cal'),
        title: 'Summer Vacation Begins',
        date: '1 Jun 2026',
        type: 'Holiday',
      ),
      CalendarEventItem(
        id: _newId('cal'),
        title: 'Independence Day',
        date: '15 Aug 2026',
        type: 'Holiday',
      ),
    ];
  }

  void addCalendarEvent({
    required String title,
    required String date,
    required String type,
    String className = '',
  }) {
    calendarEvents.add(
      CalendarEventItem(
        id: _newId('cal'),
        title: title,
        date: date,
        type: type,
        className: className,
      ),
    );
    notifyListeners();
  }

  void deleteCalendarEvent(String id) {
    calendarEvents.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Merges manually-added events with ones already scheduled elsewhere
  /// in the app (exams, PTM slots, online classes) so the calendar is a
  /// single source of truth instead of yet another disconnected list.
  List<CalendarEventItem> get allCalendarEvents {
    final list = List<CalendarEventItem>.from(calendarEvents);
    for (final e in exams) {
      list.add(
        CalendarEventItem(
          id: 'exam-${e.id}',
          title: '${e.title} (Exam)',
          date: e.date,
          type: 'Exam',
          className: e.className,
        ),
      );
    }
    for (final p in ptmSlots) {
      list.add(
        CalendarEventItem(
          id: 'ptm-${p.id}',
          title: 'Parent-Teacher Meeting',
          date: p.date,
          type: 'Meeting',
        ),
      );
    }
    for (final oc in onlineClasses) {
      list.add(
        CalendarEventItem(
          id: 'oc-${oc.id}',
          title: '${oc.title} (Online Class)',
          date: oc.date,
          type: 'Class',
          className: oc.className,
        ),
      );
    }
    return list;
  }

  int get upcomingEventsCount => allCalendarEvents.length;

  // -------------------------------------------------------------------
  // Document Vault — secure, per-student storage for certificates, TC,
  // Aadhar/ID proof, admission forms etc.
  // -------------------------------------------------------------------
  static const List<String> requiredDocumentTypes = [
    'Birth Certificate',
    'Transfer Certificate',
    'Aadhar / ID Proof',
    'Admission Form',
  ];

  late List<DocumentItem> studentDocuments;

  List<DocumentItem> _seedDocuments() {
    final list = <DocumentItem>[];
    for (int i = 0; i < students.length; i++) {
      final s = students[i];
      // Roughly two-thirds of the required set is pre-populated per
      // student, so the vault shows a realistic mix of complete /
      // incomplete records instead of everything looking finished.
      final howMany = 1 + (i % requiredDocumentTypes.length);
      for (int j = 0; j < howMany; j++) {
        final type = requiredDocumentTypes[j];
        list.add(
          DocumentItem(
            id: _newId('doc'),
            studentId: s.id,
            type: type,
            fileName:
                '${s.name.replaceAll(' ', '_')}_${type.split(' ').first}.pdf',
            uploadedOn: '${5 + j} Jul 2026',
            status: (i + j) % 3 == 0 ? 'Pending Verification' : 'Verified',
          ),
        );
      }
    }
    return list;
  }

  List<DocumentItem> documentsFor(String studentId) =>
      studentDocuments.where((d) => d.studentId == studentId).toList();

  List<String> missingDocumentTypesFor(String studentId) {
    final have = documentsFor(studentId).map((d) => d.type).toSet();
    return requiredDocumentTypes.where((t) => !have.contains(t)).toList();
  }

 Future<void> addDocument({
  required String studentId,
  required String type,
  required String fileName,
  String? fileUrl,
}) async {
  final inserted = await _client.from('documents').insert({
    'student_id': studentId,
    'type': type,
    'file_name': fileName,
    'file_url': fileUrl,
    'status': 'Pending Verification',
  }).select().single();

  studentDocuments.insert(
    0,
    DocumentItem(
      id: inserted['id'] as String,
      studentId: studentId,
      type: type,
      fileName: fileName,
      uploadedOn: 'Just now',
      fileUrl: fileUrl,
    ),
  );
  notifyListeners();
}

Future<void> verifyDocument(String id) async {
  final d = studentDocuments.firstWhere((e) => e.id == id);
  d.status = 'Verified';
  notifyListeners();

  await _client.from('documents').update({'status': 'Verified'}).eq('id', id);
}

Future<void> deleteDocument(String id) async {
  await _client.from('documents').delete().eq('id', id);
  studentDocuments.removeWhere((e) => e.id == id);
  notifyListeners();
}

  int get verifiedDocumentsCount =>
      studentDocuments.where((d) => d.status == 'Verified').length;
  int get pendingDocumentsCount =>
      studentDocuments.where((d) => d.status == 'Pending Verification').length;
  int get missingDocumentsCount =>
      students.fold(0, (a, s) => a + missingDocumentTypesFor(s.id).length);

  /// Fraction (0..1) of a student's required-document checklist that's
  /// been uploaded (verified or not).
  double documentCompletionFor(String studentId) {
    final have = documentsFor(studentId).map((d) => d.type).toSet();
    final relevant = have.intersection(requiredDocumentTypes.toSet()).length;
    return requiredDocumentTypes.isEmpty
        ? 0
        : relevant / requiredDocumentTypes.length;
  }

  // -------------------------------------------------------------------
  // Class-Wide Analytics & Report Builder — aggregates that already live
  // elsewhere in AppState (attendance, fees, gradebook) rolled up into the
  // KPIs a leadership-level "Reports" page needs.
  // -------------------------------------------------------------------
  double get schoolAttendancePercent {
    final total = presentCount + absentCount + lateCount;
    if (total == 0) return 0;
    return (presentCount + lateCount) / total * 100;
  }

  double get feeCollectionPercent {
    if (feeRecords.isEmpty) return 0;
    final collected = feeRecords.where((f) => f.status == 'Paid').length;
    return collected / feeRecords.length * 100;
  }

  double get schoolAverageExamPerformance {
    final names = classNames;
    if (names.isEmpty) return 0;
    final total = names.fold<double>(0, (a, c) => a + gradebookClassAverage(c));
    return total / names.length;
  }

  /// Class-wise average exam performance, for the Reports bar chart —
  /// scoped to a single class when [className] is given.
  Map<String, double> classPerformanceBreakdown({String? className}) {
    final names = className == null || className == 'All Classes'
        ? classNames
        : [className];
    return {for (final c in names) c: gradebookClassAverage(c)};
  }

  /// CSV export for whatever the Reports screen currently has generated —
  /// mirrors the "copy → paste into Excel/Sheets" pattern used elsewhere
  /// in the app (see Gradebook's "Export Marksheet").
  String buildReportCsv({required String reportType, required String scope}) {
    final buffer = StringBuffer('Report: $reportType ($scope)\n');
    buffer.writeln('Generated: Just now\n');
    switch (reportType) {
      case 'Attendance Trend':
        buffer.writeln('Day,Attendance %');
        for (int i = 0; i < weeklyAttendanceLabels.length; i++) {
          buffer.writeln(
            '${weeklyAttendanceLabels[i]},${weeklyAttendance[i].toStringAsFixed(1)}',
          );
        }
        break;
      case 'Fee Collection':
        buffer.writeln('Student,Class,Amount,Status');
        for (final f in feeRecords) {
          final s = studentById(f.studentId);
          buffer.writeln(
            '${s?.name ?? ''},${s?.className ?? ''},${f.amount.toStringAsFixed(0)},${f.status}',
          );
        }
        break;
      case 'Exam Performance':
        buffer.writeln('Class,Average %');
        classPerformanceBreakdown(
          className: scope,
        ).forEach((c, avg) => buffer.writeln('$c,${avg.toStringAsFixed(1)}'));
        break;
      default:
        buffer.writeln('Metric,Value');
        buffer.writeln(
          'School Attendance %,${schoolAttendancePercent.toStringAsFixed(1)}',
        );
        buffer.writeln(
          'Fee Collection %,${feeCollectionPercent.toStringAsFixed(1)}',
        );
        buffer.writeln(
          'Avg Exam Performance %,${schoolAverageExamPerformance.toStringAsFixed(1)}',
        );
    }
    return buffer.toString();
  }
}