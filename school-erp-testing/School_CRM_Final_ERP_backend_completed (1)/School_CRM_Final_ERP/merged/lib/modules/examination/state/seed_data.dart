import '../models/models.dart';
import '../services/security_services.dart';

/// Generates realistic, clearly-labelled DEMO data so every module is
/// testable immediately. In production this class is simply not called --
/// the repositories would be backed by a real API/database instead.
class SeedBundle {
  final List<AppUser> users;
  final List<AcademicSession> sessions;
  final List<SchoolClass> classes;
  final List<Subject> subjects;
  final List<Examination> exams;
  final List<Student> students;
  final List<EligibilityRecord> eligibility;
  final List<AccommodationRecord> accommodations;
  final List<QuestionItem> questions;
  final List<QuestionPaperSet> paperSets;
  final List<ExamRoom> rooms;
  final List<Invigilator> invigilators;
  final List<InvigilatorDuty> duties;
  final List<SeatAssignment> seats;
  final List<AnonymousBook> books;
  final List<EvaluationRecord> evaluations;
  final List<ResultRecord> results;
  final List<MalpracticeIncident> incidents;
  final List<NotificationItem> notifications;

  SeedBundle({
    required this.users,
    required this.sessions,
    required this.classes,
    required this.subjects,
    required this.exams,
    required this.students,
    required this.eligibility,
    required this.accommodations,
    required this.questions,
    required this.paperSets,
    required this.rooms,
    required this.invigilators,
    required this.duties,
    required this.seats,
    required this.books,
    required this.evaluations,
    required this.results,
    required this.incidents,
    required this.notifications,
  });
}

class SeedData {
  static SeedBundle generate() {
    final users = [
      AppUser(id: 'u_super', name: 'Anita Rao', email: 'admin@sunrise.edu', role: AppRole.superAdmin),
      AppUser(id: 'u_ctrl', name: 'Vikram Sharma', email: 'controller@sunrise.edu', role: AppRole.examController),
      AppUser(id: 'u_coord', name: 'Priya Verma', email: 'coordinator@sunrise.edu', role: AppRole.examCoordinator),
      AppUser(id: 'u_examiner1', name: 'Rajesh Kumar', email: 'rajesh@sunrise.edu', role: AppRole.examiner, subjectSpecialization: 'Mathematics'),
      AppUser(id: 'u_examiner2', name: 'Sunita Iyer', email: 'sunita@sunrise.edu', role: AppRole.examiner, subjectSpecialization: 'Science'),
      AppUser(id: 'u_invig1', name: 'Amit Singh', email: 'amit@sunrise.edu', role: AppRole.invigilator),
      AppUser(id: 'u_student1', name: 'Aarav Sharma', email: 'aarav@student.sunrise.edu', role: AppRole.student, classSection: '10-A'),
      AppUser(id: 'u_parent1', name: 'Mrs. Sharma', email: 'parent.sharma@sunrise.edu', role: AppRole.parent),
    ];

    final sessions = [AcademicSession(id: 's1', label: '2025-26')];

    final classes = [
      SchoolClass(id: 'c9', name: '9th', sections: ['A', 'B']),
      SchoolClass(id: 'c10', name: '10th', sections: ['A', 'B', 'C']),
    ];

    final subjects = [
      Subject(id: 'sub_math', name: 'Mathematics', code: 'MATH', classId: 'c10'),
      Subject(id: 'sub_sci', name: 'Science', code: 'SCI', classId: 'c10'),
      Subject(id: 'sub_eng', name: 'English', code: 'ENG', classId: 'c10'),
      Subject(id: 'sub_sst', name: 'Social Science', code: 'SST', classId: 'c10'),
      Subject(id: 'sub_hin', name: 'Hindi', code: 'HIN', classId: 'c10'),
    ];

    final examDate = DateTime(2026, 5, 20);
    final exam = Examination(
      id: 'exam_annual26',
      name: 'Annual Examination 2026',
      type: ExamType.annual,
      sessionId: 's1',
      classId: 'c10',
      sections: ['A', 'B', 'C'],
      schedule: [
        ExamSubjectSchedule(subjectId: 'sub_math', date: examDate, startTime: '09:00 AM', endTime: '12:00 PM', maxMarks: 100, passingMarks: 33),
        ExamSubjectSchedule(subjectId: 'sub_sci', date: examDate.add(const Duration(days: 1)), startTime: '09:00 AM', endTime: '12:00 PM', maxMarks: 100, passingMarks: 33),
        ExamSubjectSchedule(subjectId: 'sub_eng', date: examDate.add(const Duration(days: 2)), startTime: '09:00 AM', endTime: '12:00 PM', maxMarks: 100, passingMarks: 33),
      ],
      status: ExamStatus.scheduled,
    );
    final exams = [exam];

    final firstNames = ['Aarav', 'Diya', 'Rohan', 'Neha', 'Kabir', 'Ananya', 'Vivaan', 'Ishita', 'Aditya', 'Meera', 'Kabir', 'Zoya', 'Arjun', 'Saanvi', 'Reyansh'];
    final lastNames = ['Sharma', 'Patel', 'Gupta', 'Singh', 'Joshi', 'Verma', 'Reddy', 'Nair', 'Khan', 'Iyer'];
    final students = <Student>[];
    int rollCounter = 1;
    for (final sec in ['A', 'B', 'C']) {
      for (int i = 0; i < 12; i++) {
        final fn = firstNames[(i + sec.codeUnitAt(0)) % firstNames.length];
        final ln = lastNames[(i * 3 + sec.codeUnitAt(0)) % lastNames.length];
        students.add(Student(
          rollNo: rollCounter.toString().padLeft(2, '0'),
          name: '$fn $ln',
          classId: 'c10',
          section: sec,
        ));
        rollCounter++;
      }
    }

    final eligibility = <EligibilityRecord>[];
    for (int i = 0; i < students.length; i++) {
      final s = students[i];
      EligibilityStatus st = EligibilityStatus.eligible;
      String reason = '';
      if (i % 11 == 0) {
        st = EligibilityStatus.notEligible;
        reason = 'Attendance shortage';
      } else if (i % 13 == 0) {
        st = EligibilityStatus.conditional;
        reason = 'Fee due';
      }
      eligibility.add(EligibilityRecord(studentId: s.id, examId: exam.id, status: st, reason: reason));
    }

    final accommodations = [
      AccommodationRecord(studentId: students[2].id, type: AccommodationType.extraTime, details: '20 extra minutes per paper', approved: true),
    ];

    // Question bank
    final questions = <QuestionItem>[];
    final mathQs = [
      ['If x + 3 = 7, find the value of x.', Difficulty.easy, QuestionType.shortAnswer, 2],
      ['Solve: 2x^2 - 5x + 3 = 0', Difficulty.medium, QuestionType.longAnswer, 3],
      ['Prove that sqrt(2) is an irrational number.', Difficulty.hard, QuestionType.longAnswer, 5],
      ['Find the value of sin 60 degrees.', Difficulty.easy, QuestionType.shortAnswer, 2],
      ['A bag contains 5 red and 3 blue balls. Find P(red).', Difficulty.medium, QuestionType.mcq, 1],
    ];
    for (final q in mathQs) {
      questions.add(QuestionItem(
        text: q[0] as String,
        classId: 'c10',
        subjectId: 'sub_math',
        chapter: 'General',
        difficulty: q[1] as Difficulty,
        type: q[2] as QuestionType,
        marks: q[3] as int,
      ));
    }
    for (int i = 0; i < 25; i++) {
      final subj = subjects[i % subjects.length];
      questions.add(QuestionItem(
        text: 'Sample ${subj.name} question #$i covering chapter ${(i % 6) + 1}.',
        classId: 'c10',
        subjectId: subj.id,
        chapter: 'Chapter ${(i % 6) + 1}',
        difficulty: Difficulty.values[i % 3],
        type: QuestionType.values[i % QuestionType.values.length],
        marks: (i % 5) + 1,
      ));
    }

    final paperSets = <QuestionPaperSet>[
      QuestionPaperSet(examId: exam.id, subjectId: 'sub_math', setLabel: 'A', questionIds: questions.take(5).map((q) => q.id).toList(), totalMarks: 100, status: PaperStatus.approved),
    ];

    final rooms = [
      ExamRoom(id: 'room_101', name: '101', capacity: 30),
      ExamRoom(id: 'room_102', name: '102', capacity: 30),
      ExamRoom(id: 'room_103', name: '103', capacity: 25),
    ];

    final invigilators = [
      Invigilator(userId: 'u_invig1', name: 'Amit Singh'),
      Invigilator(userId: 'u_examiner2', name: 'Sunita Iyer'),
      Invigilator(userId: 'u_coord', name: 'Priya Verma'),
    ];

    final duties = [
      InvigilatorDuty(examId: exam.id, roomId: 'room_101', subjectId: 'sub_math', invigilatorId: invigilators[0].id),
      InvigilatorDuty(examId: exam.id, roomId: 'room_102', subjectId: 'sub_math', invigilatorId: invigilators[1].id),
    ];

    final seats = <SeatAssignment>[];
    for (int i = 0; i < 20; i++) {
      final row = String.fromCharCode(65 + (i ~/ 5));
      seats.add(SeatAssignment(
        examId: exam.id,
        roomId: 'room_101',
        seatCode: '$row${(i % 5) + 1}'.padLeft(3, '0'),
        studentId: i < students.length ? students[i].id : null,
      ));
    }

    // Anonymous books + a few in various custody states, with a protected
    // mapping to students (never exposed to examiner UI).
    final books = <AnonymousBook>[];
    final existingIds = <String>{};
    for (int i = 0; i < students.length; i++) {
      final anonId = AnonymousIdService.generateBulk(1, 2026, existingIds).first;
      existingIds.add(anonId);
      final statusCycle = [
        BookStatus.collected,
        BookStatus.evaluationQueue,
        BookStatus.assignedToExaminer,
        BookStatus.underEvaluation,
        BookStatus.evaluated,
        BookStatus.marksLocked,
      ];
      final status = statusCycle[i % statusCycle.length];
      final book = AnonymousBook(
        anonId: anonId,
        examId: exam.id,
        subjectId: 'sub_math',
        studentId: students[i].id,
        examinerId: status.index >= BookStatus.assignedToExaminer.index ? 'u_examiner1' : null,
        status: status,
      );
      book.history.add(CustodyEvent(toStatus: BookStatus.generated, actorUserId: 'Vikram Sharma'));
      book.history.add(CustodyEvent(toStatus: status, actorUserId: 'Vikram Sharma'));
      books.add(book);
    }

    final evaluations = <EvaluationRecord>[];
    for (final b in books) {
      if (b.status.index >= BookStatus.evaluated.index) {
        final marks = List.generate(6, (i) => QuestionMark(questionNo: '${i + 1}', maxMarks: (i < 3) ? 10 : 15, awarded: 6 + (i % 5)));
        evaluations.add(EvaluationRecord(
          bookId: b.id,
          examinerId: 'u_examiner1',
          marks: marks,
          submitted: true,
          locked: true,
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        ));
      }
    }

    final results = <ResultRecord>[];

    final incidents = [
      MalpracticeIncident(
        studentId: students[0].id,
        examId: exam.id,
        roomId: 'room_101',
        seatCode: 'A01',
        incidentType: 'Suspicious behavior',
        description: 'Repeatedly looking at neighboring script.',
        reportedByUserId: 'Amit Singh',
        actionTaken: 'Warning issued',
        status: IncidentStatus.actionTaken,
      ),
    ];

    final notifications = [
      NotificationItem(title: 'Annual Examination 2026 timetable published', body: 'The timetable for Annual Examination 2026 is now available.', audience: NotificationAudience.all, status: NotificationStatus.sent),
      NotificationItem(title: 'Admit Card available', body: 'Admit cards can now be downloaded from the student portal.', audience: NotificationAudience.students, status: NotificationStatus.sent),
    ];

    return SeedBundle(
      users: users,
      sessions: sessions,
      classes: classes,
      subjects: subjects,
      exams: exams,
      students: students,
      eligibility: eligibility,
      accommodations: accommodations,
      questions: questions,
      paperSets: paperSets,
      rooms: rooms,
      invigilators: invigilators,
      duties: duties,
      seats: seats,
      books: books,
      evaluations: evaluations,
      results: results,
      incidents: incidents,
      notifications: notifications,
    );
  }
}
