import 'package:flutter/material.dart';

/// Central theme constants matching the EduSmart reference screenshots:
/// purple/indigo primary, dark navy sidebar, clean white cards, rounded corners.
class AppColors {
  static const Color primary = Color(0xFF6D5EF2);
  static const Color primaryDark = Color(0xFF5B4BDB);
  static const Color sidebarNavy = Color(0xFF1E1B3A);
  static const Color background = Color(0xFFF5F6FB);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFEDEEF3);
  static const Color textPrimary = Color(0xFF1E1E2D);
  static const Color textSecondary = Color(0xFF8B8D9B);

  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFE9FBF0);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFDEDED);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFF6E9);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEAF2FF);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkBg = Color(0xFFFDECF4);
  static const Color purpleBg = Color(0xFFEFEBFF);
}

class AppRadius {
  static const double card = 16;
  static const double chip = 20;
  static const double input = 10;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
  );
}
