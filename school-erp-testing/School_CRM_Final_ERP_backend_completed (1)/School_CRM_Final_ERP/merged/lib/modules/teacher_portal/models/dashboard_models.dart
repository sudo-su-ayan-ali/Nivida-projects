import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// Shared enums
/// ---------------------------------------------------------------------
enum AttendanceStatus { present, absent, late }

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }
}

/// ---------------------------------------------------------------------
/// Role-Based Access Control — who's currently signed in and what they're
/// allowed to see. Teacher = own classes only. HOD = department overview +
/// reports. Principal / Admin = whole-school overview, reports & approvals.
/// ---------------------------------------------------------------------
enum UserRole { teacher, hod, principal, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.hod:
        return 'HOD';
      case UserRole.principal:
        return 'Principal';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.teacher:
        return 'Your classes & students';
      case UserRole.hod:
        return 'Department overview';
      case UserRole.principal:
        return 'Whole-school overview';
      case UserRole.admin:
        return 'Full system access';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.teacher:
        return Icons.person_outline;
      case UserRole.hod:
        return Icons.groups_outlined;
      case UserRole.principal:
        return Icons.workspace_premium_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

 bool get canApproveLeaves => true;
bool get canVerifyDocuments => true;
bool get canAccessReports => true;
}

/// ---------------------------------------------------------------------
/// Dashboard stat tile (computed live from AppState)
/// ---------------------------------------------------------------------
class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final String sub;
  final Color color;
  final Color bgColor;

  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.sub,
    required this.color,
    required this.bgColor,
  });
}

enum ScheduleStatus { completed, ongoing, upcoming }

class ScheduleItem {
  final String time;
  final String className;
  final String subject;
  final String room;
  final ScheduleStatus status;

  const ScheduleItem({
    required this.time,
    required this.className,
    required this.subject,
    required this.room,
    required this.status,
  });

  ScheduleItem copyWith({ScheduleStatus? status}) => ScheduleItem(
        time: time,
        className: className,
        subject: subject,
        room: room,
        status: status ?? this.status,
      );
}

/// ---------------------------------------------------------------------
/// Assignment — now mutable & id'd so it can be created / graded / deleted.
/// ---------------------------------------------------------------------
class AssignmentItem {
  final String id;
  final IconData icon;
  final Color color;
  final Color bgColor;
  String title;
  String className;
  String dueDate;
  int pendingCount;
  int totalCount;
  bool graded;

  AssignmentItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.className,
    required this.dueDate,
    required this.pendingCount,
    required this.totalCount,
    this.graded = false,
  });

  String get meta => '$className • Due: $dueDate';
}

class ClassSlice {
  final String name;
  final int students;
  final Color color;

  const ClassSlice({required this.name, required this.students, required this.color});
}

/// ---------------------------------------------------------------------
/// Student — mutable score / attendance so Attendance & Students pages
/// can actually change data that the rest of the app reflects.
/// ---------------------------------------------------------------------
class StudentItem {
  final String id;
  String name;
  String className;
  int score;
  final String avatarSeed;
  String email;
  String phone;
  AttendanceStatus attendanceToday;

  StudentItem({
    required this.id,
    required this.name,
    required this.className,
    required this.score,
    required this.avatarSeed,
    this.email = '',
    this.phone = '',
    this.attendanceToday = AttendanceStatus.present,
  });
}

/// ---------------------------------------------------------------------
/// Message / Announcement — id'd, mutable "unread" state.
/// ---------------------------------------------------------------------
class MessageItem {
  final String id;
  final IconData icon;
  final Color color;
  final Color bgColor;
  String title;
  String meta;
  String time;
  bool unread;

  MessageItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.meta,
    required this.time,
    this.unread = false,
  });
}

/// ---------------------------------------------------------------------
/// Exam — id'd so it can be created / removed from the Exams page.
/// ---------------------------------------------------------------------
class ExamItem {
  final String id;
  final IconData icon;
  final Color color;
  final Color bgColor;
  String title;
  String className;
  String subject;
  String date;

  ExamItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.className,
    required this.subject,
    required this.date,
  });

  String get meta => '$className • $subject';
}

class ActionTile {
  final String id;
  final IconData icon;
  final String label;
  final String sub;

  const ActionTile({required this.id, required this.icon, required this.label, this.sub = ''});
}

class AnalyticsItem {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String value;
  final String label;

  const AnalyticsItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.value,
    required this.label,
  });
}

/// ---------------------------------------------------------------------
/// New models for the additional advanced-ERP pages.
/// ---------------------------------------------------------------------
class NotificationItem {
  final String id;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;
  bool read;

  NotificationItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.read = false,
  });
}

/// ---------------------------------------------------------------------
/// Staff Leave — applied by a teacher (or any staff member), reviewed by
/// an HOD/Principal/Admin. `date`/`toDate` mark the leave range, `days` is
/// how many working days it spans.
/// ---------------------------------------------------------------------
class LeaveRequest {
  final String id;
  String staffName;
  String leaveType; // Casual / Sick / Earned
  String reason;
  String date; // from-date
  String toDate;
  int days;
  String appliedOn;
  String status; // Pending / Approved / Rejected
  String approverNote;

  LeaveRequest({
    required this.id,
    required this.reason,
    required this.date,
    this.staffName = '',
    this.leaveType = 'Casual',
    this.toDate = '',
    this.days = 1,
    this.appliedOn = '',
    this.status = 'Pending',
    this.approverNote = '',
  });
}

/// ---------------------------------------------------------------------
/// Role-Based Access Control — request/approval workflow ONLY. Raising or
/// deciding a request here never changes anyone's real UserRole; it is a
/// tracked paper-trail so a Principal / Vice Principal can formally ask
/// for a staff member's access to be changed, and leadership can review
/// that request in one place. No permission in the app is actually
/// granted or revoked by this — same as today.
/// ---------------------------------------------------------------------
class AccessRequest {
  final String id;
  String raisedBy;
  String raisedByRole; // Principal / Vice Principal
  String staffName;
  String currentRole;
  String requestedRole;
  String reason;
  String appliedOn;
  String status; // Pending / Approved / Rejected
  String reviewerNote;

  AccessRequest({
    required this.id,
    required this.staffName,
    required this.currentRole,
    required this.requestedRole,
    required this.reason,
    this.raisedBy = '',
    this.raisedByRole = 'Principal',
    this.appliedOn = '',
    this.status = 'Pending',
    this.reviewerNote = '',
  });
}

/// ---------------------------------------------------------------------
/// Staff Payroll — one generated salary slip per month.
/// ---------------------------------------------------------------------
class PayslipItem {
  final String id;
  final String staffName;
  final String month;
  final String year;
  final double basic;
  final double hra;
  final double allowances;
  final double providentFund;
  final double tax;
  final double otherDeductions;
  final String status; // Paid / Processing

  PayslipItem({
    required this.id,
    required this.staffName,
    required this.month,
    required this.year,
    required this.basic,
    required this.hra,
    required this.allowances,
    required this.providentFund,
    required this.tax,
    this.otherDeductions = 0,
    this.status = 'Paid',
  });

  double get grossEarnings => basic + hra + allowances;
  double get totalDeductions => providentFund + tax + otherDeductions;
  double get netPay => grossEarnings - totalDeductions;
  String get period => '$month $year';
}

/// ---------------------------------------------------------------------
/// Document Vault — a secure, per-student store for certificates, TC,
/// ID proof, admission forms etc.
/// ---------------------------------------------------------------------
class DocumentItem {
  final String id;
  final String studentId;
  String type;
  String fileName;
  String uploadedOn;
  String status;
  String? fileUrl;

  DocumentItem({
    required this.id,
    required this.studentId,
    required this.type,
    required this.fileName,
    required this.uploadedOn,
    this.status = 'Pending Verification',
    this.fileUrl,
  });
}

class ResourceItem {
  final String id;
  final IconData icon;
  final Color color;
  final Color bgColor;
  String title;
  String subtitle;

  ResourceItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });
}

class LessonPlanItem {
  final String id;
  String title;
  String className;
  String date;

  LessonPlanItem({required this.id, required this.title, required this.className, required this.date});
}

/// ---------------------------------------------------------------------
/// Gradebook — per-student assessment records (unit tests, assignments,
/// projects...) that roll up into an overall percentage + letter grade.
/// ---------------------------------------------------------------------
class AssessmentRecord {
  final String id;
  String title;
  String category;
  double maxMarks;
  double obtained;
  String date;

  AssessmentRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.maxMarks,
    required this.obtained,
    required this.date,
  });

  double get percent => maxMarks == 0 ? 0 : (obtained / maxMarks) * 100;
}

/// Syllabus / curriculum progress tracker — "planned vs completed".
class SyllabusChapter {
  final String id;
  String className;
  String subject;
  String title;
  int totalTopics;
  int completedTopics;

  SyllabusChapter({
    required this.id,
    required this.className,
    required this.subject,
    required this.title,
    required this.totalTopics,
    this.completedTopics = 0,
  });

  double get progress => totalTopics == 0 ? 0 : completedTopics / totalTopics;
}

/// Student conduct / behavior log entry.
class BehaviorNote {
  final String id;
  final String studentId;
  String type; // 'Merit' or 'Demerit'
  String note;
  String date;

  BehaviorNote({
    required this.id,
    required this.studentId,
    required this.type,
    required this.note,
    required this.date,
  });
}

/// Parent-Teacher Meeting slot — available until a parent name is booked.
class PTMSlot {
  final String id;
  String date;
  String time;
  String? parentName;
  String? studentName;

  PTMSlot({
    required this.id,
    required this.date,
    required this.time,
    this.parentName,
    this.studentName,
  });

  bool get booked => parentName != null && parentName!.trim().isNotEmpty;
}

/// Teacher's personal to-do / reminder item.
class TodoItem {
  final String id;
  String title;
  bool done;

  TodoItem({required this.id, required this.title, this.done = false});
}

/// ---------------------------------------------------------------------
/// Homework / Assignment Submission Tracking — per-student submission
/// status for a given homework item ('Pending' | 'Submitted' | 'Late' |
/// 'Reviewed').
/// ---------------------------------------------------------------------
class HomeworkItem {
  final String id;
  String title;
  String className;
  String subject;
  String dueDate;
  Map<String, String> submissions; // studentId -> status

  HomeworkItem({
    required this.id,
    required this.title,
    required this.className,
    required this.subject,
    required this.dueDate,
    required this.submissions,
  });

  int get totalCount => submissions.length;
  int get submittedCount => submissions.values.where((v) => v == 'Submitted' || v == 'Reviewed').length;
  int get pendingCount => submissions.values.where((v) => v == 'Pending').length;
  int get lateCount => submissions.values.where((v) => v == 'Late').length;
  double get progress => totalCount == 0 ? 0 : submittedCount / totalCount;
}

/// ---------------------------------------------------------------------
/// Online Class / Video Meeting — Zoom / Google Meet / MS Teams style
/// scheduled session with a shareable link.
/// ---------------------------------------------------------------------
class OnlineClassItem {
  final String id;
  String title;
  String className;
  String subject;
  String date;
  String time;
  String platform;
  String link;

  OnlineClassItem({
    required this.id,
    required this.title,
    required this.className,
    required this.subject,
    required this.date,
    required this.time,
    required this.platform,
    required this.link,
  });
}

/// ---------------------------------------------------------------------
/// Fee status — one record per student, so the teacher can see who's
/// pending/overdue and send a reminder in one tap.
/// ---------------------------------------------------------------------
class FeeRecord {
  final String studentId;
  double amount;
  String dueDate;
  String status; // Paid / Pending / Overdue

  FeeRecord({required this.studentId, required this.amount, required this.dueDate, this.status = 'Pending'});
}

/// ---------------------------------------------------------------------
/// Notice Board — broadcast announcements to a whole class / all parents
/// at once (separate from 1-to-1 Messages).
/// ---------------------------------------------------------------------
class NoticeItem {
  final String id;
  String title;
  String body;
  String audience;
  String date;
  bool pinned;

  NoticeItem({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.date,
    this.pinned = false,
  });
  factory NoticeItem.fromMap(Map<String, dynamic> map) {
    final created = DateTime.parse(map['created_at'] as String).toLocal();
    final now = DateTime.now();
    final diff = now.difference(created).inDays;
    final dateLabel = diff == 0 ? 'Today' : diff == 1 ? 'Yesterday' : '${created.day}/${created.month}/${created.year}';
    return NoticeItem(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['content'] as String,
      audience: map['audience'] as String? ?? 'All Classes',
      date: dateLabel,
      pinned: map['pinned'] as bool? ?? false,
    );
  }
}

/// ---------------------------------------------------------------------
/// Academic Calendar — holidays / events / exams / meetings, all in one
/// unified view.
/// ---------------------------------------------------------------------
class CalendarEventItem {
  final String id;
  String title;
  String date;
  String type; // Holiday / Exam / Event / Meeting / Class
  String className;

  CalendarEventItem({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.className = '',
  });
}
