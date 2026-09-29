import 'package:flutter/material.dart';

/// Central design tokens for the Attendance Dashboard.
/// Colors / radii / spacing are lifted straight from the reference design spec
/// so every widget in this module stays visually consistent.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF5B5CF6);
  static const secondary = Color(0xFF7C4DFF);
  static const background = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Pastel icon-circle backgrounds (derived from the accent colors above)
  static const successBg = Color(0xFFDCFCE7);
  static const dangerBg = Color(0xFFFEE2E2);
  static const warningBg = Color(0xFFFEF3C7);
  static const infoBg = Color(0xFFDBEAFE);
  static const purple = Color(0xFF7C4DFF);
  static const purpleBg = Color(0xFFEDE9FE);
  static const cyan = Color(0xFF06B6D4);
  static const cyanBg = Color(0xFFCFFAFE);
}

class AppRadius {
  AppRadius._();
  static const card = 18.0;
  static const control = 12.0;
  static const pill = 999.0;
}

class AppSpacing {
  AppSpacing._();
  static const unit = 8.0;
  static double x(double n) => unit * n;
}

class AppText {
  AppText._();

  static const _font = 'Inter';

  static const pageTitle = TextStyle(
    fontFamily: _font,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const pageSubtitle = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const cardLabel = TextStyle(
    fontFamily: _font,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const cardNumber = TextStyle(
    fontFamily: _font,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const cardDelta = TextStyle(
    fontFamily: _font,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const tableHeader = TextStyle(
    fontFamily: _font,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static const tableCell = TextStyle(
    fontFamily: _font,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const tableCellMuted = TextStyle(
    fontFamily: _font,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

/// Reusable card decoration: rounded 18px, soft shadow, subtle border.
BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A111827),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    );
