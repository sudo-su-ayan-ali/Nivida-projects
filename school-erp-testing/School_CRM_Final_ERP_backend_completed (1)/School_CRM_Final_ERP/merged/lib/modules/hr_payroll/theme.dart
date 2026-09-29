import 'package:flutter/material.dart';

/// Central design system for the HRMS ERP app.
class AppColors {
  static const primary = Color(0xFF2F6FED); // professional blue
  static const primaryDark = Color(0xFF1E4FBF);
  static const primaryLight = Color(0xFFEAF1FE);

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFE9F9EF);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3E2);

  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFDECEC);

  static const purple = Color(0xFF7C5CFC);
  static const purpleLight = Color(0xFFF1EDFF);

  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFE6FBF8);

  static const pageBg = Color(0xFFF5F7FB);
  static const cardBg = Colors.white;
  static const border = Color(0xFFE7EAF0);

  static const textPrimary = Color(0xFF1A2233);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9AA3B2);
}

class AppRadius {
  static const card = 16.0;
  static const control = 10.0;
  static const chip = 999.0;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      background: AppColors.pageBg,
    ),
    scaffoldBackgroundColor: AppColors.pageBg,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
    ),
  );
}
