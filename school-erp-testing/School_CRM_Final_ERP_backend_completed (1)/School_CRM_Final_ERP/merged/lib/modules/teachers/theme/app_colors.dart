import 'package:flutter/material.dart';

/// Centralized design tokens for the EduSmart School ERP app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B5CF6);
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color sidebar = Color(0xFF0B1029);
  static const Color sidebarMuted = Color(0xFFB6BAD6);
  static const Color sidebarFaint = Color(0xFF8B90B3);
  static const Color background = Color(0xFFF7F8FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEEF1F6);
  static const Color text = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0A111827), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x145B5CF6), blurRadius: 32, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> softerShadow = [
    BoxShadow(color: Color(0x0A111827), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F111827), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static Color badgeBg(String status) =>
      status == 'Active' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);

  static Color badgeText(String status) =>
      status == 'Active' ? const Color(0xFF15803D) : const Color(0xFFB45309);
}

/// Pastel background + accent pairs used for icon chips across the app.
class PastelPair {
  final Color bg;
  final Color fg;
  const PastelPair(this.bg, this.fg);
}

const List<PastelPair> pastelPalette = [
  PastelPair(Color(0xFFEEF0FF), AppColors.primary),
  PastelPair(Color(0xFFDFF7EC), AppColors.success),
  PastelPair(Color(0xFFE4EEFF), AppColors.blue),
  PastelPair(Color(0xFFFFF1DE), AppColors.warning),
  PastelPair(Color(0xFFF1E8FF), AppColors.secondary),
  PastelPair(Color(0xFFFFE7E7), AppColors.danger),
  PastelPair(Color(0xFFFFE3F0), Color(0xFFEC4899)),
];
