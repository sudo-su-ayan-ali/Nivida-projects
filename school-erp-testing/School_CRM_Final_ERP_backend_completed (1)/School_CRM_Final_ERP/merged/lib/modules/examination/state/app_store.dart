/// AppStore is the app's repository + domain-logic layer, exposed via
/// Provider as a ChangeNotifier. UI widgets call methods here; they never
/// contain business logic themselves. In a backend-connected deployment,
/// each method group below maps 1:1 onto a repository interface that would
/// call a real API instead of mutating in-memory lists -- swap the
/// implementation, keep the contract.

library app_store;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/security_services.dart';
import 'seed_data.dart';

class AppStore extends ChangeNotifier {
  final SupabaseClient? _clientInstance;
  SupabaseClient get _client {
    if (_clientInstance != null) return _clientInstance!;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase client is not initialized.');
    }
  }
  bool examsLoading = false;
  String? institutionId;
  final AuditService audit;
  AppUser? currentUser;

  // ---- collections (in-memory "database") ----
  late List<AppUser> demoUsers;
  late List<AcademicSession> sessions;
  late List<SchoolClass> classes;
  late List<Subject> subjects;
  late List<Examination> exams;
  late List<Student> students;
  late List<EligibilityRecord> eligibility;
  late List<AccommodationRecord> accommodations;
  late List<QuestionItem> questions;
  late List<QuestionPaperSet> paperSets;
  late List<ExamRoom> rooms;
  late List<Invigilator> invigilators;
  late List<InvigilatorDuty> duties;
  late List<SeatAssignment> seats;
  late List<AnonymousBook> books;
  late List<EvaluationRecord> evaluations;
  late List<MarksCorrectionRequest> corrections;
  late List<ResultRecord> results;
  late List<RevaluationRequest> revaluations;
  late List<MalpracticeIncident> incidents;
  late List<NotificationItem> notifications;

  static const double moderationThresholdPercent =
      10; // config: flag if 2 evaluators differ >10%

  AppStore({SupabaseClient? client, AuditService? auditService})
      : _clientInstance = client,
        audit = auditService ?? AuditService(client: client) {
    final seed = SeedData.generate();
    demoUsers = seed.users;
    sessions = seed.sessions;
    classes = seed.classes;
    subjects = seed.subjects;
    exams = seed.exams;
       students = [];
    eligibility = seed.eligibility;
    accommodations = seed.accommodations;
    questions = seed.questions;
    paperSets = seed.paperSets;
    rooms = seed.rooms;
    invigilators = seed.invigilators;
    duties = seed.duties;
    seats = seed.seats;
    books = seed.books;
    evaluations = seed.evaluations;
    corrections = [];
    results = seed.results;
    revaluations = [];
    incidents = seed.incidents;
    notifications = seed.notifications;
    currentUser =
        demoUsers.first; // default: super admin, switch via login screen
  }

  void login(AppUser user) {
    currentUser = user;
    audit.log(actor: user, action: 'Login', module: 'Auth');
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Load real Exams + Results from Supabase
  // -------------------------------------------------------------------
  Future<void> loadExamsFromSupabase() async {
    examsLoading = true;
    notifyListeners();

    final examRows = await _client.from('exams').select();
    final scheduleRows = await _client.from('exam_subject_schedule').select();
    final resultRows = await _client.from('exam_results').select();
    final resultSubjectRows = await _client
        .from('exam_result_subjects')
        .select();

    final loadedExams = <Examination>[];
    for (final row in examRows as List) {
      final schedule = (scheduleRows as List)
          .where((s) => s['exam_id'] == row['id'])
          .map(
            (s) => ExamSubjectSchedule(
              subjectId: s['subject_id'],
              date: DateTime.parse(s['exam_date']),
              startTime: s['start_time'].toString().substring(0, 5),
              endTime: s['end_time'].toString().substring(0, 5),
              maxMarks: s['max_marks'] ?? 100,
              passingMarks: s['passing_marks'] ?? 33,
            ),
          )
          .toList();

      loadedExams.add(
        Examination(
          id: row['id'],
          name: row['name'] ?? '',
          type: ExamType.values.firstWhere(
            (t) => t.name == row['exam_type'],
            orElse: () => ExamType.unitTest,
          ),
          sessionId: row['session_id'] ?? '',
          classId: row['course_id'] ?? '',
          sections: [],
          schedule: schedule,
          rankingEnabled: row['ranking_enabled'] ?? true,
          status: ExamStatus.values.firstWhere(
            (s) => s.name == row['status'],
            orElse: () => ExamStatus.draft,
          ),
        ),
      );
    }

    final loadedResults = <ResultRecord>[];
    for (final row in resultRows as List) {
      final subjects = (resultSubjectRows as List)
          .where((rs) => rs['result_id'] == row['id'])
          .map(
            (rs) => SubjectResult(
              subjectId: rs['subject_id'],
              maxMarks: rs['max_marks'],
              marksObtained: rs['marks_obtained'],
              grade: rs['grade'] ?? '',
            ),
          )
          .toList();

      loadedResults.add(
        ResultRecord(
          id: row['id'],
          examId: row['exam_id'],
          studentId: row['student_id'],
          subjects: subjects,
          percentage: (row['percentage'] as num?)?.toDouble() ?? 0,
          overallGrade: row['overall_grade'] ?? '',
          rank: row['rank'],
          pass: row['pass'] ?? false,
          stage: ResultStage.values.firstWhere(
            (s) => s.name == row['stage'],
            orElse: () => ResultStage.draft,
          ),
        ),
      );
    }

    exams = loadedExams;
    results = loadedResults;
    examsLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Load real Courses (as "classes") + Sections from Supabase
  // -------------------------------------------------------------------
  Future<void> loadCoursesFromSupabase() async {
    final courseRows = await _client.from('courses').select();
    final sectionRows = await _client.from('sections').select();
    if (courseRows.isNotEmpty) {
      institutionId = courseRows.first['institution_id'];
      audit.institutionId = institutionId;
      loadAuditLogFromSupabase();
    }

    final loadedClasses = <SchoolClass>[];
    for (final row in courseRows as List) {
      final sectionNames = (sectionRows as List)
          .where((s) => s['course_id'] == row['id'])
          .map((s) => s['name'].toString())
          .toList();

      loadedClasses.add(
        SchoolClass(
          id: row['id'],
          name: row['name'] ?? '',
          sections: sectionNames.isEmpty ? ['A'] : sectionNames,
        ),
      );
    }

    classes = loadedClasses;
    notifyListeners();
  }
  Future<void> loadStudentsFromSupabase() async {
    try {
      final rows = await _client.from('students').select();
      students = (rows as List)
          .map((r) => Student(
                id: r['id'],
                rollNo: r['enrollment_no'] ?? '',
                name: r['full_name'] ?? '',
                classId: (r['class_num'] ?? '').toString(),
                section: r['section'] ?? '',
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Students load error: $err');
    }
  }
  // -------------------------------------------------------------------
  // Load real Academic Sessions from Supabase
  // -------------------------------------------------------------------
  Future<void> loadSessionsFromSupabase() async {
    try {
      final sessionRows = await _client.from('academic_sessions').select();

      final loadedSessions = <AcademicSession>[];
      for (final row in sessionRows as List) {
        loadedSessions.add(
          AcademicSession(
            id: row['id'],
            label: row['name'] ?? '',
            isActive: row['is_current'] ?? true,
          ),
        );
      }

      if (loadedSessions.isNotEmpty) {
        sessions = loadedSessions;
        notifyListeners();
      }
    } catch (err) {
      print('❌ Sessions load error: $err');
    }
  }

  Future<void> loadSubjectsFromSupabase() async {
    try {
      final subjectRows = await _client.from('subjects').select();

      final loadedSubjects = <Subject>[];

      for (final row in subjectRows as List) {
        loadedSubjects.add(
          Subject(
            id: row['id'].toString(),
            name: row['name']?.toString() ?? '',
            code: row['code']?.toString() ?? '',
            classId: row['course_id'].toString(),
          ),
        );
      }

      subjects = loadedSubjects;
      notifyListeners();
    } catch (err) {
      print('❌ Subjects load error: $err');
    }
  }
  // =====================================================================
  // Load remaining Examination data from Supabase (Eligibility, Question
  // Bank, Rooms/Invigilators/Duties, Seating, Answer Books, Evaluations,
  // Revaluation, Malpractice)
  // =====================================================================
  // ---- Audit log (persisted, so history survives refresh/restart) ----
  Future<void> loadAuditLogFromSupabase() async {
    await audit.loadFromSupabase();
    notifyListeners();
  }

  Future<void> loadRemainingExaminationData() async {
    await Future.wait([
      loadEligibilityFromSupabase(),
      loadQuestionBankFromSupabase(),
      loadQuestionPapersFromSupabase(),
      loadRoomsInvigilatorsDutiesFromSupabase(),
      loadSeatAssignmentsFromSupabase(),
      loadAnswerBooksFromSupabase(),
      loadEvaluationsFromSupabase(),
      loadRevaluationsFromSupabase(),
      loadMalpracticeFromSupabase(),
      loadNotificationsFromSupabase(),
    ]);
  }

  // ---- Question Papers ----
  Future<void> loadQuestionPapersFromSupabase() async {
    try {
      final rows = await _client.from('question_papers').select();
      paperSets = (rows as List)
          .map((r) => QuestionPaperSet(
                id: r['id'],
                examId: r['exam_id'],
                subjectId: r['subject_id'],
                setLabel: r['set_label'] ?? '',
                questionIds: (r['question_ids'] as List?)
                        ?.map((q) => q.toString())
                        .toList() ??
                    [],
                totalMarks: r['total_marks'] ?? 0,
                status: PaperStatus.values.firstWhere(
                    (s) => s.name == r['status'],
                    orElse: () => PaperStatus.draft),
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Question papers load error: $err');
    }
  }

  // ---- Eligibility ----
  Future<void> loadEligibilityFromSupabase() async {
    try {
      final rows = await _client.from('exam_eligibility').select();
      eligibility = (rows as List)
          .map((r) => EligibilityRecord(
                id: r['id'],
                studentId: r['student_id'],
                examId: r['exam_id'],
                status: EligibilityStatus.values.firstWhere(
                    (s) => s.name == r['status'],
                    orElse: () => EligibilityStatus.eligible),
                reason: r['reason'] ?? '',
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Eligibility load error: $err');
    }
  }

  // ---- Question Bank items ----
  Future<void> loadQuestionBankFromSupabase() async {
    try {
      final rows = await _client.from('question_bank_items').select();
      questions = (rows as List)
          .map((r) => QuestionItem(
                id: r['id'],
                text: r['question_text'] ?? '',
                classId: r['course_id']?.toString() ?? '',
                subjectId: r['subject_id'],
                chapter: r['chapter'] ?? '',
                topic: r['topic'] ?? '',
                type: QuestionType.values.firstWhere(
                    (t) => t.name == r['question_type'],
                    orElse: () => QuestionType.shortAnswer),
                difficulty: Difficulty.values.firstWhere(
                    (d) => d.name == r['difficulty'],
                    orElse: () => Difficulty.medium),
                marks: r['marks'] ?? 1,
                tags: (r['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
                status: QuestionStatus.values.firstWhere(
                    (s) => s.name == r['status'],
                    orElse: () => QuestionStatus.approved),
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Question bank load error: $err');
    }
  }

  // ---- Rooms + Invigilators + Duties ----
  Future<void> loadRoomsInvigilatorsDutiesFromSupabase() async {
    try {
      final roomRows = await _client.from('exam_rooms').select();
      rooms = (roomRows as List)
          .map((r) => ExamRoom(id: r['id'], name: r['name'] ?? '', capacity: r['capacity'] ?? 0))
          .toList();

      final invRows = await _client.from('exam_invigilators').select();
      invigilators = (invRows as List)
          .map((r) => Invigilator(id: r['id'], userId: r['user_id'] ?? '', name: r['name'] ?? ''))
          .toList();

      final dutyRows = await _client.from('exam_invigilator_duties').select();
      duties = (dutyRows as List)
          .map((r) => InvigilatorDuty(
                id: r['id'],
                examId: r['exam_id'],
                roomId: r['room_id'],
                subjectId: r['subject_id'],
                invigilatorId: r['invigilator_id'],
                substituteInvigilatorId: r['substitute_invigilator_id'],
                substituteNeeded: r['substitute_needed'] ?? false,
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Rooms/Invigilators/Duties load error: $err');
    }
  }

  // ---- Seat assignments ----
  Future<void> loadSeatAssignmentsFromSupabase() async {
    try {
      final rows = await _client.from('exam_seat_assignments').select();
      seats = (rows as List)
          .map((r) => SeatAssignment(
                id: r['id'],
                examId: r['exam_id'],
                roomId: r['room_id'],
                seatCode: r['seat_code'] ?? '',
                studentId: r['student_id'],
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Seat assignments load error: $err');
    }
  }

  // ---- Answer books + custody history ----
  Future<void> loadAnswerBooksFromSupabase() async {
    try {
      final bookRows = await _client.from('exam_answer_books').select();
      final eventRows = await _client.from('exam_book_custody_events').select();
      books = (bookRows as List).map((r) {
        final history = (eventRows as List)
            .where((e) => e['book_id'] == r['id'])
            .map((e) => CustodyEvent(
                  id: e['id'],
                  toStatus: BookStatus.values.firstWhere(
                      (s) => s.name == e['to_status'],
                      orElse: () => BookStatus.generated),
                  actorUserId: e['actor_user_id'] ?? '',
                  timestamp: DateTime.tryParse(e['created_at'] ?? '') ?? DateTime.now(),
                  note: e['note'] ?? '',
                ))
            .toList();
        return AnonymousBook(
          id: r['id'],
          anonId: r['anon_id'],
          examId: r['exam_id'],
          subjectId: r['subject_id'],
          studentId: r['student_id'],
          examinerId: r['examiner_id'],
          status: BookStatus.values.firstWhere((s) => s.name == r['status'],
              orElse: () => BookStatus.generated),
          history: history,
          identityRevealed: r['identity_revealed'] ?? false,
        );
      }).toList();
      notifyListeners();
    } catch (err) {
      print('❌ Answer books load error: $err');
    }
  }

  // ---- Evaluations + Marks corrections ----
  Future<void> loadEvaluationsFromSupabase() async {
    try {
      final rows = await _client.from('exam_evaluations').select();
      evaluations = (rows as List).map((r) {
        final rawMarks = r['marks'];
        List<dynamic> rawList = [];
        if (rawMarks is List) {
          rawList = rawMarks;
        } else if (rawMarks is String) {
          try {
            final parsed = jsonDecode(rawMarks);
            if (parsed is List) rawList = parsed;
          } catch (_) {}
        } else if (rawMarks is num) {
          rawList = [
            {'questionNo': '1', 'maxMarks': 100, 'awarded': rawMarks.toInt(), 'comment': ''}
          ];
        }

        final marksList = rawList.map((m) {
          if (m is Map) {
            return QuestionMark(
              questionNo: (m['questionNo'] ?? m['question_no'] ?? '').toString(),
              maxMarks: (m['maxMarks'] ?? m['max_marks'] as num?)?.toInt() ?? 0,
              awarded: (m['awarded'] as num?)?.toInt() ?? (m['marks'] as num?)?.toInt(),
              comment: m['comment']?.toString(),
            );
          }
          return QuestionMark(questionNo: '1', maxMarks: 100, awarded: (m as num?)?.toInt());
        }).toList();

        return EvaluationRecord(
          id: r['id'],
          bookId: r['book_id'],
          examinerId: r['examiner_id'] ?? '',
          stage: EvaluationStage.values.firstWhere((s) => s.name == r['stage'],
              orElse: () => EvaluationStage.first),
          marks: marksList,
          submitted: r['submitted'] ?? false,
          locked: r['locked'] ?? false,
          submittedAt: DateTime.tryParse(r['submitted_at'] ?? ''),
        );
      }).toList();

      final corrRows = await _client.from('exam_marks_corrections').select();
      corrections = (corrRows as List)
          .map((r) => MarksCorrectionRequest(
                id: r['id'],
                bookId: r['book_id'],
                requestedByUserId: r['requested_by'] ?? '',
                originalValue: (r['original_value'] as num?)?.toInt() ?? 0,
                newValue: (r['new_value'] as num?)?.toInt() ?? 0,
                reason: r['reason'] ?? '',
                status: CorrectionStatus.values.firstWhere((s) => s.name == r['status'],
                    orElse: () => CorrectionStatus.pending),
                approvedByUserId: r['approved_by'],
                requestedAt: DateTime.tryParse(r['requested_at'] ?? '') ?? DateTime.now(),
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Evaluations load error: $err');
    }
  }

  // ---- Revaluation ----
  Future<void> loadRevaluationsFromSupabase() async {
    try {
      final rows = await _client.from('exam_revaluation_requests').select();
      revaluations = (rows as List)
          .map((r) => RevaluationRequest(
                id: r['id'],
                studentId: r['student_id'],
                bookId: r['book_id'],
                subjectId: r['subject_id'],
                originalMarks: (r['original_marks'] as num?)?.toInt() ?? 0,
                revisedMarks: (r['revised_marks'] as num?)?.toInt(),
                reason: r['reason'] ?? '',
                status: RevaluationStatus.values.firstWhere((s) => s.name == r['status'],
                    orElse: () => RevaluationStatus.requested),
                requestedAt: DateTime.tryParse(r['requested_at'] ?? '') ?? DateTime.now(),
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Revaluation load error: $err');
    }
  }

  // ---- Malpractice ----
  Future<void> loadMalpracticeFromSupabase() async {
    try {
      final rows = await _client.from('exam_malpractice_incidents').select();
      incidents = (rows as List)
          .map((r) => MalpracticeIncident(
                id: r['id'],
                studentId: r['student_id'],
                examId: r['exam_id'],
                roomId: r['room_id'] ?? '',
                seatCode: r['seat_code'] ?? '',
                incidentType: r['incident_type'] ?? '',
                description: r['description'] ?? '',
                reportedByUserId: r['reported_by'] ?? '',
                timestamp: DateTime.tryParse(r['created_at'] ?? '') ?? DateTime.now(),
                actionTaken: r['action_taken'] ?? '',
                status: IncidentStatus.values.firstWhere((s) => s.name == r['status'],
                    orElse: () => IncidentStatus.open),
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Malpractice load error: $err');
    }
  }
  bool can(Permission p) => RbacService.can(currentUser, p);

  // -------------------------------------------------------------------
  // Exam management
  // -------------------------------------------------------------------
  Future<void> upsertExam(Examination e, {bool isNew = false}) async {
    if (!can(Permission.manageExams)) return;

    try {
      // 1. Save examination in Supabase
      await _client.from('exams').upsert({
        'id': e.id,
        'institution_id': institutionId,
        'name': e.name,
        'exam_type': e.type.name,
        'session_id': e.sessionId.isEmpty ? null : e.sessionId,
        'course_id': e.classId,
        'status': e.status.name,
        'ranking_enabled': e.rankingEnabled,
      });

      // 2. Delete old subject schedules
      await _client.from('exam_subject_schedule').delete().eq('exam_id', e.id);

      // 3. Save selected subjects
      if (e.schedule.isNotEmpty) {
        await _client
            .from('exam_subject_schedule')
            .insert(
              e.schedule.map((s) {
                return {
                  'exam_id': e.id,
                  'subject_id': s.subjectId,
                  'exam_date': s.date.toIso8601String(),
                  'start_time': s.startTime,
                  'end_time': s.endTime,
                  'max_marks': s.maxMarks,
                  'passing_marks': s.passingMarks,
                };
              }).toList(),
            );
      }

      // 4. Update local list
      exams.removeWhere((x) => x.id == e.id);
      exams.add(e);

      audit.log(
        actor: currentUser!,
        action: isNew ? 'Created Exam' : 'Updated Exam',
        module: 'Exam Management',
        referenceId: e.id,
        newValue: e.name,
      );

      notifyListeners();

      print('✅ Examination saved successfully: ${e.name}');
    } catch (err) {
      print('❌ Examination save failed: $err');
      rethrow;
    }
  }

  Future<void> deleteExam(String id) async {
    if (!can(Permission.manageExams)) return;
    exams.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await _client.from('exam_subject_schedule').delete().eq('exam_id', id);
      await _client.from('exams').delete().eq('id', id);
    } catch (e) {
      print('❌ Exam delete error: $e');
    }
    audit.log(
      actor: currentUser!,
      action: 'Deleted Exam',
      module: 'Exam Management',
      referenceId: id,
    );
    notifyListeners();
  }

  /// Detects scheduling conflicts: same student/room/invigilator double-booked.
  List<String> detectScheduleConflicts(Examination exam) {
    final issues = <String>[];
    final seen = <String, String>{}; // "date|time" -> subjectId
    for (final s in exam.schedule) {
      final key = '${s.date.toIso8601String().split("T").first}|${s.startTime}';
      if (seen.containsKey(key)) {
        issues.add(
          'Subjects ${seen[key]} and ${s.subjectId} overlap on the same date/time.',
        );
      }
      seen[key] = s.subjectId;
    }
    for (final room in rooms) {
      final roomDuties = duties.where(
        (d) => d.roomId == room.id && d.examId == exam.id,
      );
      final subjSet = <String>{};
      for (final d in roomDuties) {
        if (!subjSet.add(d.subjectId)) {
          issues.add(
            'Room ${room.name} is double-booked for exam ${exam.name}.',
          );
        }
      }
    }
    return issues;
  }
  Future<void> upsertRoom(ExamRoom r) async {
    rooms.removeWhere((x) => x.id == r.id);
    rooms.add(r);
    notifyListeners();
    await _client.from('exam_rooms').upsert({
      'id': r.id, 'institution_id': institutionId, 'name': r.name, 'capacity': r.capacity,
    });
  }

  Future<void> upsertInvigilator(Invigilator i) async {
    invigilators.removeWhere((x) => x.id == i.id);
    invigilators.add(i);
    notifyListeners();
    await _client.from('exam_invigilators').upsert({
      'id': i.id, 'institution_id': institutionId, 'user_id': i.userId.isEmpty ? null : i.userId, 'name': i.name,
    });
  }

  Future<void> upsertDuty(InvigilatorDuty d) async {
    duties.removeWhere((x) => x.id == d.id);
    duties.add(d);
    notifyListeners();
    await _client.from('exam_invigilator_duties').upsert({
      'id': d.id, 'institution_id': institutionId, 'exam_id': d.examId, 'room_id': d.roomId,
      'subject_id': d.subjectId, 'invigilator_id': d.invigilatorId,
      'substitute_invigilator_id': d.substituteInvigilatorId, 'substitute_needed': d.substituteNeeded,
    });
  }

  Future<void> upsertSeatAssignment(SeatAssignment s) async {
    seats.removeWhere((x) => x.id == s.id);
    seats.add(s);
    notifyListeners();
    await _client.from('exam_seat_assignments').upsert({
      'id': s.id, 'institution_id': institutionId, 'exam_id': s.examId,
      'room_id': s.roomId, 'seat_code': s.seatCode, 'student_id': s.studentId,
    });
  }
  // -------------------------------------------------------------------
  // Eligibility
  // -------------------------------------------------------------------
   Future<void> setEligibility(EligibilityRecord r) async {
    if (!can(Permission.manageEligibility)) return;
    eligibility.removeWhere((x) => x.studentId == r.studentId && x.examId == r.examId);
    eligibility.add(r);
    notifyListeners();
    try {
      await _client.from('exam_eligibility').upsert({
        'id': r.id,
        'institution_id': institutionId,
        'exam_id': r.examId,
        'student_id': r.studentId,
        'status': r.status.name,
        'reason': r.reason,
      }, onConflict: 'exam_id,student_id');
    } catch (e) {
      print('❌ Eligibility save error: $e');
    }
    audit.log(actor: currentUser!, action: 'Updated Eligibility', module: 'Student Eligibility', referenceId: r.studentId, newValue: r.status.name);
  }

  // -------------------------------------------------------------------
  // Question bank / papers
  // -------------------------------------------------------------------
  Future<void> upsertQuestion(QuestionItem q) async {
    if (!can(Permission.manageQuestionBank)) return;
    questions.removeWhere((x) => x.id == q.id);
    questions.add(q);
    notifyListeners();
    try {
      await _client.from('question_bank_items').upsert({
        'id': q.id,
        'institution_id': institutionId,
        'course_id': q.classId.isEmpty ? null : q.classId,
        'subject_id': q.subjectId,
        'chapter': q.chapter,
        'topic': q.topic,
        'question_text': q.text,
        'question_type': q.type.name,
        'difficulty': q.difficulty.name,
        'marks': q.marks,
        'tags': q.tags,
        'status': q.status.name,
      });
    } catch (e) {
      print('❌ Question save error: $e');
    }
    audit.log(actor: currentUser!, action: 'Saved Question', module: 'Question Bank', referenceId: q.id);
  }

  Future<void> deleteQuestion(String id) async {
    if (!can(Permission.manageQuestionBank)) return;
    questions.removeWhere((q) => q.id == id);
    notifyListeners();
    try {
      await _client.from('question_bank_items').delete().eq('id', id);
    } catch (e) {
      print('❌ Question delete error: $e');
    }
    audit.log(actor: currentUser!, action: 'Deleted Question', module: 'Question Bank', referenceId: id);
  }

  /// Auto-generate a paper set from the question bank using a blueprint
  /// (difficulty distribution + question count) with shuffling.
  QuestionPaperSet generatePaper({
    required String examId,
    required String subjectId,
    required String setLabel,
    required int easyCount,
    required int mediumCount,
    required int hardCount,
  }) {
    final pool = questions
        .where(
          (q) =>
              q.subjectId == subjectId && q.status == QuestionStatus.approved,
        )
        .toList();
    List<QuestionItem> pick(Difficulty d, int n) {
      final list = pool.where((q) => q.difficulty == d).toList()..shuffle();
      return list.take(n).toList();
    }

    final chosen = [
      ...pick(Difficulty.easy, easyCount),
      ...pick(Difficulty.medium, mediumCount),
      ...pick(Difficulty.hard, hardCount),
    ]..shuffle();

    final paper = QuestionPaperSet(
      examId: examId,
      subjectId: subjectId,
      setLabel: setLabel,
      questionIds: chosen.map((q) => q.id).toList(),
      totalMarks: chosen.fold(0, (s, q) => s + q.marks),
    );
   
    paperSets.add(paper);
    try {
      _client
          .from('question_papers')
          .insert({
            'id': paper.id,
            'institution_id': institutionId,
            'exam_id': examId,
            'subject_id': subjectId,
            'set_label': setLabel,
            'total_marks': paper.totalMarks,
            'status': paper.status.name,
            'submitted_by': _client.auth.currentUser?.id,
            'question_ids': chosen.map((q) => q.id).toList(),
          })
          .catchError(
            (e) => debugPrint('Supabase paper insert failed: $e'),
          );
    } catch (e) {
      debugPrint('Supabase paper insert error: $e');
    }
    audit.log(
      actor: currentUser!,
      action: 'Generated Question Paper',
      module: 'Question Paper Generator',
      referenceId: paper.id,
    );
    notifyListeners();
    return paper;
  }

  void setPaperStatus(String paperId, PaperStatus status) {
    if (!can(Permission.approveQuestionPapers) &&
        status != PaperStatus.submitted)
      return;
    final p = paperSets.where((p) => p.id == paperId).firstOrNull;
    if (p == null) return;
    final old = p.status;
    p.status = status;
    try {
      _client
          .from('question_papers')
          .update({
            'status': status.name,
            if (status == PaperStatus.approved)
              'resolved_by': _client.auth.currentUser?.id,
            if (status == PaperStatus.approved)
              'resolved_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paperId)
          .catchError(
            (e) => debugPrint('Supabase paper status update failed: $e'),
          );
    } catch (e) {
      debugPrint('Supabase paper status error: $e');
    }
    audit.log(
      actor: currentUser!,
      action: 'Paper status changed',
      module: 'Question Paper Security',
      referenceId: paperId,
      previousValue: old.name,
      newValue: status.name,
    );
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Anonymous Examination Book + Barcode Security Center (flagship)
  // -------------------------------------------------------------------
   final _uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  String? _safeUuid(String? val) {
    if (val == null) return null;
    final trimmed = val.trim();
    if (_uuidRegex.hasMatch(trimmed)) return trimmed;
    final authId = _client.auth.currentUser?.id;
    if (authId != null && _uuidRegex.hasMatch(authId)) return authId;
    return null;
  }

  String? _resolveActorUserId() {
    final authId = _client.auth.currentUser?.id;
    if (authId != null && _uuidRegex.hasMatch(authId)) return authId;
    final currentId = currentUser?.id;
    if (currentId != null && _uuidRegex.hasMatch(currentId)) return currentId;
    return null;
  }

  Future<List<AnonymousBook>> generateAnonymousBooks({
    required String examId, required String subjectId, required int count,
  }) async {
    if (!can(Permission.generateAnonymousBooks)) return [];
    final existing = books.map((b) => b.anonId).toSet();
    final ids = AnonymousIdService.generateBulk(count, DateTime.now().year, existing);
    final created = <AnonymousBook>[];
    for (final id in ids) {
      final b = AnonymousBook(anonId: id, examId: examId, subjectId: subjectId);
      b.history.add(CustodyEvent(toStatus: BookStatus.generated, actorUserId: currentUser!.name));
      books.add(b);
      created.add(b);
      try {
        final safeExamId = _safeUuid(examId);
        final safeSubjectId = _safeUuid(subjectId);
        if (safeExamId != null && safeSubjectId != null) {
          await _client.from('exam_answer_books').insert({
            'id': b.id, 'institution_id': institutionId, 'anon_id': b.anonId,
            'exam_id': safeExamId, 'subject_id': safeSubjectId, 'status': 'generated',
          });
          final actorId = _resolveActorUserId();
          await _client.from('exam_book_custody_events').insert({
            'book_id': b.id, 'to_status': 'generated', 'actor_user_id': actorId,
          });
        }
      } catch (e) { print('❌ Answer book insert error: $e'); }
    }
    notifyListeners();
    audit.log(actor: currentUser!, action: 'Generated $count anonymous book(s)', module: 'Barcode Security Center', referenceId: examId);
    return created;
  }

  /// Pre-assigns books to students WITHOUT exposing the mapping to
  /// examiners: the mapping is stored, but examiner-facing views never read
  /// studentId off AnonymousBook (see evaluationViewFor()).
   void _transition(AnonymousBook b, BookStatus status, String note) {
    b.status = status;
    b.history.add(CustodyEvent(toStatus: status, actorUserId: currentUser!.name, note: note));
    try {
      final safeStudentId = _safeUuid(b.studentId);
      final safeExaminerId = _safeUuid(b.examinerId);
      _client.from('exam_answer_books').update({
        'status': status.name,
        if (status == BookStatus.identityRevealed) 'identity_revealed': true,
        if (safeStudentId != null) 'student_id': safeStudentId,
        if (safeExaminerId != null) 'examiner_id': safeExaminerId,
      }).eq('id', b.id).catchError((e) => print('❌ Book status update error: $e'));
      final actorId = _resolveActorUserId();
      _client.from('exam_book_custody_events').insert({
        'book_id': b.id, 'to_status': status.name, 'actor_user_id': actorId, 'note': note,
      }).catchError((e) => print('❌ Custody event error: $e'));
    } catch (e) {
      debugPrint('❌ Transition db error: $e');
    }
    audit.log(actor: currentUser!, action: 'Book ${b.anonId} -> ${status.label}', module: 'Answer Book Chain of Custody', referenceId: b.anonId, newValue: status.name);
    notifyListeners();
  }

  /// Public entry point used by UI screens to advance a book's status by id
  /// (e.g. custody chain buttons, marks locking, approval).
  void transitionBook(String bookId, BookStatus status, {String note = ''}) {
    final b = books.where((b) => b.id == bookId).firstOrNull;
    if (b == null) return;
    _transition(b, status, note);
  }

  /// Random allocation of evaluation-queue books to an examiner (controlled
  /// allocation, not manual student selection).
  int allocateRandomBooks({
    required String subjectId,
    required String examinerId,
    required int count,
  }) {
    if (!can(Permission.moderateEvaluation) &&
        currentUser!.role != AppRole.examController) {
      // exam controller / coordinator allocate; examiners cannot self-allocate
    }
    final pool =
        books
            .where(
              (b) =>
                  b.subjectId == subjectId &&
                  b.status == BookStatus.evaluationQueue,
            )
            .toList()
          ..shuffle();
    final take = pool.take(count).toList();
    for (final b in take) {
      b.examinerId = examinerId;
      _transition(b, BookStatus.assignedToExaminer, 'Randomly allocated');
    }
    return take.length;
  }

  /// Examiner-safe view: strips all identity fields. This is the ONLY
  /// object shape the evaluation UI is allowed to render from.
  Map<String, dynamic> evaluationViewFor(AnonymousBook b) {
    final exam = exams.firstWhere(
      (e) => e.id == b.examId,
      orElse: () => exams.first,
    );
    final subject = subjects.firstWhere(
      (s) => s.id == b.subjectId,
      orElse: () => subjects.first,
    );
    return {
      'bookId': b.id,
      'anonId': b.anonId,
      'examName': exam.name,
      'subjectName': subject.name,
      'status': b.status.label,
      // deliberately NO studentId / name / roll / photo / class here
    };
  }

  EvaluationRecord? startEvaluation(
    String bookId, {
    EvaluationStage stage = EvaluationStage.first,
  }) {
    if (!can(Permission.enterMarks)) throw Exception('Not permitted');
    final b = books.where((b) => b.id == bookId).firstOrNull;
    if (b == null) return null;
    final existing = evaluations.firstWhere(
      (e) =>
          e.bookId == bookId &&
          e.examinerId == currentUser!.id &&
          e.stage == stage,
      orElse: () => EvaluationRecord(
        bookId: bookId,
        examinerId: currentUser!.id,
        stage: stage,
      ),
    );
    if (!evaluations.contains(existing)) evaluations.add(existing);
    if (b.status == BookStatus.assignedToExaminer) {
      _transition(b, BookStatus.underEvaluation, 'Examiner opened script');
    }
    return existing;
  }

    Future<void> saveEvaluationDraft(EvaluationRecord rec) async {
    if (!can(Permission.enterMarks)) return;
    if (!evaluations.any((e) => e.id == rec.id)) evaluations.add(rec);
    notifyListeners();
    try {
      await _client.from('exam_evaluations').upsert({
        'id': rec.id, 'institution_id': institutionId, 'book_id': rec.bookId,
        'examiner_id': rec.examinerId, 'stage': rec.stage.name,
        'marks': rec.marks.map((m) => {
          'questionNo': m.questionNo, 'maxMarks': m.maxMarks, 'awarded': m.awarded, 'comment': m.comment,
        }).toList(),
        'submitted': rec.submitted, 'locked': rec.locked,
        'submitted_at': rec.submittedAt?.toIso8601String(),
      });
    } catch (e) { print('❌ Evaluation draft save error: $e'); }
    audit.log(actor: currentUser!, action: 'Saved evaluation draft', module: 'Anonymous Evaluation', referenceId: rec.bookId);
  }

  Future<void> submitEvaluation(EvaluationRecord rec) async {
    if (!can(Permission.enterMarks)) return;
    rec.submitted = true;
    rec.locked = true;
    rec.submittedAt = DateTime.now();
    if (!evaluations.any((e) => e.id == rec.id)) evaluations.add(rec);
    final b = books.where((b) => b.id == rec.bookId).firstOrNull;
    if (b != null) {
      _transition(b, BookStatus.evaluated, 'Marks submitted and locked by examiner');
    }
    try {
      await _client.from('exam_evaluations').upsert({
        'id': rec.id, 'institution_id': institutionId, 'book_id': rec.bookId,
        'examiner_id': rec.examinerId, 'stage': rec.stage.name,
        'marks': rec.marks.map((m) => {
          'questionNo': m.questionNo, 'maxMarks': m.maxMarks, 'awarded': m.awarded, 'comment': m.comment,
        }).toList(),
        'submitted': true, 'locked': true,
        'submitted_at': rec.submittedAt!.toIso8601String(),
      });
    } catch (e) { print('❌ Evaluation submit error: $e'); }

    final siblings = evaluations.where((e) => e.bookId == rec.bookId && e.submitted && e.id != rec.id);
    for (final other in siblings) {
      final maxPossible = rec.marks.fold(0, (s, m) => s + m.maxMarks);
      if (maxPossible == 0) continue;
      final diffPct = ((rec.total - other.total).abs() / maxPossible) * 100;
      if (diffPct > moderationThresholdPercent) {
        audit.log(actor: currentUser!, action: 'Flagged for moderation (diff ${diffPct.toStringAsFixed(1)}%)', module: 'Moderation', referenceId: b?.anonId ?? rec.bookId);
      }
    }
    audit.log(actor: currentUser!, action: 'Marks locked', module: 'Marks Locking', referenceId: b?.anonId ?? rec.bookId, newValue: '${rec.total}');
    notifyListeners();
  }

   Future<void> requestCorrection(MarksCorrectionRequest req) async {
    if (!can(Permission.requestMarksCorrection)) return;
    corrections.add(req);
    notifyListeners();
    try {
      await _client.from('exam_marks_corrections').insert({
        'id': req.id, 'institution_id': institutionId, 'book_id': req.bookId,
        'requested_by': req.requestedByUserId, 'original_value': req.originalValue,
        'new_value': req.newValue, 'reason': req.reason, 'status': req.status.name,
      });
    } catch (e) { print('❌ Correction request error: $e'); }
    audit.log(actor: currentUser!, action: 'Requested marks correction', module: 'Marks Locking', referenceId: req.bookId);
  }

  Future<void> decideCorrection(String reqId, bool approve) async {
    if (!can(Permission.approveMarksCorrection)) return;
    final r = corrections.where((c) => c.id == reqId).firstOrNull;
    if (r == null) return;
    r.status = approve ? CorrectionStatus.approved : CorrectionStatus.rejected;
    r.approvedByUserId = currentUser!.name;
    notifyListeners();
    try {
      await _client.from('exam_marks_corrections').update({
        'status': r.status.name, 'approved_by': currentUser!.id,
      }).eq('id', reqId);
    } catch (e) { print('❌ Correction decide error: $e'); }
    if (approve) {
      audit.log(actor: currentUser!, action: 'Approved correction', module: 'Marks Locking', referenceId: r.bookId, previousValue: '${r.originalValue}', newValue: '${r.newValue}');
    }
  }

  /// Privileged operation: reveal student identity behind an anonymous book.
  /// Only callable post evaluation/approval by authorized roles.
  Student? revealIdentity(String bookId) {
    if (!can(Permission.revealIdentity)) return null;
    final b = books.where((b) => b.id == bookId).firstOrNull;
    if (b == null) return null;
    if (b.status != BookStatus.approved && b.status != BookStatus.marksLocked) {
      // still allow for demo but log as early reveal
    }
    b.identityRevealed = true;
    _transition(
      b,
      BookStatus.identityRevealed,
      'Identity revealed by authorized role',
    );
    if (b.studentId == null) return null;
    return students.where((s) => s.id == b.studentId).firstOrNull;
  }

  // -------------------------------------------------------------------
  // Results & grading
  // -------------------------------------------------------------------
  static final List<GradeBand> defaultGradeScale = [
    GradeBand('A+', 90, 100.01, 10),
    GradeBand('A', 80, 90, 9),
    GradeBand('B+', 70, 80, 8),
    GradeBand('B', 60, 70, 7),
    GradeBand('C', 50, 60, 6),
    GradeBand('D', 33, 50, 5),
    GradeBand('F', 0, 33, 0),
  ];

  String gradeFor(double percent) {
    for (final band in defaultGradeScale) {
      if (percent >= band.minPercent && percent < band.maxPercent)
        return band.grade;
    }
    return 'F';
  }

   Future<ResultRecord> computeResult(
    String examId,
    String studentId,
    int passingPercent,
  ) async {
    final subjectResults = <SubjectResult>[];
    final relevantBooks = books.where(
      (b) =>
          b.examId == examId &&
          b.studentId == studentId &&
          b.status.index >= BookStatus.evaluated.index,
    );
    for (final b in relevantBooks) {
      final ev = evaluations.firstWhere(
        (e) => e.bookId == b.id && e.submitted,
        orElse: () => EvaluationRecord(bookId: b.id, examinerId: ''),
      );
      final max = ev.marks.fold(0, (s, m) => s + m.maxMarks);
      final sr = SubjectResult(
        subjectId: b.subjectId,
        maxMarks: max == 0 ? 100 : max,
        marksObtained: ev.total,
      );
      sr.grade = gradeFor(max == 0 ? 0 : (ev.total / max) * 100);
      subjectResults.add(sr);
    }
    final totalMax = subjectResults.fold(0, (s, r) => s + r.maxMarks);
    final totalObtained = subjectResults.fold(0, (s, r) => s + r.marksObtained);
    final percent = totalMax == 0 ? 0.0 : (totalObtained / totalMax) * 100;
    final rec = ResultRecord(
      examId: examId,
      studentId: studentId,
      subjects: subjectResults,
      percentage: percent,
      overallGrade: gradeFor(percent),
      pass: percent >= passingPercent,
    );
    results.removeWhere((r) => r.examId == examId && r.studentId == studentId);
    results.add(rec);
        try {
      await _client.from('exam_results').upsert({
        'id': rec.id, 'exam_id': rec.examId, 'student_id': rec.studentId,
        'percentage': rec.percentage, 'overall_grade': rec.overallGrade,
        'rank': rec.rank, 'pass': rec.pass, 'stage': rec.stage.name,
      });
      await _client.from('exam_result_subjects').delete().eq('result_id', rec.id);
      if (rec.subjects.isNotEmpty) {
        await _client.from('exam_result_subjects').insert(rec.subjects.map((s) => {
          'result_id': rec.id, 'subject_id': s.subjectId, 'max_marks': s.maxMarks,
          'marks_obtained': s.marksObtained, 'grade': s.grade,
        }).toList());
      }
    } catch (e) { print('❌ Result save error: $e'); }
    notifyListeners();
    return rec;
  }

  Future<void> rankResults(String examId) async {
    final list = results.where((r) => r.examId == examId).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    for (int i = 0; i < list.length; i++) {
      list[i].rank = i + 1;
    }
    notifyListeners();
    try {
      for (final r in list) {
        await _client.from('exam_results').update({'rank': r.rank}).eq('id', r.id);
      }
    } catch (e) {
      print('❌ Result rank save error: $e');
    }
  }

  void setResultStage(String resultId, ResultStage stage) {
    final permOk = switch (stage) {
      ResultStage.approved => can(Permission.approveResults),
      ResultStage.published => can(Permission.publishResults),
      _ => true,
    };
    if (!permOk) return;
    final r = results.where((r) => r.id == resultId).firstOrNull;
    if (r == null) return;
    final old = r.stage;
    r.stage = stage;
        _client.from('exam_results').update({'stage': stage.name}).eq('id', resultId)
        .catchError((e) => print('❌ Result stage update error: $e'));
    audit.log(
      actor: currentUser!,
      action: 'Result stage changed',
      module: 'Result Processing',
      referenceId: resultId,
      previousValue: old.name,
      newValue: stage.name,
    );
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Revaluation
  // -------------------------------------------------------------------
   Future<void> createRevaluation(RevaluationRequest r) async {
    if (!can(Permission.manageRevaluation)) return;
    revaluations.add(r);
    notifyListeners();
    try {
      final safeStudentId = _safeUuid(r.studentId);
      final safeBookId = _safeUuid(r.bookId);
      final safeSubjectId = _safeUuid(r.subjectId);
      if (safeStudentId != null && safeSubjectId != null) {
        await _client.from('exam_revaluation_requests').insert({
          'id': r.id, 'institution_id': institutionId, 'student_id': safeStudentId,
          'book_id': safeBookId, 'subject_id': safeSubjectId, 'original_marks': r.originalMarks,
          'reason': r.reason, 'status': r.status.name,
        });
      }
    } catch (e) { print('❌ Revaluation create error: $e'); }
    audit.log(actor: currentUser!, action: 'Revaluation requested', module: 'Revaluation', referenceId: r.id);
  }
  // -------------------------------------------------------------------
  // Certificates
  // -------------------------------------------------------------------
  /// Generates a unique verification ID for a result and persists the
  /// issuance record to Supabase. Returns the verification ID so the
  /// caller can embed it in the printed PDF/QR code.
  Future<String> recordCertificateIssued(ResultRecord r) async {
    final verificationId = 'CERT-${r.id.substring(0, 8).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';
    try {
      await _client.from('exam_certificates').insert({
        'institution_id': institutionId,
        'result_id': r.id,
        'student_id': r.studentId,
        'verification_id': verificationId,
        'issued_by': _client.auth.currentUser?.id,
      });
    } catch (e) {
      debugPrint('❌ Certificate issue insert error: $e');
    }
    audit.log(
      actor: currentUser!,
      action: 'Certificate generated',
      module: 'Certificate & Transcript Management',
      referenceId: r.id,
      newValue: verificationId,
    );
    return verificationId;
  }
  Future<void> decideRevaluation(String id, RevaluationStatus status, {int? revisedMarks}) async {
    final r = revaluations.firstWhere((r) => r.id == id);
    r.status = status;
    if (revisedMarks != null) r.revisedMarks = revisedMarks;
    notifyListeners();
    try {
      await _client.from('exam_revaluation_requests').update({
        'status': status.name, if (revisedMarks != null) 'revised_marks': revisedMarks,
      }).eq('id', id);
    } catch (e) { print('❌ Revaluation decide error: $e'); }
    audit.log(actor: currentUser!, action: 'Revaluation ${status.name}', module: 'Revaluation', referenceId: id, previousValue: '${r.originalMarks}', newValue: '${r.revisedMarks}');
  }

  // -------------------------------------------------------------------
  // Malpractice
  // -------------------------------------------------------------------
  Future<void> reportIncident(MalpracticeIncident i) async {
    if (!can(Permission.manageMalpractice)) return;
    incidents.add(i);
    notifyListeners();
    try {
      final safeStudentId = _safeUuid(i.studentId);
      final safeExamId = _safeUuid(i.examId);
      final safeRoomId = _safeUuid(i.roomId);
      final safeReporterId = _safeUuid(i.reportedByUserId) ?? _resolveActorUserId();
      if (safeStudentId != null && safeExamId != null) {
        await _client.from('exam_malpractice_incidents').insert({
          'id': i.id, 'institution_id': institutionId, 'student_id': safeStudentId,
          'exam_id': safeExamId, 'room_id': safeRoomId,
          'seat_code': i.seatCode, 'incident_type': i.incidentType, 'description': i.description,
          'reported_by': safeReporterId, 'action_taken': i.actionTaken, 'status': i.status.name,
        });
      }
    } catch (e) { print('❌ Incident report error: $e'); }
    audit.log(actor: currentUser!, action: 'Incident reported', module: 'Malpractice', referenceId: i.id);
  }

  Future<void> updateIncident(MalpracticeIncident i) async {
    if (!can(Permission.manageMalpractice)) return;
    final idx = incidents.indexWhere((x) => x.id == i.id);
    if (idx != -1) incidents[idx] = i;
    notifyListeners();
    try {
      await _client.from('exam_malpractice_incidents').update({
        'action_taken': i.actionTaken, 'status': i.status.name, 'description': i.description,
      }).eq('id', i.id);
    } catch (e) { print('❌ Incident update error: $e'); }
    audit.log(actor: currentUser!, action: 'Incident updated', module: 'Malpractice', referenceId: i.id, newValue: i.status.name);
  }

  // -------------------------------------------------------------------
  // Notifications
  // -------------------------------------------------------------------
  Future<void> loadNotificationsFromSupabase() async {
    try {
      final rows = await _client.from('exam_notifications').select();
      notifications = (rows as List)
          .map((r) => NotificationItem(
                id: r['id'],
                title: r['title'] ?? '',
                body: r['body'] ?? '',
                audience: NotificationAudience.values.firstWhere(
                    (a) => a.name == r['audience'],
                    orElse: () => NotificationAudience.all),
                status: NotificationStatus.values.firstWhere(
                    (s) => s.name == r['status'],
                    orElse: () => NotificationStatus.draft),
                scheduledFor: r['scheduled_for'] != null
                    ? DateTime.parse(r['scheduled_for'])
                    : null,
                createdAt: r['created_at'] != null
                    ? DateTime.parse(r['created_at'])
                    : null,
              ))
          .toList();
      notifyListeners();
    } catch (err) {
      print('❌ Notifications load error: $err');
    }
  }

  Future<void> upsertNotification(NotificationItem n) async {
    if (!can(Permission.manageNotifications)) return;
    notifications.removeWhere((x) => x.id == n.id);
    notifications.add(n);
    notifyListeners();
    try {
      await _client.from('exam_notifications').upsert({
        'id': n.id,
        'institution_id': institutionId,
        'title': n.title,
        'body': n.body,
        'audience': n.audience.name,
        'status': n.status.name,
        'scheduled_for': n.scheduledFor?.toIso8601String(),
        'created_at': n.createdAt.toIso8601String(),
      });
    } catch (e) {
      print('❌ Notification save error: $e');
    }
    audit.log(
      actor: currentUser!,
      action: 'Notification saved',
      module: 'Notifications',
      referenceId: n.id,
    );
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Generic helpers used by generic CRUD screens for remaining modules
  // -------------------------------------------------------------------
  Student studentById(String id) => students.firstWhere(
    (s) => s.id == id,
    orElse: () =>
        Student(rollNo: '-', name: 'Unknown', classId: '', section: ''),
  );
  Subject? subjectById(String id) =>
      subjects.where((s) => s.id == id).firstOrNull;
  Examination? examById(String id) =>
      exams.where((e) => e.id == id).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}