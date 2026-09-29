/// Core domain models for the School Examination ERP.
/// Kept as strongly-typed, immutable-ish classes with copyWith helpers.
library models;

import 'package:uuid/uuid.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();

// ---------------------------------------------------------------------------
// RBAC
// ---------------------------------------------------------------------------

enum AppRole {
  superAdmin,
  examController,
  examCoordinator,
  examiner,
  invigilator,
  student,
  parent,
}

extension AppRoleX on AppRole {
  String get label => switch (this) {
        AppRole.superAdmin => 'Super Admin',
        AppRole.examController => 'Exam Controller',
        AppRole.examCoordinator => 'Exam Coordinator',
        AppRole.examiner => 'Examiner / Teacher',
        AppRole.invigilator => 'Invigilator',
        AppRole.student => 'Student',
        AppRole.parent => 'Parent',
      };
}

/// Granular permissions checked at the service layer (never UI-only).
enum Permission {
  viewDashboard,
  manageExams,
  manageEligibility,
  manageQuestionBank,
  manageQuestionPapers,
  approveQuestionPapers,
  generateAnonymousBooks,
  viewAnonymousMapping, // sensitive: identity mapping
  revealIdentity, // sensitive: privileged
  assignInvigilators,
  manageSeating,
  manageAttendance,
  enterMarks,
  lockMarks,
  requestMarksCorrection,
  approveMarksCorrection,
  moderateEvaluation,
  approveResults,
  publishResults,
  manageRevaluation,
  manageMalpractice,
  manageAccommodation,
  manageCertificates,
  manageNotifications,
  viewAnalytics,
  manageUsers,
  manageRolesPermissions,
  viewAuditLogs,
  manageBackup,
  manageArchive,
  viewOwnResults, // student/parent
  viewOwnAdmitCard,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final AppRole role;
  final String? classSection; // for students
  final String? subjectSpecialization; // for examiners
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.classSection,
    this.subjectSpecialization,
  });
}

// ---------------------------------------------------------------------------
// Academic structure
// ---------------------------------------------------------------------------

class AcademicSession {
  final String id;
  final String label; // e.g. 2025-26
  final bool isActive;
  AcademicSession({required this.id, required this.label, this.isActive = true});
}

class SchoolClass {
  final String id;
  final String name; // e.g. 10th
  final List<String> sections; // A, B, C
  SchoolClass({required this.id, required this.name, required this.sections});
}

class Subject {
  final String id;
  final String name;
  final String code;
  final String classId;
  Subject({required this.id, required this.name, required this.code, required this.classId});
}

enum ExamType { unitTest, halfYearly, preBoard, annual, supplementary }

extension ExamTypeX on ExamType {
  String get label => switch (this) {
        ExamType.unitTest => 'Unit Test',
        ExamType.halfYearly => 'Half Yearly',
        ExamType.preBoard => 'Pre-Board',
        ExamType.annual => 'Annual Examination',
        ExamType.supplementary => 'Supplementary / Re-Exam',
      };
}

enum ExamStatus { draft, scheduled, ongoing, completed, resultDeclared, archived }

class ExamSubjectSchedule {
  final String subjectId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int maxMarks;
  final int passingMarks;
  ExamSubjectSchedule({
    required this.subjectId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxMarks,
    required this.passingMarks,
  });
}

class Examination {
  final String id;
  String name;
  ExamType type;
  String sessionId;
  String classId;
  List<String> sections;
  List<ExamSubjectSchedule> schedule;
  bool rankingEnabled;
  ExamStatus status;
  Examination({
    String? id,
    required this.name,
    required this.type,
    required this.sessionId,
    required this.classId,
    required this.sections,
    required this.schedule,
    this.rankingEnabled = true,
    this.status = ExamStatus.draft,
  }) : id = id ?? newId();
}

// ---------------------------------------------------------------------------
// Students & eligibility & accommodation
// ---------------------------------------------------------------------------

enum EligibilityStatus { eligible, notEligible, conditional }

class Student {
  final String id;
  final String rollNo;
  final String name;
  final String classId;
  final String section;
  final String? parentUserId;
  Student({
    String? id,
    required this.rollNo,
    required this.name,
    required this.classId,
    required this.section,
    this.parentUserId,
  }) : id = id ?? newId();
}

class EligibilityRecord {
  final String id;
  final String studentId;
  final String examId;
  EligibilityStatus status;
  String reason;
  EligibilityRecord({
    String? id,
    required this.studentId,
    required this.examId,
    required this.status,
    this.reason = '',
  }) : id = id ?? newId();
}

enum AccommodationType { extraTime, separateRoom, specialSeating, scribe, largePrint, other }

class AccommodationRecord {
  final String id;
  final String studentId;
  final AccommodationType type;
  final String details; // sensitive-ish, only visible to authorized roles
  final bool approved;
  AccommodationRecord({
    String? id,
    required this.studentId,
    required this.type,
    required this.details,
    this.approved = false,
  }) : id = id ?? newId();
}

// ---------------------------------------------------------------------------
// Question bank & papers
// ---------------------------------------------------------------------------

enum QuestionType {
  mcq,
  trueFalse,
  fillBlank,
  shortAnswer,
  longAnswer,
  numerical,
  caseStudy,
  assertionReasoning,
}

enum Difficulty { easy, medium, hard }

enum QuestionStatus { draft, approved, retired }

class QuestionItem {
  final String id;
  String text;
  final String classId;
  final String subjectId;
  String chapter;
  String topic;
  QuestionType type;
  Difficulty difficulty;
  int marks;
  List<String> tags;
  QuestionStatus status;
  QuestionItem({
    String? id,
    required this.text,
    required this.classId,
    required this.subjectId,
    this.chapter = '',
    this.topic = '',
    this.type = QuestionType.shortAnswer,
    this.difficulty = Difficulty.medium,
    this.marks = 1,
    List<String>? tags,
    this.status = QuestionStatus.approved,
  })  : id = id ?? newId(),
        tags = tags ?? [];
}

enum PaperStatus { draft, submitted, approved, published }

class QuestionPaperSet {
  final String id;
  final String examId;
  final String subjectId;
  String setLabel; // A / B / C
  List<String> questionIds;
  int totalMarks;
  PaperStatus status;
  bool watermarkEnabled;
  bool encryptionEnabled;
  bool downloadRestricted;
  QuestionPaperSet({
    String? id,
    required this.examId,
    required this.subjectId,
    required this.setLabel,
    List<String>? questionIds,
    this.totalMarks = 0,
    this.status = PaperStatus.draft,
    this.watermarkEnabled = true,
    this.encryptionEnabled = true,
    this.downloadRestricted = true,
  })  : id = id ?? newId(),
        questionIds = questionIds ?? [];
}

// ---------------------------------------------------------------------------
// Rooms, invigilators, seating
// ---------------------------------------------------------------------------

class ExamRoom {
  final String id;
  final String name;
  final int capacity;
  ExamRoom({String? id, required this.name, required this.capacity}) : id = id ?? newId();
}

class Invigilator {
  final String id;
  final String userId;
  final String name;
  Invigilator({String? id, required this.userId, required this.name}) : id = id ?? newId();
}

class InvigilatorDuty {
  final String id;
  final String examId;
  final String roomId;
  final String subjectId;
  String invigilatorId;
  String? substituteInvigilatorId;
  bool substituteNeeded;
  InvigilatorDuty({
    String? id,
    required this.examId,
    required this.roomId,
    required this.subjectId,
    required this.invigilatorId,
    this.substituteInvigilatorId,
    this.substituteNeeded = false,
  }) : id = id ?? newId();
}

class SeatAssignment {
  final String id;
  final String examId;
  final String roomId;
  final String seatCode; // A01, A02...
  String? studentId;
  SeatAssignment({
    String? id,
    required this.examId,
    required this.roomId,
    required this.seatCode,
    this.studentId,
  }) : id = id ?? newId();
}

// ---------------------------------------------------------------------------
// Anonymous Examination Book + Chain of Custody (flagship security feature)
// ---------------------------------------------------------------------------

enum BookStatus {
  generated,
  printed,
  prepared,
  assigned,
  distributed,
  collected,
  received,
  evaluationQueue,
  assignedToExaminer,
  underEvaluation,
  evaluated,
  marksLocked,
  approved,
  identityRevealed,
  resultPublished,
  archived,
  cancelled,
}

extension BookStatusX on BookStatus {
  String get label {
    final s = toString().split('.').last;
    // camelCase -> Title Case
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final c = s[i];
      if (i > 0 && c.toUpperCase() == c) buf.write(' ');
      buf.write(i == 0 ? c.toUpperCase() : c);
    }
    return buf.toString();
  }
}

class CustodyEvent {
  final String id;
  final BookStatus toStatus;
  final String actorUserId;
  final DateTime timestamp;
  final String note;
  CustodyEvent({
    String? id,
    required this.toStatus,
    required this.actorUserId,
    DateTime? timestamp,
    this.note = '',
  })  : id = id ?? newId(),
        timestamp = timestamp ?? DateTime.now();
}

/// A single anonymous answer book. Crypto-random, non-sequential anonId.
/// studentId is the PROTECTED mapping - must never be surfaced to examiners.
class AnonymousBook {
  final String id;
  final String anonId; // e.g. EXM26-7K9P-Q2L8
  final String examId;
  final String subjectId;
  String? studentId; // protected mapping
  String? examinerId; // assigned examiner (never sees studentId)
  BookStatus status;
  final List<CustodyEvent> history;
  bool identityRevealed;
  AnonymousBook({
    String? id,
    required this.anonId,
    required this.examId,
    required this.subjectId,
    this.studentId,
    this.examinerId,
    this.status = BookStatus.generated,
    List<CustodyEvent>? history,
    this.identityRevealed = false,
  })  : id = id ?? newId(),
        history = history ?? [];
}

// ---------------------------------------------------------------------------
// Evaluation
// ---------------------------------------------------------------------------

enum EvaluationStage { first, second, moderation }

class QuestionMark {
  final String questionNo;
  final int maxMarks;
  int? awarded;
  String? comment;
  QuestionMark({required this.questionNo, required this.maxMarks, this.awarded, this.comment});
}

class EvaluationRecord {
  final String id;
  final String bookId; // anonymous book id (internal id, not the printed anonId)
  final String examinerId;
  final EvaluationStage stage;
  List<QuestionMark> marks;
  bool submitted;
  bool locked;
  DateTime? submittedAt;
  EvaluationRecord({
    String? id,
    required this.bookId,
    required this.examinerId,
    this.stage = EvaluationStage.first,
    List<QuestionMark>? marks,
    this.submitted = false,
    this.locked = false,
    this.submittedAt,
  })  : id = id ?? newId(),
        marks = marks ?? [];

  int get total => marks.fold(0, (sum, m) => sum + (m.awarded ?? 0));
}

enum CorrectionStatus { pending, approved, rejected }

class MarksCorrectionRequest {
  final String id;
  final String bookId;
  final String requestedByUserId;
  final int originalValue;
  final int newValue;
  final String reason;
  CorrectionStatus status;
  String? approvedByUserId;
  DateTime requestedAt;
  MarksCorrectionRequest({
    String? id,
    required this.bookId,
    required this.requestedByUserId,
    required this.originalValue,
    required this.newValue,
    required this.reason,
    this.status = CorrectionStatus.pending,
    this.approvedByUserId,
    DateTime? requestedAt,
  })  : id = id ?? newId(),
        requestedAt = requestedAt ?? DateTime.now();
}

// ---------------------------------------------------------------------------
// Results & grading
// ---------------------------------------------------------------------------

enum ResultStage { draft, underReview, approved, published, locked }

class GradeBand {
  final String grade;
  final double minPercent;
  final double maxPercent;
  final int gradePoint;
  GradeBand(this.grade, this.minPercent, this.maxPercent, this.gradePoint);
}

class SubjectResult {
  final String subjectId;
  final int maxMarks;
  final int marksObtained;
  String grade;
  SubjectResult({
    required this.subjectId,
    required this.maxMarks,
    required this.marksObtained,
    this.grade = '',
  });
}

class ResultRecord {
  final String id;
  final String examId;
  final String studentId;
  List<SubjectResult> subjects;
  double percentage;
  String overallGrade;
  int? rank;
  bool pass;
  ResultStage stage;
  ResultRecord({
    String? id,
    required this.examId,
    required this.studentId,
    List<SubjectResult>? subjects,
    this.percentage = 0,
    this.overallGrade = '',
    this.rank,
    this.pass = false,
    this.stage = ResultStage.draft,
  })  : id = id ?? newId(),
        subjects = subjects ?? [];
}

enum RevaluationStatus { requested, assigned, reevaluated, approved, rejected }

class RevaluationRequest {
  final String id;
  final String studentId;
  final String bookId;
  final String subjectId;
  int originalMarks;
  int? revisedMarks;
  String reason;
  RevaluationStatus status;
  DateTime requestedAt;
  RevaluationRequest({
    String? id,
    required this.studentId,
    required this.bookId,
    required this.subjectId,
    required this.originalMarks,
    this.revisedMarks,
    required this.reason,
    this.status = RevaluationStatus.requested,
    DateTime? requestedAt,
  })  : id = id ?? newId(),
        requestedAt = requestedAt ?? DateTime.now();
}

// ---------------------------------------------------------------------------
// Malpractice
// ---------------------------------------------------------------------------

enum IncidentStatus { open, underInvestigation, actionTaken, closed }

class MalpracticeIncident {
  final String id;
  final String studentId;
  final String examId;
  final String roomId;
  final String seatCode;
  String incidentType; // cheating, mobile phone, unauthorized material, impersonation, other
  String description;
  final String reportedByUserId;
  DateTime timestamp;
  String actionTaken;
  IncidentStatus status;
  MalpracticeIncident({
    String? id,
    required this.studentId,
    required this.examId,
    required this.roomId,
    required this.seatCode,
    required this.incidentType,
    required this.description,
    required this.reportedByUserId,
    DateTime? timestamp,
    this.actionTaken = '',
    this.status = IncidentStatus.open,
  })  : id = id ?? newId(),
        timestamp = timestamp ?? DateTime.now();
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

enum NotificationAudience { all, students, parents, examiners, invigilators, staff }
enum NotificationStatus { draft, scheduled, sent }

class NotificationItem {
  final String id;
  String title;
  String body;
  NotificationAudience audience;
  NotificationStatus status;
  DateTime? scheduledFor;
  DateTime createdAt;
  NotificationItem({
    String? id,
    required this.title,
    required this.body,
    this.audience = NotificationAudience.all,
    this.status = NotificationStatus.draft,
    this.scheduledFor,
    DateTime? createdAt,
  })  : id = id ?? newId(),
        createdAt = createdAt ?? DateTime.now();
}

// ---------------------------------------------------------------------------
// Audit log
// ---------------------------------------------------------------------------

class AuditLogEntry {
  final String id;
  final String actorUserId;
  final String actorRole;
  final String action;
  final String module;
  final String? referenceId;
  final String? previousValue;
  final String? newValue;
  final DateTime timestamp;
  final String sessionInfo;
  AuditLogEntry({
    String? id,
    required this.actorUserId,
    required this.actorRole,
    required this.action,
    required this.module,
    this.referenceId,
    this.previousValue,
    this.newValue,
    DateTime? timestamp,
    this.sessionInfo = 'web-session',
  })  : id = id ?? newId(),
        timestamp = timestamp ?? DateTime.now();
}
