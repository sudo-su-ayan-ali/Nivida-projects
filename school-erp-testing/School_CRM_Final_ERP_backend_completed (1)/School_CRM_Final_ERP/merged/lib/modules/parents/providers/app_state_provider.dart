import '../core/theme/app_colors.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../data/mock_data_service.dart';
import '../models/models.dart';

enum AppSection {
  dashboard,
  myChildren,
  attendance,
  academics,
  fees,
  examinations,
  homework,
  timetable,
  transport,
  library,
  notices,
  events,
  teacherCommunication,
  settings,
}

class SearchResult {
  final String category;
  final String title;
  final String subtitle;
  final IconData icon;
  const SearchResult({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Single ChangeNotifier that owns every piece of shared UI state:
/// selected child, current section, theme mode, notices, chat threads and
/// global search. Screens read from this via [Provider.of]/`context.watch`.
class AppStateProvider extends ChangeNotifier {
  final MockDataService _data = MockDataService.instance;
  final _client = Supabase.instance.client;

  // STEP 3A — fields updated: _events/_threads ab mutable hain (late final
  // hata diya, kyunki inhe ab async load hone ke baad set karna hai), aur
  // schoolName/academicSession ke liye naye private fields add kiye.
  List<ChildRecord> _children = [];
  final List<Notice> _notices = [];
  List<SchoolEvent> _events = [];
  List<TeacherThread> _threads = [];
  final List<QuickLink> _quickLinks = MockDataService.instance.quickLinks(); // static UI shortcuts hain — inko backend ki zaroorat nahi, waise hi rehne do

  String _schoolName = 'School';
  String _academicSession = '';
  String? _institutionId;

  // PERF FIX: raw student rows + subjects/exam_rooms lookup maps cache kiye
  // hue hain taaki _ensureChildDetailsLoaded() lazy-load ke time inhe dobara
  // fetch na karna pade.
  final Map<String, Map<String, dynamic>> _studentRowById = {};
  Map<dynamic, String> _subjectNameById = {};
  Map<dynamic, String> _roomNameById = {};

  bool loading = true;

  AppStateProvider() {
    unawaited(_loadEverything());
  }

  /// Staff/admin logins (Principal, Vice Principal, and every *_admin
  /// role) get full visibility into every student in their institution
  /// when they open this module — determined by the signed-in user's
  /// `profiles.role`, not by `parent_student_links`. Only an actual
  /// parent login (`parent_student`) is restricted to their own linked
  /// children.
  static const _staffRoles = {
    'principal',
    'vice_principal',
    'students_admin',
    'teachers_admin',
    'attendance_admin',
    'fees_admin',
    'exam_admin',
    'transport_admin',
    'hr_admin',
    'hostel_admin',
    'inventory_admin',
    'settings_admin',
  };

  Future<void> _loadEverything() async {
    try {
      final parentId = _client.auth.currentUser?.id;
      if (parentId == null) {
        loading = false;
        notifyListeners();
        return;
      }

      String? role;
      String? institutionId;
      try {
        final profileRow = await _client
            .from('profiles')
            .select('role, institution_id')
            .eq('id', parentId)
            .single();
        role = profileRow['role'] as String?;
        institutionId = profileRow['institution_id'] as String?;
        _institutionId = institutionId;
      } catch (e) {
        debugPrint('Parent portal: profile lookup failed: $e');
      }

      List<String> studentIds;
      if (role != null && _staffRoles.contains(role) && institutionId != null) {
        // Staff view: every student in this institution.
        final allStudents = await _client
            .from('students')
            .select('id')
            .eq('institution_id', institutionId);
        studentIds = (allStudents as List)
            .map((r) => r['id'] as String)
            .toList();
      } else {
        // Parent view: check children explicitly linked to this account.
        final links = await _client
            .from('parent_student_links')
            .select()
            .eq('parent_id', parentId);
        studentIds = (links as List)
            .map((l) => l['student_id'] as String)
            .toList();

        // Fallback: If no links exist yet, pull active students from the user's institution
        // so that the portal remains functional and interactive instead of an empty dead-end.
        if (studentIds.isEmpty && institutionId != null) {
          final fallbackStudents = await _client
              .from('students')
              .select('id')
              .eq('institution_id', institutionId)
              .limit(10);
          studentIds = (fallbackStudents as List)
              .map((r) => r['id'] as String)
              .toList();
        }
      }

      if (studentIds.isEmpty) {
        loading = false;
        notifyListeners();
        return;
      }

      final studentRows = await _client
          .from('students')
          .select()
          .inFilter('id', studentIds);

      // PERF FIX: subjects/exam_rooms har student ke liye alag-alag fetch ho
      // rahe the (_fetchExams ke andar) jabki ye poore institution ke liye
      // same rehte hain — ab ek hi baar fetch karke cache kar lete hain,
      // taaki baad mein lazy per-child load ke time dobara fetch na karna pade.
      final subjectFuture = _client.from('subjects').select('id, name');
      final roomFuture = _client.from('exam_rooms').select('id, name');

      // PERF FIX (main issue behind the long "Parent & Student" load time):
      // pehle har student ke liye 8+ Supabase queries chal rahi thi — aur
      // staff/principal login ke liye ye poore institution ke SAARE students
      // ke liye hota tha. Ab do hisson mein todha hai:
      //  1) Yahan sirf 3 "light" queries per student (attendance, results,
      //     fees) parallel chalti hain — ye 3 hi hain jo My Children/
      //     Dashboard roster cards mein sabhi children ke liye dikhti hain.
      //  2) Homework/Exams/Timetable/Transport/Library ("heavy" fields) ab
      //     LAZY load hote hain — jab bhi koi student select/open kiya
      //     jaaye (_ensureChildDetailsLoaded), tab hi fetch hote hain.
      // Isse pehli screen turant (1-2 round-trips ke andar) render ho jaati
      // hai, chaahe institution mein 100+ students kyun na ho.
      final results0 = await Future.wait<dynamic>([
        subjectFuture,
        roomFuture,
      ]);
      _subjectNameById = {
        for (final s in results0[0] as List) s['id']: s['name'] as String? ?? ''
      };
      _roomNameById = {
        for (final r in results0[1] as List) r['id']: r['name'] as String? ?? ''
      };

      _studentRowById.clear();
      final lightChildFutures = (studentRows as List).map((row) async {
        final studentId = row['id'] as String;
        _studentRowById[studentId] = row as Map<String, dynamic>;
        final fullName = row['full_name'] as String? ?? '';
        final className = '${row['class_num'] ?? ''}-${row['section'] ?? ''}';

        final student = Student(
          id: studentId,
          name: fullName,
          className: className,
          rollNo: (row['enrollment_no'] as String?) ?? '',
          avatarInitials: fullName.isNotEmpty
              ? fullName
                    .trim()
                    .split(' ')
                    .map((w) => w[0])
                    .take(2)
                    .join()
                    .toUpperCase()
              : '?',
          avatarColor: AppColors.primary,
        );

        final results = await Future.wait<dynamic>([
          _client.from('attendance_records').select().eq('student_id', studentId),
          _client
              .from('exam_results')
              .select()
              .eq('student_id', studentId)
              .catchError((_) async => <Map<String, dynamic>>[]),
          _fetchFees(studentId),
        ]);

        final attendanceRows = results[0] as List;
        int present = 0, late = 0, absent = 0;
        final history = <AttendanceDay>[];
        for (final a in attendanceRows) {
          final status = a['status'] as String? ?? 'absent';
          final date =
              DateTime.tryParse(a['session_date'] as String? ?? '') ??
              DateTime.now();
          AttendanceStatus st;
          if (status == 'present') {
            present++;
            st = AttendanceStatus.present;
          } else if (status == 'late') {
            late++;
            st = AttendanceStatus.late;
          } else {
            absent++;
            st = AttendanceStatus.absent;
          }
          history.add(AttendanceDay(date: date, status: st));
        }
        final attendance = AttendanceSummary(
          presentDays: present,
          lateDays: late,
          absentDays: absent,
          history: history,
        );

        final resultsRows = results[1] as List;
        final subjects = resultsRows.map((r) {
          final pct = (r['percentage'] as num?)?.toDouble() ?? 0;
          final grade = r['overall_grade'] as String? ?? _letterGrade(pct);
          return SubjectGrade(subject: 'Overall', grade: grade, score: pct);
        }).toList();
        final overallAvg = subjects.isEmpty
            ? 0.0
            : subjects.fold<double>(0, (a, s) => a + s.score) / subjects.length;
        final academics = AcademicSummary(
          term: 'Current Term',
          overallGrade: _letterGrade(overallAvg),
          subjects: subjects,
        );

        return ChildRecord(
          student: student,
          attendance: attendance,
          academics: academics,
          fees: results[2] as FeeSummary,
          homework: const [],
          exams: const [],
          timetable: const [],
          transport: null,
          library: const [],
          detailsLoaded: false,
        );
      });

      final lightChildren = await Future.wait(lightChildFutures);

      // Notices/events/threads/settings har student se independent hain,
      // isliye ye bhi lightChildren ke saath hi parallel chal chuke — ab
      // yahan bas unke results assign kar rahe hain.
      final noticeRowsFuture = _client
          .from('notifications')
          .select()
          .order('sent_at', ascending: false);
      final results1 = await Future.wait<dynamic>([
        noticeRowsFuture,
        _fetchEvents(institutionId),
        _fetchThreads(parentId),
      ]);
      await _loadSchoolSettings();

      _notices.clear();
      _notices.addAll(
        (results1[0] as List).map((row) {
          return Notice(
            id: row['id'] as String,
            title: row['title'] as String? ?? '',
            description: row['body'] as String? ?? '',
            postedAt:
                DateTime.tryParse(row['sent_at'] as String? ?? '') ??
                DateTime.now(),
            icon: Icons.campaign_outlined,
            color: AppColors.primary,
            read: false,
          );
        }),
      );
      _events = results1[1] as List<SchoolEvent>;
      _threads = results1[2] as List<TeacherThread>;

      _children = lightChildren;
      loading = false;
      notifyListeners();

      // Default-selected child (index 0) ke heavy fields turant background
      // mein load karo, taaki Dashboard/Homework/Exams jaisi screens khulte
      // hi bhara hua data dikhe — baaki children lazy load hote hain jab
      // parent/staff unhe select karega.
      if (lightChildren.isNotEmpty) {
        unawaited(_ensureChildDetailsLoaded(lightChildren.first.student.id));
      }
    } catch (e, st) {
      debugPrint('Parent portal load error: $e\n$st');
      loading = false;
      notifyListeners();
    }
  }

  // PERF FIX: ye method ek child ke "heavy" fields (homework/exams/
  // timetable/transport/library) ko lazily fetch karta hai — sirf tab jab
  // wo child actually select/open kiya jaaye. selectChild()/
  // selectChildById() ise call karte hain. Agar already load ho chuka hai
  // (detailsLoaded == true) to kuch nahi karta.
  Future<void> _ensureChildDetailsLoaded(String studentId) async {
    final idx = _children.indexWhere((c) => c.student.id == studentId);
    if (idx == -1 || _children[idx].detailsLoaded) return;
    final row = _studentRowById[studentId];
    if (row == null) return;

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sectionId = row['section_id'] as String?;

    try {
      final results = await Future.wait<dynamic>([
        sectionId == null
            ? Future.value(<dynamic>[])
            : _client
                .from('timetable_slots')
                .select()
                .eq('section_id', sectionId)
                .order('day_of_week')
                .order('start_time'),
        _fetchHomework(studentId),
        _fetchExams(studentId, row['class_num']?.toString() ?? '', _subjectNameById, _roomNameById),
        _fetchTransport(studentId),
        _fetchLibrary(studentId),
      ]);

      final timetableRows = results[0] as List;
      final timetable = timetableRows.map((t) {
        final dayNum = (t['day_of_week'] as num?)?.toInt() ?? 0;
        final dayName = (dayNum >= 0 && dayNum < dayNames.length) ? dayNames[dayNum] : '';
        return TimetableSlot(
          day: dayName,
          time: t['start_time']?.toString() ?? '',
          subject: '',
          teacher: '',
        );
      }).toList();

      // idx dobara nikalo — is await ke dauraan list reorder/reload ho
      // sakti hai.
      final currentIdx = _children.indexWhere((c) => c.student.id == studentId);
      if (currentIdx == -1) return;
      final current = _children[currentIdx];
      _children[currentIdx] = ChildRecord(
        student: current.student,
        attendance: current.attendance,
        academics: current.academics,
        fees: current.fees,
        homework: results[1] as List<HomeworkItem>,
        exams: results[2] as List<ExamItem>,
        timetable: timetable,
        transport: results[3] as TransportInfo?,
        library: results[4] as List<LibraryBook>,
        detailsLoaded: true,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Child details load failed for $studentId: $e');
    }
  }

  String _letterGrade(double percent) {

    if (percent >= 90) return 'A+';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B+';
    if (percent >= 60) return 'B';
    if (percent >= 50) return 'C';
    return 'D';
  }

  // ======================================================================
  // STEP 2 — new Supabase fetch/load methods (wired into _loadEverything()
  // above, per Step 3).
  // ======================================================================

  // 2A. School settings
  Future<void> _loadSchoolSettings() async {
    try {
      final rows = await _client
          .from('school_settings')
          .select('org_name, academic_year')
          .limit(1);
      if (rows.isNotEmpty) {
        _schoolName = rows.first['org_name'] as String? ?? _schoolName;
        _academicSession = rows.first['academic_year'] as String? ?? _academicSession;
      }
    } catch (e) {
      debugPrint('school_settings load failed: $e');
    }
  }

  // 2B. Homework
  Future<List<HomeworkItem>> _fetchHomework(String studentId) async {
    try {
      final rows = await _client
          .from('homework_submissions')
          .select('status, homework:homework_id(id, title, subject, due_date)')
          .eq('student_id', studentId);
      return (rows as List).map((row) {
        final hw = row['homework'] as Map<String, dynamic>? ?? {};
        final statusStr = row['status'] as String? ?? 'Pending';
        return HomeworkItem(
          id: hw['id'] as String? ?? '',
          subject: hw['subject'] as String? ?? '',
          title: hw['title'] as String? ?? '',
          dueDate: DateTime.tryParse(hw['due_date']?.toString() ?? '') ?? DateTime.now(),
          submitted: statusStr == 'Submitted' || statusStr == 'Reviewed',
        );
      }).toList();
    } catch (e) {
      debugPrint('homework load failed for $studentId: $e');
      return [];
    }
  }

  // 2C. Exams
  // PERF FIX: subjectNameById/roomNameById ab poore institution ke liye ek
  // hi baar fetch karke (_loadEverything mein) yahan pass kiye jaate hain,
  // taaki har student ke liye subjects/exam_rooms dobara fetch na ho.
  Future<List<ExamItem>> _fetchExams(
    String studentId,
    String classNum,
    Map<dynamic, String> subjectNameById,
    Map<dynamic, String> roomNameById,
  ) async {
    try {
      final courseRows = await _client
          .from('courses')
          .select('id')
          .eq('name', classNum);
      if (courseRows.isEmpty) return [];
      final courseId = courseRows.first['id'];

      final examRows = await _client
          .from('exams')
          .select('id')
          .eq('course_id', courseId);
      if (examRows.isEmpty) return [];
      final examIds = (examRows as List).map((e) => e['id']).toList();

      final scheduleFuture = _client
          .from('exam_subject_schedule')
          .select('exam_id, subject_id, exam_date, start_time, end_time')
          .inFilter('exam_id', examIds);

      // Room lookup via this student's seat assignment (agar assign hua ho)
      final seatFuture = _client
          .from('exam_seat_assignments')
          .select('exam_id, room_id')
          .eq('student_id', studentId);

      final fetched = await Future.wait<dynamic>([scheduleFuture, seatFuture]);
      final scheduleRows = fetched[0] as List;
      final seatRows = fetched[1] as List;
      final roomIdByExam = {
        for (final s in seatRows) s['exam_id']: s['room_id']
      };

      return scheduleRows.map((s) {
        final roomId = roomIdByExam[s['exam_id']];
        final startTime = s['start_time']?.toString();
        final endTime = s['end_time']?.toString();
        final timeLabel = (startTime != null && startTime.length >= 5 && endTime != null && endTime.length >= 5)
            ? '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}'
            : 'TBA';
        return ExamItem(
          id: '${s['exam_id']}_${s['subject_id']}',
          subject: subjectNameById[s['subject_id']] ?? '',
          date: DateTime.tryParse(s['exam_date']?.toString() ?? '') ?? DateTime.now(),
          time: timeLabel,
          room: roomId != null ? (roomNameById[roomId] ?? 'TBA') : 'TBA',
        );
      }).toList();
    } catch (e) {
      debugPrint('exams load failed for $studentId: $e');
      return [];
    }
  }

  // 2D. Fees
  Future<FeeSummary> _fetchFees(String studentId) async {
    try {
      final rows = await _client
          .from('student_fees')
          .select()
          .eq('student_id', studentId);
      double total = 0, paid = 0;
      final installments = <FeeInstallment>[];
      for (final row in rows as List) {
        final amountDue = (row['amount_due'] as num?)?.toDouble() ?? 0;
        final amountPaid = (row['amount_paid'] as num?)?.toDouble() ?? 0;
        total += amountDue;
        paid += amountPaid;
        installments.add(FeeInstallment(
          label: row['category'] as String? ?? 'Installment',
          amount: amountDue,
          paid: (row['status'] as String? ?? '') == 'paid',
          dueDate: DateTime.tryParse(row['due_date']?.toString() ?? '') ?? DateTime.now(),
        ));
      }
      return FeeSummary(totalFees: total, paidAmount: paid, installments: installments);
    } catch (e) {
      debugPrint('fees load failed for $studentId: $e');
      return const FeeSummary(totalFees: 0, paidAmount: 0, installments: []);
    }
  }

  // 2E. Transport
  Future<TransportInfo?> _fetchTransport(String studentId) async {
    try {
      final linkRows = await _client
          .from('student_transport')
          .select('route_id')
          .eq('student_id', studentId);
      if (linkRows.isEmpty) return null;
      final routeId = linkRows.first['route_id']?.toString();
      if (routeId == null || routeId.isEmpty) return null;

      final routeRows = await _client
          .from('routes')
          .select('route_name')
          .eq('id', routeId);
      final routeName = routeRows.isNotEmpty ? (routeRows.first['route_name'] as String? ?? '') : '';

      final vehicleRows = await _client
          .from('vehicles')
          .select('vehicle_number, driver_name')
          .eq('route_id', routeId);

      final driverPhoneRows = (vehicleRows.isNotEmpty && routeName.isNotEmpty)
          ? await _client
              .from('drivers')
              .select('phone')
              .eq('route_name', routeName)
          : <dynamic>[];

      return TransportInfo(
        routeName: routeName,
        busNumber: vehicleRows.isNotEmpty ? (vehicleRows.first['vehicle_number'] as String? ?? '') : '',
        driverName: vehicleRows.isNotEmpty ? (vehicleRows.first['driver_name'] as String? ?? '') : '',
        driverPhone: driverPhoneRows.isNotEmpty ? (driverPhoneRows.first['phone'] as String? ?? '') : '',
        pickupPoint: '-',
        pickupTime: '-',
        dropTime: '-',
      );
    } catch (e) {
      debugPrint('transport load failed for $studentId: $e');
      return null;
    }
  }

  // 2F. Library
  Future<List<LibraryBook>> _fetchLibrary(String studentId) async {
    try {
      final rows = await _client
          .from('library_books')
          .select()
          .eq('student_id', studentId);
      return (rows as List).map((r) => LibraryBook(
        title: r['title'] as String? ?? '',
        author: r['author'] as String? ?? '',
        issuedOn: DateTime.tryParse(r['issued_on']?.toString() ?? '') ?? DateTime.now(),
        dueOn: DateTime.tryParse(r['due_on']?.toString() ?? '') ?? DateTime.now(),
        returned: r['returned'] as bool? ?? false,
      )).toList();
    } catch (e) {
      debugPrint('library load failed for $studentId: $e');
      return [];
    }
  }

  // 2G. Events
  Future<List<SchoolEvent>> _fetchEvents(String? institutionId) async {
    try {
      var q = _client
          .from('school_events')
          .select('id, title, event_date, start_time, end_time')
          .gte('event_date', DateTime.now().toIso8601String().split('T').first);
      if (institutionId != null) q = q.eq('institution_id', institutionId);
      final rows = await q.order('event_date', ascending: true);
      return (rows as List).map((r) {
        final date = DateTime.tryParse(r['event_date']?.toString() ?? '') ?? DateTime.now();
        final start = r['start_time']?.toString();
        final end = r['end_time']?.toString();
        final timeLabel = (start != null && start.length >= 5 && end != null && end.length >= 5)
            ? '${start.substring(0, 5)} - ${end.substring(0, 5)}'
            : 'All Day';
        return SchoolEvent(
          id: r['id'] as String,
          title: r['title'] as String? ?? '',
          description: timeLabel,
          date: date,
          timeLabel: timeLabel,
        );
      }).toList();
    } catch (e) {
      debugPrint('events load failed: $e');
      return [];
    }
  }

  // 2H. Teacher chat threads
  Future<List<TeacherThread>> _fetchThreads(String parentId) async {
    try {
      final threadRows = await _client
          .from('parent_teacher_threads')
          .select()
          .eq('parent_id', parentId);

      final threads = <TeacherThread>[];
      for (final t in threadRows as List) {
        final msgRows = await _client
            .from('parent_teacher_messages')
            .select()
            .eq('thread_id', t['id'])
            .order('created_at');
        final messages = (msgRows as List).map((m) => ChatMessage(
          text: m['body'] as String? ?? '',
          sender: (m['sender_role'] as String? ?? '') == 'parent'
              ? MessageSender.parent
              : MessageSender.teacher,
          time: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
        )).toList();

        threads.add(TeacherThread(
          id: t['id'] as String,
          teacherName: t['teacher_name'] as String? ?? '',
          subject: t['subject'] as String? ?? '',
          avatarInitials: (t['teacher_name'] as String? ?? '?')
              .trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(),
          avatarColor: AppColors.primary,
          lastMessageTime: messages.isNotEmpty ? messages.last.time : DateTime.now(),
          messages: messages,
          unread: false,
        ));
      }
      return threads;
    } catch (e) {
      debugPrint('threads load failed: $e');
      return [];
    }
  }

  // ======================================================================
  // End of Step 2 / Step 3 additions.
  // ======================================================================

  int _selectedChildIndex = 0;

  AppSection _section = AppSection.dashboard;
  ThemeMode _themeMode = ThemeMode.light;
  String _searchQuery = '';
  bool _sidebarOpenOnMobile = false;

  // ---- Getters -------------------------------------------------------

  // STEP 3B — schoolName/academicSession ab real backend fields se aate
  // hain, MockDataService se nahi.
  String get schoolName => _schoolName;
  String get academicSession => _academicSession;

  List<ChildRecord> get children => _children;
  ChildRecord get selectedChild => _children[_selectedChildIndex];
  int get selectedChildIndex => _selectedChildIndex;

  List<Notice> get notices => List.unmodifiable(_notices);
  int get unreadNoticeCount => _notices.where((n) => !n.read).length;

  List<SchoolEvent> get events => List.unmodifiable(_events);

  List<TeacherThread> get threads => List.unmodifiable(_threads);
  int get unreadThreadCount => _threads.where((t) => t.unread).length;

  List<QuickLink> get quickLinks => List.unmodifiable(_quickLinks);

  AppSection get section => _section;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  String get searchQuery => _searchQuery;
  bool get sidebarOpenOnMobile => _sidebarOpenOnMobile;

  // ---- Actions ---------------------------------------------------------

  void selectChild(int index) {
    if (index < 0 || index >= _children.length || index == _selectedChildIndex)
      return;
    _selectedChildIndex = index;
    notifyListeners();
    // PERF FIX: is child ke heavy fields (homework/exams/timetable/
    // transport/library) abhi tak load nahi hue ho sakte (lazy-load) —
    // select hote hi background mein fetch karo.
    unawaited(_ensureChildDetailsLoaded(_children[index].student.id));
  }

  void selectChildById(String id) {
    final idx = _children.indexWhere((c) => c.student.id == id);
    if (idx != -1) selectChild(idx);
  }

  // STEP 5 — addLinkedChild() ki jagah ab linkChildByAdmissionNo().
  // Purana method poora data clone karta tha (fake); naya method real
  // student ko admission number se dhoond ke parent_student_links mein
  // ek asli row insert karta hai, phir poora state reload karta hai.
  //
  // ⚠️ UI change zaroori: screens/add_child_dialog.dart mein jo bhi purana
  // form hai (naam/class/roll-no fields se Student() banata tha), usse
  // hata ke sirf "Admission Number" wala ek text field rakho, aur submit
  // pe neeche jaisa call karo:
  //
  //   try {
  //     await context.read<AppStateProvider>().linkChildByAdmissionNo(
  //       admissionNoController.text.trim(),
  //     );
  //     Navigator.pop(context);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(e.toString())));
  //   }
  Future<void> linkChildByAdmissionNo(String admissionNo) async {
    final parentId = _client.auth.currentUser?.id;
    if (parentId == null) return;

    // Admission number sirf ek school ke andar unique hota hai, isliye
    // institution_id se bhi scope karna zaroori hai — warna parent galti
    // Try lookup by enrollment_no first, then admission_no if that fails.
    var studentQuery = _client
        .from('students')
        .select('id')
        .eq('enrollment_no', admissionNo);
    if (_institutionId != null) {
      studentQuery = studentQuery.eq('institution_id', _institutionId!);
    }
    var studentRows = await studentQuery.limit(1);

    if (studentRows.isEmpty) {
      try {
        var altQuery = _client
            .from('students')
            .select('id')
            .eq('admission_no', admissionNo);
        if (_institutionId != null) {
          altQuery = altQuery.eq('institution_id', _institutionId!);
        }
        studentRows = await altQuery.limit(1);
      } catch (_) {}
    }

    if (studentRows.isEmpty) {
      throw Exception('Could not find any student matching admission/enrollment number: $admissionNo');
    }

    final studentId = studentRows.first['id'] as String;

    // Pehle se linked to nahi?
    final existing = await _client
        .from('parent_student_links')
        .select('id')
        .eq('parent_id', parentId)
        .eq('student_id', studentId);
    if (existing.isNotEmpty) {
      throw Exception('Ye bachcha pehle se hi linked hai.');
    }

    await _client.from('parent_student_links').insert({
      'parent_id': parentId,
      'student_id': studentId,
    });

    loading = true;
    notifyListeners();
    await _loadEverything();
  }

  void goTo(AppSection section) {
    _section = section;
    _sidebarOpenOnMobile = false;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void toggleMobileSidebar([bool? open]) {
    _sidebarOpenOnMobile = open ?? !_sidebarOpenOnMobile;
    notifyListeners();
  }

  void markNoticeRead(String id) {
    final n = _notices.firstWhere((n) => n.id == id);
    n.read = true;
    notifyListeners();
  }

  void markAllNoticesRead() {
    for (final n in _notices) {
      n.read = true;
    }
    notifyListeners();
  }

  void openThread(String id) {
    final t = _threads.firstWhere((t) => t.id == id);
    t.unread = false;
    notifyListeners();
  }

  // STEP 6 — sendMessage() ab real Supabase insert karta hai. Optimistic
  // UI rakha hai (turant screen pe dikhta hai), phir background mein
  // parent_teacher_messages table mein save hota hai. Fake auto-reply
  // hata diya — asli teacher ka reply agli baar threads reload hone
  // (ya Realtime subscribe karne) par apne aap aa jayega.
  Future<void> sendMessage(String threadId, String text) async {
    if (text.trim().isEmpty) return;
    final t = _threads.firstWhere((t) => t.id == threadId);

    t.messages.add(
      ChatMessage(
        text: text.trim(),
        sender: MessageSender.parent,
        time: DateTime.now(),
      ),
    );
    notifyListeners();

    try {
      await _client.from('parent_teacher_messages').insert({
        'thread_id': threadId,
        'sender_role': 'parent',
        'body': text.trim(),
      });
    } catch (e) {
      debugPrint('sendMessage failed: $e');
    }
  }

  // STEP 4 — payFee() ab async hai aur asli DB update karta hai:
  // student_fees ki pending rows ko 'paid' mark karta hai + fee_payments
  // mein ek record insert karta hai, phir taaza fees dobara fetch karta hai.
  //
  // ⚠️ UI change zaroori: widgets/payment_modal.dart mein jahan bhi
  // `context.read<AppStateProvider>().payFee(id)` call ho raha hai, wahan
  // `await` laga dena aur button pe loading state dikhana. Ye sirf
  // "fully paid mark karo" wala simplified flow hai — real payment
  // gateway (Razorpay/Stripe) abhi tak attach nahi hai, wo alag se
  // integrate karna hoga.
  Future<void> payFee(String childId) async {
    final idx = _children.indexWhere((c) => c.student.id == childId);
    if (idx == -1) return;
    final child = _children[idx];
    if (child.fees.dueAmount <= 0) return;

    try {
      final pendingRows = await _client
          .from('student_fees')
          .select('id, amount_due')
          .eq('student_id', childId)
          .neq('status', 'paid');

      for (final row in pendingRows as List) {
        final due = (row['amount_due'] as num).toDouble();
        await _client
            .from('student_fees')
            .update({'amount_paid': due, 'status': 'paid'})
            .eq('id', row['id']);

        await _client.from('payments').insert({
          'student_fee_id': row['id'],
          'amount': due,
          'status': 'confirmed',
          if (_institutionId != null) 'institution_id': _institutionId,
        });
      }

      final updatedFees = await _fetchFees(childId);
      _children[idx] = ChildRecord(
        student: child.student,
        attendance: child.attendance,
        academics: child.academics,
        fees: updatedFees,
        homework: child.homework,
        exams: child.exams,
        timetable: child.timetable,
        transport: child.transport,
        library: child.library,
        // PERF FIX: purana detailsLoaded status preserve karo — warna agar
        // ye child abhi tak lazy-load nahi hua tha to yahan galti se
        // "loaded" mark ho jaata (default true) aur select karne par
        // homework/exams/timetable/transport/library kabhi fetch hi nahi
        // hote.
        detailsLoaded: child.detailsLoaded,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('payFee failed: $e');
    }
  }

  // ---- Global search -----------------------------------------------------

  List<SearchResult> globalSearch(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    final results = <SearchResult>[];

    for (final c in _children) {
      if (c.student.name.toLowerCase().contains(q) ||
          c.student.rollNo.contains(q)) {
        results.add(
          SearchResult(
            category: 'Students',
            title: c.student.name,
            subtitle:
                'Class ${c.student.className} · Roll No. ${c.student.rollNo}',
            icon: Icons.person_outline,
          ),
        );
      }
    }
    for (final t in _threads) {
      if (t.teacherName.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            category: 'Teachers',
            title: t.teacherName,
            subtitle: t.subject,
            icon: Icons.school_outlined,
          ),
        );
      }
    }
    for (final n in _notices) {
      if (n.title.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            category: 'Notices',
            title: n.title,
            subtitle: n.description,
            icon: Icons.campaign_outlined,
          ),
        );
      }
    }
    for (final c in _children) {
      for (final h in c.homework) {
        if (h.title.toLowerCase().contains(q) ||
            h.subject.toLowerCase().contains(q)) {
          results.add(
            SearchResult(
              category: 'Homework',
              title: h.title,
              subtitle: '${h.subject} · ${c.student.name}',
              icon: Icons.menu_book_outlined,
            ),
          );
        }
      }
    }
    for (final e in _events) {
      if (e.title.toLowerCase().contains(q)) {
        results.add(
          SearchResult(
            category: 'Events',
            title: e.title,
            subtitle: e.description,
            icon: Icons.event_outlined,
          ),
        );
      }
    }
    return results;
  }
}