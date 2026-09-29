import 'package:flutter/material.dart';

enum AttendanceStatus { present, late, absent }

enum PaymentMethod { card, upi, netBanking }

enum MessageSender { parent, teacher }

class Student {
  final String id;
  final String name;
  final String className; // e.g. "10-A"
  final String rollNo;
  final String avatarInitials;
  final Color avatarColor;
  final bool active;

  const Student({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNo,
    required this.avatarInitials,
    required this.avatarColor,
    this.active = true,
  });
}

class AttendanceDay {
  final DateTime date;
  final AttendanceStatus status;
  const AttendanceDay({required this.date, required this.status});
}

class AttendanceSummary {
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final List<AttendanceDay> history;

  const AttendanceSummary({
    required this.presentDays,
    required this.lateDays,
    required this.absentDays,
    required this.history,
  });

  int get totalDays => presentDays + lateDays + absentDays;
  double get presentPercent => totalDays == 0 ? 0 : (presentDays / totalDays) * 100;
  double get latePercent => totalDays == 0 ? 0 : (lateDays / totalDays) * 100;
  double get absentPercent => totalDays == 0 ? 0 : (absentDays / totalDays) * 100;
}

class SubjectGrade {
  final String subject;
  final String grade;
  final double score; // 0-100, used for progress bars / homework charts
  const SubjectGrade({required this.subject, required this.grade, required this.score});
}

class AcademicSummary {
  final String term;
  final String overallGrade;
  final List<SubjectGrade> subjects;
  const AcademicSummary({required this.term, required this.overallGrade, required this.subjects});
}

class FeeInstallment {
  final String label;
  final double amount;
  final bool paid;
  final DateTime dueDate;
  const FeeInstallment({
    required this.label,
    required this.amount,
    required this.paid,
    required this.dueDate,
  });
}

class FeeSummary {
  final double totalFees;
  final double paidAmount;
  final List<FeeInstallment> installments;
  const FeeSummary({
    required this.totalFees,
    required this.paidAmount,
    required this.installments,
  });

  double get dueAmount => totalFees - paidAmount;
  double get paidPercent => totalFees == 0 ? 0 : (paidAmount / totalFees) * 100;
}

class Notice {
  final String id;
  final String title;
  final String description;
  final DateTime postedAt;
  final IconData icon;
  final Color color;
  bool read;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.postedAt,
    required this.icon,
    required this.color,
    this.read = false,
  });
}

class SchoolEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String timeLabel;
  const SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.timeLabel,
  });
}

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime time;
  const ChatMessage({required this.text, required this.sender, required this.time});
}

class TeacherThread {
  final String id;
  final String teacherName;
  final String subject;
  final String avatarInitials;
  final Color avatarColor;
  final DateTime lastMessageTime;
  bool unread;
  final List<ChatMessage> messages;

  TeacherThread({
    required this.id,
    required this.teacherName,
    required this.subject,
    required this.avatarInitials,
    required this.avatarColor,
    required this.lastMessageTime,
    required this.messages,
    this.unread = false,
  });

  String get lastMessagePreview => messages.isEmpty ? '' : messages.last.text;
}

class QuickLink {
  final String label;
  final IconData icon;
  final Color color;
  const QuickLink({required this.label, required this.icon, required this.color});
}

class HomeworkItem {
  final String id;
  final String subject;
  final String title;
  final DateTime dueDate;
  final bool submitted;
  const HomeworkItem({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    required this.submitted,
  });
}

class ExamItem {
  final String id;
  final String subject;
  final DateTime date;
  final String time;
  final String room;
  const ExamItem({
    required this.id,
    required this.subject,
    required this.date,
    required this.time,
    required this.room,
  });
}

class TimetableSlot {
  final String day; // Mon..Sat
  final String time;
  final String subject;
  final String teacher;
  const TimetableSlot({
    required this.day,
    required this.time,
    required this.subject,
    required this.teacher,
  });
}

class TransportInfo {
  final String routeName;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final String pickupPoint;
  final String pickupTime;
  final String dropTime;
  const TransportInfo({
    required this.routeName,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.pickupPoint,
    required this.pickupTime,
    required this.dropTime,
  });
}

class LibraryBook {
  final String title;
  final String author;
  final DateTime issuedOn;
  final DateTime dueOn;
  final bool returned;
  const LibraryBook({
    required this.title,
    required this.author,
    required this.issuedOn,
    required this.dueOn,
    required this.returned,
  });
}

/// Bundles every piece of per-child data so the dashboard (and every other
/// screen) can react to child-switching from a single source of truth.
class ChildRecord {
  final Student student;
  final AttendanceSummary attendance;
  final AcademicSummary academics;
  final FeeSummary fees;
  final List<HomeworkItem> homework;
  final List<ExamItem> exams;
  final List<TimetableSlot> timetable;
  final TransportInfo? transport;   // <-- nullable kiya
  final List<LibraryBook> library;
  // PERF FIX: false jab tak sirf halka (attendance/academics/fees) data
  // load hua ho — homework/exams/timetable/transport/library abhi tak
  // fetch nahi hue. AppStateProvider is child ko select karte hi in
  // fields ko lazily fetch karke true kar deta hai.
  final bool detailsLoaded;

  const ChildRecord({
    required this.student,
    required this.attendance,
    required this.academics,
    required this.fees,
    required this.homework,
    required this.exams,
    required this.timetable,
    required this.transport,
    required this.library,
    this.detailsLoaded = true,
  });
}