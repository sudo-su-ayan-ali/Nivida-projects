import 'package:flutter/material.dart';

/// Design tokens — an original fintech/SaaS palette (Linear/Stripe inspired,
/// NOT copied from any reference image). Deep indigo/violet primary with an
/// electric cyan accent, tuned separately for dark and light surfaces.
class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF6E56F7); // electric indigo
  static const primaryDeep = Color(0xFF4A34C4);
  static const accent = Color(0xFF00E5C7); // electric teal accent
  static const accentAmber = Color(0xFFFFB454);
  static const danger = Color(0xFFFF5C7A);
  static const success = Color(0xFF2ED9A8);
  static const warning = Color(0xFFFFB454);
  static const info = Color(0xFF4CC2FF);

  // Dark surfaces
  static const darkBg = Color(0xFF0B0C14);
  static const darkSurface = Color(0xFF12131F);
  static const darkSurfaceAlt = Color(0xFF191B29);
  static const darkBorder = Color(0xFF262838);
  static const darkTextPrimary = Color(0xFFF3F3FA);
  static const darkTextSecondary = Color(0xFF9295AB);
  static const darkTextMuted = Color(0xFF61637A);

  // Light surfaces
  static const lightBg = Color(0xFFF6F6FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF0F0F8);
  static const lightBorder = Color(0xFFE3E3ED);
  static const lightTextPrimary = Color(0xFF15161F);
  static const lightTextSecondary = Color(0xFF5A5C70);
  static const lightTextMuted = Color(0xFF9294A6);

  // Chart gradient stops
  static const List<Color> chartGradient = [primary, accent];

  static const List<Color> agingBuckets = [
    Color(0xFF2ED9A8), // 0-30
    Color(0xFF4CC2FF), // 31-60
    Color(0xFFFFB454), // 61-90
    Color(0xFFFF8A5C), // 91-120
    Color(0xFFFF5C7A), // 120+
  ];
}
