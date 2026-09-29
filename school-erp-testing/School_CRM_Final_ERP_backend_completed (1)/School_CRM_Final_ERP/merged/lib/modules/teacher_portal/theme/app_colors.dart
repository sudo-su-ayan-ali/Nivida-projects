import 'package:flutter/material.dart';

/// Centralized color palette for the EduSmart ERP Teacher Portal.
/// Premium light theme with soft blue/purple gradients.
class AppColors {
  AppColors._();

  static const Color scaffoldBg = Color(0xFFF3F5FB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEBEDF6);

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4BD6);
  static const Color primaryLight = Color(0xFFEFEBFF);

  // Accent palette (used for stat icons / tags)
  static const Color purple = Color(0xFF7C6BF0);
  static const Color purpleBg = Color(0xFFEFECFE);

  static const Color blue = Color(0xFF3D7BFF);
  static const Color blueBg = Color(0xFFE7EFFF);

  static const Color green = Color(0xFF22C55E);
  static const Color greenBg = Color(0xFFE6F9EE);

  static const Color orange = Color(0xFFFF9A2E);
  static const Color orangeBg = Color(0xFFFFF1E1);

  static const Color pink = Color(0xFFFF4D8D);
  static const Color pinkBg = Color(0xFFFFE9F1);

  static const Color red = Color(0xFFFF4757);
  static const Color redBg = Color(0xFFFFE9EB);

  static const Color teal = Color(0xFF17C3B2);
  static const Color tealBg = Color(0xFFE3FAF6);

  static const Color yellow = Color(0xFFFFC542);
  static const Color yellowBg = Color(0xFFFFF6E0);

  // Text
  static const Color textPrimary = Color(0xFF1E2138);
  static const Color textSecondary = Color(0xFF8A8FA6);
  static const Color textMuted = Color(0xFFAEB2C4);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFF9A2E);
  static const Color danger = Color(0xFFFF4757);
  static const Color info = Color(0xFF3D7BFF);

  static const List<Color> primaryGradient = [
    Color(0xFF7C6BF0),
    Color(0xFF6C5CE7),
  ];

  static const List<Color> headerGreetingGradient = [
    Color(0xFFF4F1FF),
    Color(0xFFEFF3FF),
  ];

  static BoxShadow cardShadow = BoxShadow(
    color: const Color(0xFF1E2138).withOpacity(0.045),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );

  static BoxShadow hoverShadow = BoxShadow(
    color: AppColors.primary.withOpacity(0.14),
    blurRadius: 28,
    offset: const Offset(0, 10),
  );
}
