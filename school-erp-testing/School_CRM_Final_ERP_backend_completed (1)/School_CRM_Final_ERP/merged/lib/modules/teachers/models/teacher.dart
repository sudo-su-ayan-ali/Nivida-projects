import 'package:flutter/material.dart';

/// Sort keys supported by the Teacher List table. Shared between the
/// dashboard screen (which owns the filter/sort state) and the panel
/// that renders it.
enum TeacherSortKey { none, name, empId, department, status }

/// A single department, with a signature color used in charts & badges.
class Department {
  final String name;
  final Color color;
  const Department(this.name, this.color);
}

/// Core Teacher record shown in the Teacher List table.
class Teacher {
  final int id;
  final String empId;
  String name;
  String email;
  String phone;
  String department;
  String subject;
  String status; // 'Active' | 'On Leave'
  final String avatarSeed;
  final int birthDay;
  final String birthMonth;

  Teacher({
    required this.id,
    required this.empId,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.subject,
    required this.status,
    required this.avatarSeed,
    required this.birthDay,
    required this.birthMonth,
  });

  Teacher copyWith({
    String? name,
    String? email,
    String? phone,
    String? department,
    String? subject,
    String? status,
  }) {
    return Teacher(
      id: id,
      empId: empId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      avatarSeed: avatarSeed,
      birthDay: birthDay,
      birthMonth: birthMonth,
    );
  }
  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] as int,
      empId: map['emp_id'] as String,
      name: map['name'] as String,
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      department: map['department'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      status: map['status'] as String? ?? 'Active',
      avatarSeed: map['avatar_seed'] as String? ?? '',
      birthDay: map['birth_day'] as int? ?? 1,
      birthMonth: map['birth_month'] as String? ?? 'JAN',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emp_id': empId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'subject': subject,
      'status': status,
      'avatar_seed': avatarSeed,
      'birth_day': birthDay,
      'birth_month': birthMonth,
    };
  }
}

/// A small stat tile used for the summary row and the bottom info grid.
class StatTile {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color bg;
  const StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.bg,
  });
}

/// A quick-access tool card ("Teaching Tools & Important Links").
class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color bg;
  const QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.bg,
  });
  
}
