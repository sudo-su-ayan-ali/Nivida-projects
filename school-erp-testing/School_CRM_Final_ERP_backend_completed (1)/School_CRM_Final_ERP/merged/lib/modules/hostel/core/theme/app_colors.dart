import 'package:flutter/material.dart';

/// Centralized color system for HostelHub.
/// Never scatter raw colors around the app — always reference AppColors.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1677FF);
  static const Color primaryDark = Color(0xFF146EF5);
  static const Color primarySoft = Color(0xFFE8F1FF);

  static const Color navy = Color(0xFF101B4A);
  static const Color textPrimary = Color(0xFF101B4A);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textMuted = Color(0xFF98A2B3);

  static const Color success = Color(0xFF16B364);
  static const Color successSoft = Color(0xFFE7F9F1);

  static const Color warning = Color(0xFFF79009);
  static const Color warningSoft = Color(0xFFFFF6E9);

  static const Color danger = Color(0xFFF04438);
  static const Color dangerSoft = Color(0xFFFFEDEC);

  static const Color info = Color(0xFF0BA5EC);
  static const Color infoSoft = Color(0xFFE7F8FE);

  static const Color purple = Color(0xFF7A5AF8);
  static const Color purpleSoft = Color(0xFFF1EDFF);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4E7EC);
  static const Color divider = Color(0xFFEEF1F5);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
      case 'resolved':
      case 'completed':
      case 'present':
      case 'active':
      case 'checked in':
      case 'occupied':
        return success;
      case 'pending':
      case 'in progress':
      case 'partial':
      case 'late':
      case 'reserved':
      case 'scheduled':
        return warning;
      case 'rejected':
      case 'failed':
      case 'overdue':
      case 'absent':
      case 'closed':
      case 'urgent':
      case 'inactive':
        return danger;
      case 'vacant':
      case 'checked out':
      case 'open':
        return info;
      case 'maintenance':
      case 'cancelled':
        return purple;
      default:
        return AppColors.textMuted;
    }
  }

  static Color statusSoft(String status) => statusColor(status).withOpacity(0.12);
}
