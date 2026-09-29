import 'package:flutter/material.dart';

/// Central color palette & theme for the School Inventory Dashboard.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDEFF5);

  static const Color textPrimary = Color(0xFF1B1F3B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primaryLight = Color(0xFFEDE9FE);

  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFE8F0FE);

  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFE7F8ED);

  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFFF3DF);

  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFDE9E9);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF1EBFE);

  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFE1F7F4);

  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFFCE7F3);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.border,
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Common rounded-card decoration used across the dashboard.
BoxDecoration cardDecoration({double radius = 18, Color? color}) {
  return BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A1B1F3B),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
    ],
  );
}
