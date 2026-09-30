import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/modules/examination/models/models.dart';
import 'package:edusmart_school_erp_flutter/modules/examination/state/app_store.dart';
import 'package:edusmart_school_erp_flutter/modules/examination/services/security_services.dart';
import 'package:edusmart_school_erp_flutter/modules/examination/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 Section 4.8: Examination & Grading Lifecycle Tests', () {
    late AppStore store;

    setUp(() {
      store = AppStore();
    });

    test('1. Exam Scheduling & Room Seating Allocation: Conflict detection and seat allocation', () {
      // 1.1 Create Exam with schedule
      final exam = Examination(
        id: 'exam-term-1',
        name: 'Annual Examination 2026',
        type: ExamType.annual,
        sessionId: 'session-2026',
        classId: 'class-10',
        sections: ['A', 'B'],
        rankingEnabled: true,
        status: ExamStatus.scheduled,
        schedule: [
          ExamSubjectSchedule(
            subjectId: 'sub-math',
            date: DateTime(2026, 10, 15),
            startTime: '09:00',
            endTime: '12:00',
            maxMarks: 100,
            passingMarks: 33,
          ),
          ExamSubjectSchedule(
            subjectId: 'sub-science',
            date: DateTime(2026, 10, 17),
            startTime: '09:00',
            endTime: '12:00',
            maxMarks: 100,
            passingMarks: 33,
          ),
        ],
      );

      // Verify no conflict on distinct dates
      final conflicts = store.detectScheduleConflicts(exam);
      expect(conflicts, isEmpty);

      // 1.2 Inject overlapping conflict on same date and time
      final conflictingExam = Examination(
        id: 'exam-conflict',
        name: 'Conflicting Exam',
        type: ExamType.unitTest,
        sessionId: 'session-2026',
        classId: 'class-10',
        sections: ['A'],
        schedule: [
          ExamSubjectSchedule(
            subjectId: 'sub-math',
            date: DateTime(2026, 10, 15),
            startTime: '09:00',
            endTime: '12:00',
            maxMarks: 100,
            passingMarks: 33,
          ),
          ExamSubjectSchedule(
            subjectId: 'sub-physics',
            date: DateTime(2026, 10, 15),
            startTime: '09:00',
            endTime: '11:30',
            maxMarks: 100,
            passingMarks: 33,
          ),
        ],
      );
      final detected = store.detectScheduleConflicts(conflictingExam);
      expect(detected, isNotEmpty);
      expect(detected.first, contains('overlap'));

      // 1.3 Room capacity and seat allocation
      final room = ExamRoom(id: 'room-101', name: 'Exam Hall A', capacity: 30);
      store.rooms.add(room);
      store.exams.add(exam);

      // Generate 30 seats for room
      for (int i = 0; i < room.capacity; i++) {
        final code = 'A${(i + 1).toString().padLeft(2, '0')}';
        store.seats.add(SeatAssignment(
          examId: exam.id,
          roomId: room.id,
          seatCode: code,
          studentId: 'student-${i + 1}',
        ));
      }

      final roomSeats = store.seats.where((s) => s.roomId == room.id).toList();
      expect(roomSeats.length, equals(30));
      // Ensure zero over-allocation
      expect(roomSeats.length, lessThanOrEqualTo(room.capacity));
      // Ensure unique seat codes
      final uniqueCodes = roomSeats.map((s) => s.seatCode).toSet();
      expect(uniqueCodes.length, equals(30));
      expect(roomSeats.first.seatCode, equals('A01'));
      expect(roomSeats.last.seatCode, equals('A30'));
    });

    test('2. Question Paper Generator: Blueprint difficulty distribution and set generation', () {
      final subjectId = 'sub-physics-101';
      // Seed question pool with known difficulty distribution
      store.questions.clear();
      for (int i = 1; i <= 10; i++) {
        store.questions.add(QuestionItem(
          id: 'q-easy-$i',
          text: 'Easy Question $i',
          classId: '10',
          subjectId: subjectId,
          type: QuestionType.mcq,
          difficulty: Difficulty.easy,
          marks: 2,
          status: QuestionStatus.approved,
        ));
      }
      for (int i = 1; i <= 10; i++) {
        store.questions.add(QuestionItem(
          id: 'q-med-$i',
          text: 'Medium Question $i',
          classId: '10',
          subjectId: subjectId,
          type: QuestionType.shortAnswer,
          difficulty: Difficulty.medium,
          marks: 4,
          status: QuestionStatus.approved,
        ));
      }
      for (int i = 1; i <= 10; i++) {
        store.questions.add(QuestionItem(
          id: 'q-hard-$i',
          text: 'Hard Question $i',
          classId: '10',
          subjectId: subjectId,
          type: QuestionType.longAnswer,
          difficulty: Difficulty.hard,
          marks: 10,
          status: QuestionStatus.approved,
        ));
      }

      // Generate Set A: 4 Easy (8 marks) + 4 Medium (16 marks) + 2 Hard (20 marks) = 10 questions, 44 marks
      final setA = store.generatePaper(
        examId: 'exam-midterm',
        subjectId: subjectId,
        setLabel: 'A',
        easyCount: 4,
        mediumCount: 4,
        hardCount: 2,
      );

      expect(setA.setLabel, equals('A'));
      expect(setA.questionIds.length, equals(10));
      expect(setA.totalMarks, equals(44));
      expect(setA.status, equals(PaperStatus.draft));

      // Generate Set B with different distribution
      final setB = store.generatePaper(
        examId: 'exam-midterm',
        subjectId: subjectId,
        setLabel: 'B',
        easyCount: 5,
        mediumCount: 3,
        hardCount: 1,
      );

      expect(setB.setLabel, equals('B'));
      expect(setB.questionIds.length, equals(9));
      expect(setB.totalMarks, equals(32));

      // Paper sets stored in AppStore
      expect(store.paperSets.any((p) => p.id == setA.id), isTrue);
      expect(store.paperSets.any((p) => p.id == setB.id), isTrue);
    });

    test('3. Anonymous Barcoded Answer Books: Cryptographic generation and examiner identity concealment', () async {
      // 3.1 Bulk generate unique IDs
      final existingIds = <String>{};
      final generatedIds = AnonymousIdService.generateBulk(25, 2026, existingIds);

      expect(generatedIds.length, equals(25));
      // All IDs match EXM26-XXXX-XXXX format
      for (final id in generatedIds) {
        expect(id, matches(r'^EXM26-[A-Z0-9]{4}-[A-Z0-9]{4}$'));
      }
      // Zero duplicate IDs
      expect(generatedIds.toSet().length, equals(25));

      // 3.2 Generate anonymous books in store
      store.currentUser = AppUser(
        id: 'usr-controller',
        name: 'Exam Controller',
        email: 'controller@edusmart.local',
        role: AppRole.examController,
      );

      final books = await store.generateAnonymousBooks(
        examId: 'exam-board-2026',
        subjectId: 'sub-chem',
        count: 5,
      );
      expect(books.length, equals(5));

      // 3.3 Verify examiner-safe view strips all student identifying fields
      final book = books.first;
      book.studentId = 'student-confidential-uuid-999';

      final safeView = store.evaluationViewFor(book);
      expect(safeView['anonId'], equals(book.anonId));
      expect(safeView.containsKey('studentId'), isFalse);
      expect(safeView.containsKey('name'), isFalse);
      expect(safeView.containsKey('rollNo'), isFalse);
      expect(safeView.containsKey('classNum'), isFalse);
    });

    test('4. Marks Entry, Moderation & Result Compilation: Threshold flagging and class ranking', () async {
      final examId = 'exam-comp-2026';
      final bookId = 'book-test-101';

      final studentA = 'stu-001';
      final studentB = 'stu-002';
      final studentC = 'stu-003';

      // 4.1 Evaluation & Double Evaluation Moderation Flag
      store.currentUser = AppUser(
        id: 'eval-1',
        name: 'Evaluator One',
        email: 'eval1@edusmart.local',
        role: AppRole.examiner,
      );
      store.books.add(AnonymousBook(
        id: bookId,
        anonId: 'EXM26-AAAA-BBBB',
        examId: examId,
        subjectId: 'sub-math',
        status: BookStatus.underEvaluation,
      ));

      // First Evaluation: 90 / 100
      final eval1 = EvaluationRecord(
        id: 'eval-rec-1',
        bookId: bookId,
        examinerId: 'eval-1',
        stage: EvaluationStage.first,
        marks: [
          QuestionMark(questionNo: '1', maxMarks: 50, awarded: 45),
          QuestionMark(questionNo: '2', maxMarks: 50, awarded: 45),
        ],
      );
      await store.submitEvaluation(eval1);
      expect(eval1.submitted, isTrue);
      expect(eval1.locked, isTrue);
      expect(eval1.total, equals(90));

      // Second Evaluation with >10% divergence: 70 / 100 (Difference is 20% > 10% threshold)
      store.currentUser = AppUser(
        id: 'eval-2',
        name: 'Evaluator Two',
        email: 'eval2@edusmart.local',
        role: AppRole.examiner,
      );
      final eval2 = EvaluationRecord(
        id: 'eval-rec-2',
        bookId: bookId,
        examinerId: 'eval-2',
        stage: EvaluationStage.second,
        marks: [
          QuestionMark(questionNo: '1', maxMarks: 50, awarded: 35),
          QuestionMark(questionNo: '2', maxMarks: 50, awarded: 35),
        ],
      );
      await store.submitEvaluation(eval2);

      // Verify moderation audit entry was created for >10% diff
      final moderationAudit = store.audit.entries.where((e) => e.module == 'Moderation').toList();
      expect(moderationAudit, isNotEmpty);
      expect(moderationAudit.first.action, contains('Flagged for moderation'));

      // 4.2 Compile results for multiple students
      store.results.clear();
      store.results.addAll([
        ResultRecord(
          id: 'res-1',
          examId: examId,
          studentId: studentA,
          percentage: 78.5,
          overallGrade: 'B+',
          pass: true,
          subjects: [],
        ),
        ResultRecord(
          id: 'res-2',
          examId: examId,
          studentId: studentB,
          percentage: 95.0,
          overallGrade: 'A+',
          pass: true,
          subjects: [],
        ),
        ResultRecord(
          id: 'res-3',
          examId: examId,
          studentId: studentC,
          percentage: 42.0,
          overallGrade: 'C',
          pass: true,
          subjects: [],
        ),
      ]);

      // 4.3 Compute Rankings
      await store.rankResults(examId);

      final rA = store.results.firstWhere((r) => r.studentId == studentA);
      final rB = store.results.firstWhere((r) => r.studentId == studentB);
      final rC = store.results.firstWhere((r) => r.studentId == studentC);

      // Rank 1: studentB (95%), Rank 2: studentA (78.5%), Rank 3: studentC (42%)
      expect(rB.rank, equals(1));
      expect(rA.rank, equals(2));
      expect(rC.rank, equals(3));
    });

    test('5. Malpractice Logging: Incident logging, audit trail and status resolution', () async {
      store.currentUser = AppUser(
        id: 'invig-1',
        name: 'Room 204 Invigilator',
        email: 'invig1@edusmart.local',
        role: AppRole.invigilator,
      );

      final incident = MalpracticeIncident(
        id: 'mal-2026-01',
        examId: 'exam-term-1',
        studentId: 'student-99',
        roomId: 'room-204',
        seatCode: 'B-14',
        incidentType: 'Confiscated unauthorized handwritten notes',
        description: 'Student possessed notes for physics formulas behind calculator',
        reportedByUserId: 'invig-1',
        actionTaken: 'Material seized, preliminary report filed',
        status: IncidentStatus.open,
      );

      // Report incident
      await store.reportIncident(incident);

      expect(store.incidents.any((i) => i.id == incident.id), isTrue);
      final auditLog = store.audit.entries.where((e) => e.module == 'Malpractice');
      expect(auditLog, isNotEmpty);
      expect(auditLog.first.action, equals('Incident reported'));

      // Update incident resolution
      store.currentUser = AppUser(
        id: 'admin-1',
        name: 'Exam Controller',
        email: 'admin1@edusmart.local',
        role: AppRole.examController,
      );
      final updated = MalpracticeIncident(
        id: incident.id,
        examId: incident.examId,
        studentId: incident.studentId,
        roomId: incident.roomId,
        seatCode: incident.seatCode,
        incidentType: incident.incidentType,
        description: incident.description,
        reportedByUserId: incident.reportedByUserId,
        actionTaken: 'Cancelled paper for current subject and issued warning',
        status: IncidentStatus.actionTaken,
      );

      await store.updateIncident(updated);
      final storedIncident = store.incidents.firstWhere((i) => i.id == incident.id);
      expect(storedIncident.status, equals(IncidentStatus.actionTaken));
      expect(storedIncident.actionTaken, contains('Cancelled paper'));
    });

    test('6. PDF Generation & QR Code Verification: Admit card and certificate byte streams', () async {
      final student = Student(
        id: 'stu-pdf-01',
        rollNo: 'ROLL-1001',
        name: 'Diya Patel',
        classId: '10',
        section: 'A',
      );

      final exam = Examination(
        id: 'exam-final',
        name: 'Annual Examination 2026',
        type: ExamType.annual,
        sessionId: 'session-2026',
        classId: '10',
        sections: ['A'],
        schedule: [
          ExamSubjectSchedule(
            subjectId: 's-1',
            date: DateTime(2026, 10, 15),
            startTime: '09:00',
            endTime: '12:00',
            maxMarks: 100,
            passingMarks: 33,
          ),
        ],
      );

      final subjects = [
        Subject(id: 's-1', name: 'Mathematics', code: 'MATH10', classId: '10'),
        Subject(id: 's-2', name: 'English Literature', code: 'ENG10', classId: '10'),
      ];

      final result = ResultRecord(
        id: 'res-cert-01',
        examId: exam.id,
        studentId: student.id,
        percentage: 88.5,
        overallGrade: 'A',
        pass: true,
        subjects: [
          SubjectResult(subjectId: 's-1', maxMarks: 100, marksObtained: 90, grade: 'A+'),
          SubjectResult(subjectId: 's-2', maxMarks: 100, marksObtained: 87, grade: 'A'),
        ],
      );

      // 6.1 Build Admit Card Document
      final admitDoc = PdfService.buildAdmitCardDoc(student, exam, subjects);
      final admitBytes = await admitDoc.save();

      expect(admitBytes, isNotEmpty);
      // Valid PDF magic header bytes "%PDF-"
      final pdfMagicHeader = String.fromCharCodes(admitBytes.sublist(0, 5));
      expect(pdfMagicHeader, equals('%PDF-'));

      // 6.2 Build Certificate Document
      final certDoc = PdfService.buildCertificateDoc(
        student,
        exam,
        result,
        subjects,
        verificationId: 'CERT-2026-DIYA-885',
        schoolName: 'EduSmart Model School',
      );
      final certBytes = await certDoc.save();

      expect(certBytes, isNotEmpty);
      final certMagicHeader = String.fromCharCodes(certBytes.sublist(0, 5));
      expect(certMagicHeader, equals('%PDF-'));
    });

    test('7. RBAC Governance: Permission matrix checks and paper approval workflow', () {
      final superAdmin = AppUser(
        id: 'u-admin',
        name: 'Super Admin',
        email: 'superadmin@edusmart.local',
        role: AppRole.superAdmin,
      );
      final controller = AppUser(
        id: 'u-ctrl',
        name: 'Controller',
        email: 'controller@edusmart.local',
        role: AppRole.examController,
      );
      final examiner = AppUser(
        id: 'u-exam',
        name: 'Examiner',
        email: 'examiner@edusmart.local',
        role: AppRole.examiner,
      );
      final student = AppUser(
        id: 'u-stu',
        name: 'Student',
        email: 'student@edusmart.local',
        role: AppRole.student,
      );

      // Controller and SuperAdmin can approve papers; Examiner and Student CANNOT
      expect(RbacService.can(superAdmin, Permission.approveQuestionPapers), isTrue);
      expect(RbacService.can(controller, Permission.approveQuestionPapers), isTrue);
      expect(RbacService.can(examiner, Permission.approveQuestionPapers), isFalse);
      expect(RbacService.can(student, Permission.approveQuestionPapers), isFalse);

      // Examiner can enter marks; Student CANNOT
      expect(RbacService.can(examiner, Permission.enterMarks), isTrue);
      expect(RbacService.can(student, Permission.enterMarks), isFalse);

      // Student can view own results; cannot moderate
      expect(RbacService.can(student, Permission.viewOwnResults), isTrue);
      expect(RbacService.can(student, Permission.moderateEvaluation), isFalse);

      // Paper status transition gate in AppStore
      final paper = QuestionPaperSet(
        id: 'paper-workflow',
        examId: 'exam-1',
        subjectId: 'sub-1',
        setLabel: 'A',
        totalMarks: 100,
        status: PaperStatus.draft,
      );
      store.paperSets.add(paper);

      // Attempt approval as examiner (Unauthorized)
      store.currentUser = examiner;
      store.setPaperStatus(paper.id, PaperStatus.approved);
      // Status must NOT change
      expect(paper.status, equals(PaperStatus.draft));

      // Examiner CAN submit draft to submitted
      store.setPaperStatus(paper.id, PaperStatus.submitted);
      expect(paper.status, equals(PaperStatus.submitted));

      // Controller approves (Authorized)
      store.currentUser = controller;
      store.setPaperStatus(paper.id, PaperStatus.approved);
      expect(paper.status, equals(PaperStatus.approved));
    });
  });
}
