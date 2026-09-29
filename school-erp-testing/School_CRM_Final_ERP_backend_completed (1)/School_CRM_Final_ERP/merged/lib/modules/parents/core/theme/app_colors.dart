import 'package:flutter/material.dart';

/// Central color palette matching the EduSmart School ERP design reference.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B5CF6);
  static const Color secondary = Color(0xFF7C4DFF);

  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0B1029);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF141A33);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF232A4A);

  static const Color sidebar = Color(0xFF0B1029);
  static const Color sidebarHover = Color(0xFF171E3D);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);

  static const Color muted = Color(0xFF6B7280);
  static const Color mutedDark = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color statBg(Color base) => base.withOpacity(0.12);
}
